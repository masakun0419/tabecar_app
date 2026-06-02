import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case missingToken
    case badStatus(Int, String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "API URLが不正です。"
        case .missingToken:
            "ログインが必要です。"
        case let .badStatus(status, message):
            message.isEmpty ? "APIエラー: \(status)" : message
        case .decodingFailed:
            "レスポンスの読み取りに失敗しました。"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    var baseURL = URL(string: "https://api.devapiserver.com/api/v1")!
    var accessToken: String?

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared) {
        self.session = session
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            if let date = DateParser.decode(value) {
                return date
            }
            throw APIError.decodingFailed
        }

        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(ISO8601DateFormatter.api.string(from: date))
        }
    }

    func get<Response: Decodable>(_ path: String, queryItems: [URLQueryItem] = [], authenticated: Bool = false) async throws -> Response {
        try await request(path, method: "GET", queryItems: queryItems, authenticated: authenticated, body: Optional<Data>.none)
    }

    func post<Request: Encodable, Response: Decodable>(_ path: String, body: Request, authenticated: Bool = false) async throws -> Response {
        let data = try encoder.encode(body)
        return try await request(path, method: "POST", authenticated: authenticated, body: data)
    }

    func patch<Request: Encodable, Response: Decodable>(_ path: String, body: Request, authenticated: Bool = true) async throws -> Response {
        let data = try encoder.encode(body)
        return try await request(path, method: "PATCH", authenticated: authenticated, body: data)
    }

    func postNoContent<Request: Encodable>(_ path: String, body: Request, authenticated: Bool = false) async throws {
        let data = try encoder.encode(body)
        let _: EmptyResponse = try await request(path, method: "POST", authenticated: authenticated, body: data)
    }

    func delete(_ path: String, authenticated: Bool = true) async throws {
        let _: EmptyResponse = try await request(path, method: "DELETE", authenticated: authenticated, body: Optional<Data>.none)
    }

    private func request<Response: Decodable>(
        _ path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        authenticated: Bool,
        body: Data?
    ) async throws -> Response {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body

        if authenticated {
            guard let token = accessToken else { throw APIError.missingToken }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.decodingFailed }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = (try? decoder.decode(ErrorResponse.self, from: data).detail) ?? String(data: data, encoding: .utf8) ?? ""
            throw APIError.badStatus(httpResponse.statusCode, message)
        }

        if data.isEmpty {
            return EmptyResponse() as! Response
        }
        return try decoder.decode(Response.self, from: data)
    }
}

private struct ErrorResponse: Decodable {
    let detail: String
}

private struct EmptyResponse: Decodable {}

private enum DateParser {
    static func decode(_ value: String) -> Date? {
        if let date = ISO8601DateFormatter.api.date(from: value) {
            return date
        }
        if let date = ISO8601DateFormatter.apiNoFraction.date(from: value) {
            return date
        }
        return localDateTime.date(from: value)
    }

    private static let localDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}

private extension ISO8601DateFormatter {
    static let api: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let apiNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

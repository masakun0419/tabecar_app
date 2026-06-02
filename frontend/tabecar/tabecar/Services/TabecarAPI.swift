import Foundation

struct TabecarAPI {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func events(latitude: Double? = nil, longitude: Double? = nil, radiusKm: Int = 5) async throws -> [FoodTruckEvent] {
        var items: [URLQueryItem] = [URLQueryItem(name: "radius_km", value: "\(radiusKm)")]
        if let latitude, let longitude {
            items.append(URLQueryItem(name: "latitude", value: "\(latitude)"))
            items.append(URLQueryItem(name: "longitude", value: "\(longitude)"))
        }
        return try await client.get("/events", queryItems: items)
    }

    func shops(openNow: Bool? = nil) async throws -> [ShopSummary] {
        var items: [URLQueryItem] = []
        if let openNow {
            items.append(URLQueryItem(name: "open_now", value: openNow ? "true" : "false"))
        }
        return try await client.get("/shops", queryItems: items)
    }

    func shop(id: Int) async throws -> ShopDetail {
        try await client.get("/shops/\(id)")
    }

    func createShop(_ request: ShopCreateRequest) async throws -> ShopDetail {
        try await client.post("/shops", body: request, authenticated: true)
    }

    func createEvent(_ request: EventCreateRequest) async throws -> FoodTruckEvent {
        try await client.post("/events", body: request, authenticated: true)
    }

    func favorites() async throws -> [FavoriteShop] {
        try await client.get("/favorites", authenticated: true)
    }

    func addFavorite(shopID: Int) async throws -> FavoriteShop {
        try await client.post("/favorites", body: ["shop_id": shopID], authenticated: true)
    }

    func removeFavorite(shopID: Int) async throws {
        try await client.delete("/favorites/\(shopID)", authenticated: true)
    }

    func notifications() async throws -> [AppNotification] {
        try await client.get("/notifications", authenticated: true)
    }

    func registerDeviceToken(_ token: String) async throws {
        let _: DeviceTokenResponse = try await client.post(
            "/device-tokens",
            body: ["fcm_token": token, "platform": "iOS"],
            authenticated: true
        )
    }
}

private struct DeviceTokenResponse: Decodable {
    let id: Int
    let fcmToken: String
    let platform: String
}

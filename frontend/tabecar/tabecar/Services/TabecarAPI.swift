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

    func shops(latitude: Double? = nil, longitude: Double? = nil, openNow: Bool? = nil) async throws -> [ShopSummary] {
        var items: [URLQueryItem] = []
        if let latitude, let longitude {
            items.append(URLQueryItem(name: "latitude", value: "\(latitude)"))
            items.append(URLQueryItem(name: "longitude", value: "\(longitude)"))
        }
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

    func unreadNotificationCount() async throws -> Int {
        let response: UnreadCountResponse = try await client.get("/notifications/unread-count", authenticated: true)
        return response.count
    }

    func markNotificationRead(id: Int) async throws -> AppNotification {
        try await client.patch("/notifications/\(id)/read", body: EmptyRequest())
    }

    func markAllNotificationsRead() async throws -> Int {
        let response: ReadAllNotificationsResponse = try await client.post("/notifications/read-all", body: EmptyRequest(), authenticated: true)
        return response.updated
    }

    func profile() async throws -> UserProfile {
        try await client.get("/profile", authenticated: true)
    }

    func updateProfile(latitude: Double? = nil, longitude: Double? = nil, notificationRadiusKm: Int? = nil) async throws -> UserProfile {
        try await client.patch(
            "/profile",
            body: ProfileUpdateRequest(
                latitude: latitude,
                longitude: longitude,
                notificationRadiusKm: notificationRadiusKm
            ),
            authenticated: true
        )
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

private struct EmptyRequest: Encodable {}

private struct UnreadCountResponse: Decodable {
    let count: Int
}

private struct ReadAllNotificationsResponse: Decodable {
    let updated: Int
}

private struct ProfileUpdateRequest: Encodable {
    let latitude: Double?
    let longitude: Double?
    let notificationRadiusKm: Int?

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case notificationRadiusKm = "notification_radius_km"
    }
}

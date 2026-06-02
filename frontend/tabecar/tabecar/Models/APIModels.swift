import Foundation

enum UserType: String, Codable, CaseIterable, Identifiable {
    case user = "USER"
    case shop = "SHOP"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .user: "一般"
        case .shop: "店舗"
        }
    }
}

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let displayName: String
    let userType: String
}

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
}

struct Category: Codable, Identifiable {
    let id: Int
    let name: String
}

struct ShopSummary: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let iconImageUrl: URL?
    let category: Category?
    let isOpenNow: Bool
    let nextEventLatitude: Double?
    let nextEventLongitude: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case iconImageUrl
        case category
        case isOpenNow
        case nextEventLatitude
        case nextEventLongitude
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        iconImageUrl = try container.decodeIfPresent(URL.self, forKey: .iconImageUrl)
        category = try container.decodeIfPresent(Category.self, forKey: .category)
        isOpenNow = try container.decode(Bool.self, forKey: .isOpenNow)
        nextEventLatitude = try container.decodeLossyDoubleIfPresent(forKey: .nextEventLatitude)
        nextEventLongitude = try container.decodeLossyDoubleIfPresent(forKey: .nextEventLongitude)
    }
}

struct ShopDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let phone: String?
    let email: String?
    let websiteUrl: URL?
    let instagramUrl: URL?
    let xUrl: URL?
    let iconImageUrl: URL?
    let category: Category?
    let images: [ShopImage]
    let menus: [Menu]
}

struct ShopImage: Codable, Identifiable {
    let id: Int
    let imageUrl: URL
    let caption: String?
    let displayOrder: Int
}

struct Menu: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String?
    let price: Int
    let imageUrl: URL?
    let isAvailable: Bool
    let displayOrder: Int
}

struct FoodTruckEvent: Codable, Identifiable {
    let id: Int
    let shopId: Int
    let shopName: String
    let title: String
    let address: String
    let prefecture: String
    let city: String?
    let latitude: Double
    let longitude: Double
    let startAt: Date
    let endAt: Date
    let note: String?
    let isCancelled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case shopId
        case shopName
        case title
        case address
        case prefecture
        case city
        case latitude
        case longitude
        case startAt
        case endAt
        case note
        case isCancelled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        shopId = try container.decode(Int.self, forKey: .shopId)
        shopName = try container.decode(String.self, forKey: .shopName)
        title = try container.decode(String.self, forKey: .title)
        address = try container.decode(String.self, forKey: .address)
        prefecture = try container.decode(String.self, forKey: .prefecture)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        latitude = try container.decodeLossyDouble(forKey: .latitude)
        longitude = try container.decodeLossyDouble(forKey: .longitude)
        startAt = try container.decode(Date.self, forKey: .startAt)
        endAt = try container.decode(Date.self, forKey: .endAt)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        isCancelled = try container.decode(Bool.self, forKey: .isCancelled)
    }
}

struct FavoriteShop: Codable, Identifiable {
    let id: Int
    let shopId: Int
    let shopName: String
    let iconImageUrl: URL?
    let createdAt: Date
}

struct AppNotification: Codable, Identifiable {
    let id: Int
    let shopId: Int?
    let eventId: Int?
    let notificationType: String
    let title: String
    let body: String
    let isRead: Bool
    let createdAt: Date
}

struct UserProfile: Codable {
    let notificationRadiusKm: Int
    let lastLatitude: Double?
    let lastLongitude: Double?

    enum CodingKeys: String, CodingKey {
        case notificationRadiusKm = "notification_radius_km"
        case lastLatitude = "last_latitude"
        case lastLongitude = "last_longitude"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        notificationRadiusKm = try container.decode(Int.self, forKey: .notificationRadiusKm)
        lastLatitude = try container.decodeLossyDoubleIfPresent(forKey: .lastLatitude)
        lastLongitude = try container.decodeLossyDoubleIfPresent(forKey: .lastLongitude)
    }
}

struct ShopCreateRequest: Encodable {
    let categoryId: Int?
    let name: String
    let description: String?
    let phone: String?
    let email: String?
    let websiteUrl: String?
    let instagramUrl: String?
    let xUrl: String?
    let iconImageUrl: String?
}

struct EventCreateRequest: Encodable {
    let title: String
    let address: String
    let prefecture: String
    let city: String?
    let latitude: Double
    let longitude: Double
    let startAt: Date
    let endAt: Date
    let note: String?
}

private extension KeyedDecodingContainer {
    func decodeLossyDouble(forKey key: Key) throws -> Double {
        if let value = try? decode(Double.self, forKey: key) {
            return value
        }
        let stringValue = try decode(String.self, forKey: key)
        if let value = Double(stringValue) {
            return value
        }
        throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Expected Double-compatible value")
    }

    func decodeLossyDoubleIfPresent(forKey key: Key) throws -> Double? {
        if try decodeNil(forKey: key) {
            return nil
        }
        if let value = try? decode(Double.self, forKey: key) {
            return value
        }
        if let stringValue = try? decode(String.self, forKey: key) {
            return Double(stringValue)
        }
        return nil
    }
}

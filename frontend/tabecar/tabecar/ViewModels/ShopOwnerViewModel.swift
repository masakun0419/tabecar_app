import Combine
import Foundation

@MainActor
final class ShopOwnerViewModel: ObservableObject {
    @Published var shopName = ""
    @Published var shopDescription = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var instagramURL = ""
    @Published var xURL = ""

    @Published var eventTitle = ""
    @Published var eventAddress = ""
    @Published var prefecture = ""
    @Published var city = ""
    @Published var latitude = ""
    @Published var longitude = ""
    @Published var startAt = Date()
    @Published var endAt = Date().addingTimeInterval(60 * 60 * 6)
    @Published var note = ""

    @Published var isLoading = false
    @Published var message: String?

    private let api = TabecarAPI()

    func createShop() async {
        isLoading = true
        message = nil
        defer { isLoading = false }

        do {
            let request = ShopCreateRequest(
                categoryId: nil,
                name: shopName,
                description: shopDescription.nilIfEmpty,
                phone: phone.nilIfEmpty,
                email: email.nilIfEmpty,
                websiteUrl: nil,
                instagramUrl: instagramURL.nilIfEmpty,
                xUrl: xURL.nilIfEmpty,
                iconImageUrl: nil
            )
            _ = try await api.createShop(request)
            message = "店舗プロフィールを登録しました"
        } catch {
            message = error.localizedDescription
        }
    }

    func createEvent() async {
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            message = "緯度経度を数値で入力してください"
            return
        }

        isLoading = true
        message = nil
        defer { isLoading = false }

        do {
            let request = EventCreateRequest(
                title: eventTitle,
                address: eventAddress,
                prefecture: prefecture,
                city: city.nilIfEmpty,
                latitude: lat,
                longitude: lon,
                startAt: startAt,
                endAt: endAt,
                note: note.nilIfEmpty
            )
            _ = try await api.createEvent(request)
            message = "出店予定を登録しました"
        } catch {
            message = error.localizedDescription
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

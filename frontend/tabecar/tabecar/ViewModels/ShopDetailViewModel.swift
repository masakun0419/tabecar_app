import Foundation

@MainActor
final class ShopDetailViewModel: ObservableObject {
    @Published private(set) var shop: ShopDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var favoriteMessage: String?

    private let api = TabecarAPI()
    private let shopID: Int

    init(shopID: Int) {
        self.shopID = shopID
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            shop = try await api.shop(id: shopID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addFavorite() async {
        do {
            _ = try await api.addFavorite(shopID: shopID)
            favoriteMessage = "お気に入りに追加しました"
        } catch {
            favoriteMessage = error.localizedDescription
        }
    }
}

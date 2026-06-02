import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [FavoriteShop] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = TabecarAPI()

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            favorites = try await api.favorites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func remove(shopID: Int) async {
        do {
            try await api.removeFavorite(shopID: shopID)
            favorites.removeAll { $0.shopId == shopID }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

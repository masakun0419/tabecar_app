import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var events: [FoodTruckEvent] = []
    @Published private(set) var shops: [ShopSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = TabecarAPI()

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            events = try await api.events()
            shops = try await api.shops()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

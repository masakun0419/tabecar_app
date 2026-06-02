import Combine
import CoreLocation
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var events: [FoodTruckEvent] = []
    @Published private(set) var shops: [ShopSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api = TabecarAPI()
    private let locationService: LocationService

    init(locationService: LocationService = .shared) {
        self.locationService = locationService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let coordinate = await locationService.requestCoordinate()
            let radiusKm = locationService.notificationRadiusKm

            if let coordinate {
                events = try await api.events(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    radiusKm: radiusKm
                )
                shops = try await api.shops(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            } else {
                events = try await api.events()
                shops = try await api.shops()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

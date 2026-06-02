import CoreLocation
import Foundation

@MainActor
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var notificationRadiusKm = 5

    private let manager = CLLocationManager()
    private let api = TabecarAPI()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func refreshProfileSettings() async {
        guard let profile = try? await api.profile() else { return }
        notificationRadiusKm = profile.notificationRadiusKm
        if let latitude = profile.lastLatitude, let longitude = profile.lastLongitude {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    func requestCoordinate() async -> CLLocationCoordinate2D? {
        if let coordinate {
            return coordinate
        }

        return await withCheckedContinuation { continuation in
            locationContinuation = continuation

            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                resumeContinuation(with: nil)
            }
        }
    }

    func syncToServer() async {
        guard let coordinate = await requestCoordinate() else { return }
        self.coordinate = coordinate

        if let profile = try? await api.updateProfile(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ) {
            notificationRadiusKm = profile.notificationRadiusKm
        }
    }

    func updateNotificationRadius(_ radiusKm: Int) async throws {
        _ = try await api.updateProfile(notificationRadiusKm: radiusKm)
        notificationRadiusKm = radiusKm
    }

    private func resumeContinuation(with coordinate: CLLocationCoordinate2D?) {
        if let coordinate {
            self.coordinate = coordinate
        }
        locationContinuation?.resume(returning: coordinate)
        locationContinuation = nil
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            guard locationContinuation != nil else { return }

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .denied, .restricted:
                resumeContinuation(with: nil)
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            resumeContinuation(with: locations.last?.coordinate)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            resumeContinuation(with: nil)
        }
    }
}

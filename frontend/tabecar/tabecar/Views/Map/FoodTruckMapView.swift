import MapKit
import SwiftUI

struct FoodTruckMapView: View {
    @ObservedObject private var locationService = LocationService.shared
    @StateObject private var viewModel = HomeViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                ForEach(viewModel.events) { event in
                    Marker(event.shopName, coordinate: event.coordinate)
                        .tint(.orange)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .safeAreaInset(edge: .bottom) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.events) { event in
                            NavigationLink {
                                ShopDetailView(shopID: event.shopId)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.shopName)
                                        .font(.headline)
                                    Text(event.title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                    Text(event.address)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                .frame(width: 220, alignment: .leading)
                                .padding(12)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: event.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                                    )
                                )
                            })
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.events.isEmpty && viewModel.errorMessage == nil {
                    ContentUnavailableView(
                        "出店予定なし",
                        systemImage: "map",
                        description: Text("近くの出店予定がここに表示されます")
                    )
                }
            }
            .navigationTitle("マップ")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if let coordinate = await locationService.requestCoordinate() {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                        )
                    )
                } else {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: 34.685087, longitude: 135.804848),
                            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
                        )
                    )
                }
                await viewModel.load()
            }
        }
    }
}

private extension FoodTruckEvent {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}

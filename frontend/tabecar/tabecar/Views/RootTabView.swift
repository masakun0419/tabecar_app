import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var session: AuthSession
    @StateObject private var badgeViewModel = NotificationBadgeViewModel()
    @ObservedObject private var locationService = LocationService.shared

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "list.bullet")
                }

            FoodTruckMapView()
                .tabItem {
                    Label("マップ", systemImage: "map")
                }

            FavoritesView()
                .tabItem {
                    Label("お気に入り", systemImage: "heart")
                }

            NotificationsView()
                .environmentObject(badgeViewModel)
                .tabItem {
                    Label("通知", systemImage: "bell")
                }
                .badge(badgeViewModel.unreadCount)

            if session.assumedUserType == .shop {
                ShopOwnerView()
                    .tabItem {
                        Label("店舗", systemImage: "storefront")
                    }
            }

            ProfileView()
                .tabItem {
                    Label("設定", systemImage: "person.crop.circle")
                }
        }
        .tint(Tabecar.orange)
        .task {
            await locationService.refreshProfileSettings()
            await locationService.syncToServer()
            await badgeViewModel.refresh()
        }
    }
}

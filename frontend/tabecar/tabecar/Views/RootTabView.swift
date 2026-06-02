import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var session: AuthSession

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
                .tabItem {
                    Label("通知", systemImage: "bell")
                }

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
    }
}

import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .listRowBackground(Color.clear)
                }

                ForEach(viewModel.favorites) { favorite in
                    NavigationLink {
                        ShopDetailView(shopID: favorite.shopId)
                    } label: {
                        FavoriteRow(favorite: favorite)
                    }
                    .listRowBackground(Color.white)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { await viewModel.remove(shopID: favorite.shopId) }
                        } label: {
                            Label("解除", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Tabecar.background)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.favorites.isEmpty && viewModel.errorMessage == nil {
                    ContentUnavailableView(
                        "お気に入りなし",
                        systemImage: "heart",
                        description: Text("店舗詳細から追加できます")
                    )
                }
            }
            .navigationTitle("お気に入り")
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .tint(Tabecar.orange)
    }
}

private struct FavoriteRow: View {
    let favorite: FavoriteShop

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: favorite.iconImageUrl) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(Tabecar.orange.opacity(0.6))
            }
            .frame(width: 52, height: 52)
            .background(Tabecar.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.shopName)
                    .font(.headline)
                    .foregroundStyle(Tabecar.textPrimary)
                Label(
                    "追加日 \(favorite.createdAt.formatted(date: .abbreviated, time: .omitted))",
                    systemImage: "calendar"
                )
                .font(.caption)
                .foregroundStyle(Tabecar.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

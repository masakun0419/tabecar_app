import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                ForEach(viewModel.favorites) { favorite in
                    NavigationLink {
                        ShopDetailView(shopID: favorite.shopId)
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: favorite.iconImageUrl) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                            }
                            .frame(width: 44, height: 44)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(favorite.shopName)
                                    .font(.headline)
                                Text("追加日 \(favorite.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { await viewModel.remove(shopID: favorite.shopId) }
                        } label: {
                            Label("解除", systemImage: "trash")
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.favorites.isEmpty && viewModel.errorMessage == nil {
                    ContentUnavailableView("お気に入りなし", systemImage: "heart", description: Text("店舗詳細から追加できます"))
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
    }
}

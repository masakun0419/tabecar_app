import SwiftUI

struct ShopDetailView: View {
    @StateObject private var viewModel: ShopDetailViewModel

    init(shopID: Int) {
        _viewModel = StateObject(wrappedValue: ShopDetailViewModel(shopID: shopID))
    }

    var body: some View {
        List {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }

            if let shop = viewModel.shop {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        AsyncImage(url: shop.iconImageUrl) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image(systemName: "truck.box")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text(shop.name)
                            .font(.title2.bold())
                        Text(shop.category?.name ?? "カテゴリ未設定")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let description = shop.description {
                            Text(description)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("メニュー") {
                    if shop.menus.isEmpty {
                        Text("メニューはまだ登録されていません")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(shop.menus.sorted { $0.displayOrder < $1.displayOrder }) { menu in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(menu.name)
                                    if let description = menu.description {
                                        Text(description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text(menu.price, format: .currency(code: "JPY"))
                            }
                        }
                    }
                }

                Section("連絡先") {
                    if let phone = shop.phone {
                        Label(phone, systemImage: "phone")
                    }
                    if let email = shop.email {
                        Label(email, systemImage: "envelope")
                    }
                    if let instagramUrl = shop.instagramUrl {
                        Link("Instagram", destination: instagramUrl)
                    }
                    if let xUrl = shop.xUrl {
                        Link("X", destination: xUrl)
                    }
                }

                Section {
                    Button {
                        Task { await viewModel.addFavorite() }
                    } label: {
                        Label("お気に入りに追加", systemImage: "heart")
                    }
                    if let message = viewModel.favoriteMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("店舗詳細")
        .task {
            await viewModel.load()
        }
    }
}

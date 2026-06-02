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
                    .listRowBackground(Color.clear)
            }

            if let shop = viewModel.shop {
                // Hero section
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        AsyncImage(url: shop.iconImageUrl) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ZStack {
                                Rectangle()
                                    .fill(Tabecar.orange.opacity(0.1))
                                Image(systemName: "truck.box")
                                    .font(.system(size: 52))
                                    .foregroundStyle(Tabecar.orange.opacity(0.5))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        Text(shop.name)
                            .font(.title2.bold())
                            .foregroundStyle(Tabecar.textPrimary)

                        Text(shop.category?.name ?? "カテゴリ未設定")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Tabecar.orange.opacity(0.12))
                            .foregroundStyle(Tabecar.orange)
                            .clipShape(Capsule())

                        if let description = shop.description {
                            Text(description)
                                .foregroundStyle(Tabecar.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Menu section
                Section {
                    if shop.menus.isEmpty {
                        Text("メニューはまだ登録されていません")
                            .foregroundStyle(Tabecar.textSecondary)
                    } else {
                        ForEach(shop.menus.sorted { $0.displayOrder < $1.displayOrder }) { menu in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(menu.name)
                                        .foregroundStyle(Tabecar.textPrimary)
                                    if let description = menu.description {
                                        Text(description)
                                            .font(.caption)
                                            .foregroundStyle(Tabecar.textSecondary)
                                    }
                                }
                                Spacer()
                                Text(menu.price, format: .currency(code: "JPY"))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Tabecar.orange)
                            }
                        }
                    }
                } header: {
                    Label("メニュー", systemImage: "fork.knife")
                        .foregroundStyle(Tabecar.textPrimary)
                }

                // Contact section
                Section {
                    if let phone = shop.phone {
                        Label(phone, systemImage: "phone")
                            .foregroundStyle(Tabecar.textPrimary)
                    }
                    if let email = shop.email {
                        Label(email, systemImage: "envelope")
                            .foregroundStyle(Tabecar.textPrimary)
                    }
                    if let instagramUrl = shop.instagramUrl {
                        Link(destination: instagramUrl) {
                            Label("Instagram", systemImage: "camera")
                                .foregroundStyle(Tabecar.orange)
                        }
                    }
                    if let xUrl = shop.xUrl {
                        Link(destination: xUrl) {
                            Label("X (Twitter)", systemImage: "bird")
                                .foregroundStyle(Tabecar.orange)
                        }
                    }
                } header: {
                    Label("連絡先", systemImage: "phone.circle")
                        .foregroundStyle(Tabecar.textPrimary)
                }

                // Favorite section
                Section {
                    Button {
                        Task { await viewModel.addFavorite() }
                    } label: {
                        Label("お気に入りに追加", systemImage: "heart")
                            .foregroundStyle(Tabecar.orange)
                    }
                    if let message = viewModel.favoriteMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(Tabecar.textSecondary)
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
        .navigationBarTitleDisplayMode(.inline)
        .tint(Tabecar.orange)
        .task {
            await viewModel.load()
        }
    }
}

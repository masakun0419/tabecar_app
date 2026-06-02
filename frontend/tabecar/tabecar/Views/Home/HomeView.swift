import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }

                    if !viewModel.events.isEmpty {
                        SectionHeader(title: "出店予定", systemImage: "calendar")
                            .padding(.horizontal)
                            .padding(.top, 4)

                        ForEach(viewModel.events) { event in
                            NavigationLink {
                                ShopDetailView(shopID: event.shopId)
                            } label: {
                                EventCard(event: event)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }

                    if !viewModel.shops.isEmpty {
                        SectionHeader(title: "店舗", systemImage: "storefront")
                            .padding(.horizontal)
                            .padding(.top, 8)

                        ForEach(viewModel.shops) { shop in
                            NavigationLink {
                                ShopDetailView(shopID: shop.id)
                            } label: {
                                ShopCard(shop: shop)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Tabecar.background)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("食べカー")
            .toolbar {
                Button {
                    Task { await viewModel.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .tint(Tabecar.orange)
            }
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

private struct EventCard: View {
    let event: FoodTruckEvent

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Tabecar.orange)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline)
                    .foregroundStyle(Tabecar.textPrimary)
                Text(event.shopName)
                    .font(.subheadline)
                    .foregroundStyle(Tabecar.orange)
                Label(event.address, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(Tabecar.textSecondary)
                Label(
                    "\(event.startAt.formatted(date: .abbreviated, time: .shortened)) – \(event.endAt.formatted(date: .omitted, time: .shortened))",
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundStyle(Tabecar.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Tabecar.textSecondary.opacity(0.4))
                .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

private struct ShopCard: View {
    let shop: ShopSummary

    var body: some View {
        HStack(spacing: 14) {
            AsyncImage(url: shop.iconImageUrl) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "truck.box")
                    .font(.title2)
                    .foregroundStyle(Tabecar.orange.opacity(0.7))
            }
            .frame(width: 56, height: 56)
            .background(Tabecar.orange.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(shop.name)
                        .font(.headline)
                        .foregroundStyle(Tabecar.textPrimary)
                    if shop.isOpenNow {
                        Text("営業中")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(.green.opacity(0.12))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }
                }
                Text(shop.category?.name ?? "カテゴリ未設定")
                    .font(.caption)
                    .foregroundStyle(Tabecar.orange.opacity(0.85))
                if let description = shop.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Tabecar.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Tabecar.textSecondary.opacity(0.4))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

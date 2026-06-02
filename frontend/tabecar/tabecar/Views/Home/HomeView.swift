import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                Section("出店予定") {
                    ForEach(viewModel.events) { event in
                        NavigationLink {
                            ShopDetailView(shopID: event.shopId)
                        } label: {
                            EventRow(event: event)
                        }
                    }
                }

                Section("店舗") {
                    ForEach(viewModel.shops) { shop in
                        NavigationLink {
                            ShopDetailView(shopID: shop.id)
                        } label: {
                            ShopSummaryRow(shop: shop)
                        }
                    }
                }
            }
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
            }
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }
}

struct EventRow: View {
    let event: FoodTruckEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title)
                .font(.headline)
            Text(event.shopName)
                .foregroundStyle(.secondary)
            Label(event.address, systemImage: "mappin.and.ellipse")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(event.startAt.formatted(date: .abbreviated, time: .shortened)) - \(event.endAt.formatted(date: .omitted, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ShopSummaryRow: View {
    let shop: ShopSummary

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: shop.iconImageUrl) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "truck.box")
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48, height: 48)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(shop.name)
                        .font(.headline)
                    if shop.isOpenNow {
                        Text("営業中")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.green.opacity(0.15))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }
                }
                Text(shop.category?.name ?? "カテゴリ未設定")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let description = shop.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

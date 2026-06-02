import SwiftUI

struct ShopOwnerView: View {
    @StateObject private var viewModel = ShopOwnerViewModel()

    var body: some View {
        NavigationStack {
            Form {
                if let message = viewModel.message {
                    Section {
                        Text(message)
                            .foregroundColor(message.contains("しました") ? .green : .red)
                    }
                }

                Section("店舗プロフィール") {
                    TextField("店舗名", text: $viewModel.shopName)
                    TextField("説明", text: $viewModel.shopDescription, axis: .vertical)
                    TextField("電話番号", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                    TextField("店舗メール", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Instagram URL", text: $viewModel.instagramURL)
                        .textInputAutocapitalization(.never)
                    TextField("X URL", text: $viewModel.xURL)
                        .textInputAutocapitalization(.never)

                    Button {
                        Task { await viewModel.createShop() }
                    } label: {
                        Label("店舗を登録", systemImage: "storefront")
                    }
                    .disabled(viewModel.shopName.isEmpty || viewModel.isLoading)
                }

                Section("出店予定") {
                    TextField("タイトル", text: $viewModel.eventTitle)
                    TextField("住所", text: $viewModel.eventAddress, axis: .vertical)
                    TextField("都道府県", text: $viewModel.prefecture)
                    TextField("市区町村", text: $viewModel.city)
                    TextField("緯度", text: $viewModel.latitude)
                        .keyboardType(.decimalPad)
                    TextField("経度", text: $viewModel.longitude)
                        .keyboardType(.decimalPad)
                    DatePicker("開始", selection: $viewModel.startAt)
                    DatePicker("終了", selection: $viewModel.endAt)
                    TextField("備考", text: $viewModel.note, axis: .vertical)

                    Button {
                        Task { await viewModel.createEvent() }
                    } label: {
                        Label("出店予定を登録", systemImage: "calendar.badge.plus")
                    }
                    .disabled(!canCreateEvent || viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("店舗管理")
        }
    }

    private var canCreateEvent: Bool {
        !viewModel.eventTitle.isEmpty &&
        !viewModel.eventAddress.isEmpty &&
        !viewModel.prefecture.isEmpty &&
        !viewModel.latitude.isEmpty &&
        !viewModel.longitude.isEmpty
    }
}

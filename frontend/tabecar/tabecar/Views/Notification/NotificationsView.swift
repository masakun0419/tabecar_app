import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                ForEach(viewModel.notifications) { notification in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(notification.title)
                                .font(.headline)
                            Spacer()
                            Text(notification.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(notification.body)
                            .foregroundStyle(.secondary)
                        Text(notification.notificationType)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.notifications.isEmpty && viewModel.errorMessage == nil {
                    ContentUnavailableView("通知なし", systemImage: "bell", description: Text("出店通知がここに表示されます"))
                }
            }
            .navigationTitle("通知")
            .task {
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }
}

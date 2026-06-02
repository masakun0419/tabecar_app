import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .listRowBackground(Color.clear)
                }

                ForEach(viewModel.notifications) { notification in
                    NotificationRow(notification: notification)
                        .listRowBackground(Color.white)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Tabecar.background)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.notifications.isEmpty && viewModel.errorMessage == nil {
                    ContentUnavailableView(
                        "通知なし",
                        systemImage: "bell",
                        description: Text("出店通知がここに表示されます")
                    )
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
        .tint(Tabecar.orange)
    }
}

private struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Tabecar.orange.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: "bell.fill")
                    .foregroundStyle(Tabecar.orange)
                    .font(.system(size: 17))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundStyle(Tabecar.textPrimary)
                    Spacer()
                    Text(notification.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(Tabecar.textSecondary)
                }
                Text(notification.body)
                    .font(.subheadline)
                    .foregroundStyle(Tabecar.textSecondary)
                Text(notification.notificationType)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Tabecar.orange.opacity(0.1))
                    .foregroundStyle(Tabecar.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

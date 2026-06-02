import SwiftUI

struct AuthRootView: View {
    @EnvironmentObject private var session: AuthSession
    @StateObject private var viewModel = AuthViewModel()
    @State private var mode: AuthMode = .login
    @State private var didAttemptBiometricLogin = false

    var body: some View {
        ZStack {
            Tabecar.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Hero header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Tabecar.orange.opacity(0.15))
                                .frame(width: 110, height: 110)
                            Image(systemName: "truck.box.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(Tabecar.orange)
                        }

                        Text("食べカー")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Tabecar.textPrimary)

                        Text("キッチンカー出店情報アプリ")
                            .font(.subheadline)
                            .foregroundStyle(Tabecar.textSecondary)
                    }
                    .padding(.top, 56)
                    .padding(.bottom, 36)

                    // Form card
                    VStack(spacing: 20) {
                        // User type picker
                        HStack(spacing: 0) {
                            ForEach(UserType.allCases) { type in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        viewModel.userType = type
                                    }
                                } label: {
                                    Text(type.title)
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 9)
                                        .background(
                                            viewModel.userType == type ? Tabecar.orange : Color.clear
                                        )
                                        .foregroundStyle(
                                            viewModel.userType == type ? .white : Tabecar.textSecondary
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(4)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())

                        // Input fields
                        VStack(spacing: 12) {
                            SoftTextField(
                                placeholder: "メールアドレス",
                                text: $viewModel.email,
                                systemImage: "envelope",
                                isEmail: true
                            )

                            SoftTextField(
                                placeholder: "パスワード",
                                text: $viewModel.password,
                                systemImage: "lock",
                                isSecure: true
                            )

                            if mode == .register {
                                SoftTextField(
                                    placeholder: "表示名",
                                    text: $viewModel.displayName,
                                    systemImage: "person"
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: mode)

                        // Error message
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text(error)
                                    .font(.caption)
                            }
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // Biometric login (general users only)
                        if session.biometricLoginAvailable, viewModel.userType == .user, mode == .login {
                            VStack(spacing: 8) {
                                if let email = session.savedEmail {
                                    Text(email)
                                        .font(.caption)
                                        .foregroundStyle(Tabecar.textSecondary)
                                }

                                Button {
                                    Task { await viewModel.loginWithBiometrics(session: session) }
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: session.biometricSystemImage)
                                            .font(.title2)
                                        Text("\(session.biometricLabel)でログイン")
                                            .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Tabecar.orange.opacity(0.12))
                                    .foregroundStyle(Tabecar.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .disabled(viewModel.isLoading)
                            }
                        }

                        // Primary action button
                        Button {
                            Task {
                                if mode == .login {
                                    await viewModel.login(session: session)
                                } else {
                                    await viewModel.registerThenLogin(session: session)
                                }
                            }
                        } label: {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(mode.buttonTitle)
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                (viewModel.isLoading || (mode == .login ? !viewModel.canLogin : !viewModel.canRegister))
                                    ? Tabecar.orange.opacity(0.5)
                                    : Tabecar.orange
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(viewModel.isLoading || (mode == .login ? !viewModel.canLogin : !viewModel.canRegister))

                        // Switch mode
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                mode = mode == .login ? .register : .login
                            }
                            viewModel.errorMessage = nil
                        } label: {
                            Text(mode.switchTitle)
                                .font(.subheadline)
                                .foregroundStyle(Tabecar.orange)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 4)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            if let email = session.savedEmail, viewModel.email.isEmpty {
                viewModel.email = email
            }
            guard !didAttemptBiometricLogin,
                  session.biometricLoginAvailable,
                  viewModel.userType == .user,
                  mode == .login else { return }
            didAttemptBiometricLogin = true
            Task { await viewModel.loginWithBiometrics(session: session) }
        }
    }
}

private enum AuthMode {
    case login, register

    var buttonTitle: String {
        switch self {
        case .login: "ログインする"
        case .register: "登録してログイン"
        }
    }

    var switchTitle: String {
        switch self {
        case .login: "アカウントを作成"
        case .register: "ログインに戻る"
        }
    }
}

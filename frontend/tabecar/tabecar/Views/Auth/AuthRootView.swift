import SwiftUI

struct AuthRootView: View {
    @EnvironmentObject private var session: AuthSession
    @StateObject private var viewModel = AuthViewModel()
    @State private var mode: AuthMode = .login

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("利用区分", selection: $viewModel.userType) {
                        ForEach(UserType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("メールアドレス", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("パスワード", text: $viewModel.password)

                    if mode == .register {
                        TextField("表示名", text: $viewModel.displayName)
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task {
                            if mode == .login {
                                await viewModel.login(session: session)
                            } else {
                                await viewModel.registerThenLogin(session: session)
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(mode.buttonTitle)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isLoading || (mode == .login ? !viewModel.canLogin : !viewModel.canRegister))

                    Button(mode.switchTitle) {
                        mode = mode == .login ? .register : .login
                        viewModel.errorMessage = nil
                    }
                }
            }
            .navigationTitle(mode.title)
        }
    }
}

private enum AuthMode {
    case login
    case register

    var title: String {
        switch self {
        case .login: "ログイン"
        case .register: "会員登録"
        }
    }

    var buttonTitle: String {
        switch self {
        case .login: "ログイン"
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

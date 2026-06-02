import SwiftUI

enum Tabecar {
    static let orange = Color(red: 1.0, green: 0.56, blue: 0.27)
    static let background = Color(red: 1.0, green: 0.97, blue: 0.94)
    static let textPrimary = Color(red: 0.24, green: 0.17, blue: 0.12)
    static let textSecondary = Color(red: 0.49, green: 0.37, blue: 0.32)
    static let fieldBackground = Color(red: 0.94, green: 0.94, blue: 0.96)
}

struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(Tabecar.orange)
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Tabecar.textPrimary)
        }
        .padding(.top, 8)
    }
}

struct SoftTextField: View {
    let placeholder: String
    @Binding var text: String
    let systemImage: String
    var isSecure: Bool = false
    var isEmail: Bool = false

    private var placeholderPrompt: Text {
        Text(placeholder)
            .foregroundStyle(Tabecar.textSecondary.opacity(0.45))
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(Tabecar.orange)
                .frame(width: 20)
            inputField
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Tabecar.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var inputField: some View {
        if isSecure {
            SecureField("", text: $text, prompt: placeholderPrompt)
                .foregroundStyle(Tabecar.textPrimary)
        } else if isEmail {
            #if os(iOS)
            TextField("", text: $text, prompt: placeholderPrompt)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(Tabecar.textPrimary)
            #else
            TextField("", text: $text, prompt: placeholderPrompt)
                .foregroundStyle(Tabecar.textPrimary)
            #endif
        } else {
            TextField("", text: $text, prompt: placeholderPrompt)
                .foregroundStyle(Tabecar.textPrimary)
        }
    }
}

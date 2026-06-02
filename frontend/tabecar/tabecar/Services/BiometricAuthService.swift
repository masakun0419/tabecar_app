import Foundation
import LocalAuthentication

enum BiometricAuthError: LocalizedError {
    case unavailable
    case cancelled
    case failed

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "生体認証を利用できません。"
        case .cancelled:
            nil
        case .failed:
            "認証に失敗しました。"
        }
    }
}

enum BiometricAuthService {
    static func isAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    static var label: String {
        switch biometryType() {
        case .faceID:
            "Face ID"
        case .touchID:
            "Touch ID"
        default:
            "生体認証"
        }
    }

    static var systemImage: String {
        switch biometryType() {
        case .faceID:
            "faceid"
        case .touchID:
            "touchid"
        default:
            "lock.shield"
        }
    }

    private static func biometryType() -> LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }
}

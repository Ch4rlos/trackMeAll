import Foundation
import LocalAuthentication

/// Envoltorio de LocalAuthentication. Sabe qué biometría tiene el equipo
/// (Face ID / Touch ID / Optic ID), si está enrolada, y distingue los errores
/// que importan: cancelado por el usuario, bloqueo por intentos, biometría no
/// disponible (con fallback a código del dispositivo).
public struct BiometricAuthenticator: Sendable {

    public enum Biometry: Sendable, Equatable {
        case faceID, touchID, opticID, none

        public var displayName: String {
            switch self {
            case .faceID: "Face ID"
            case .touchID: "Touch ID"
            case .opticID: "Optic ID"
            case .none: "sin biometría"
            }
        }

        public var symbolName: String {
            switch self {
            case .faceID: "faceid"
            case .touchID: "touchid"
            case .opticID: "opticid"
            case .none: "lock.trianglebadge.exclamationmark"
            }
        }
    }

    public enum Failure: Error, Sendable, Equatable {
        case cancelled
        case userFallback
        case biometryLockedOut
        case biometryNotAvailable
        case biometryNotEnrolled
        case passcodeNotSet
        case unknown(String)

        public var message: String {
            switch self {
            case .cancelled: "Autenticación cancelada."
            case .userFallback: "Pediste usar el código del dispositivo."
            case .biometryLockedOut: "Biometría bloqueada por intentos fallidos. Usa el código del dispositivo."
            case .biometryNotAvailable: "Este equipo no tiene biometría disponible."
            case .biometryNotEnrolled: "No hay Face ID ni Touch ID configurado en el equipo."
            case .passcodeNotSet: "El equipo no tiene código de desbloqueo configurado."
            case .unknown(let detail): "No se pudo autenticar: \(detail)"
            }
        }
    }

    public init() {}

    /// Consulta sin disparar el diálogo del sistema.
    public func availableBiometry() -> Biometry {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        case .none: return .none
        @unknown default: return .none
        }
    }

    /// `true` si el equipo puede autenticar con biometría ahora mismo.
    public func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        let can = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return can && context.biometryType != .none
    }

    /// Desbloqueo. Primero biometría; si el usuario elige el código o la biometría
    /// está bloqueada, cae a `deviceOwnerAuthentication` (código del iPhone).
    @MainActor
    public func unlock(reason: String) async throws(Failure) {
        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"
        context.localizedFallbackTitle = "Usar código"

        do {
            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                             localizedReason: reason)
        } catch {
            throw Self.map(error)
        }
    }

    /// Camino con fallback explícito al código del dispositivo.
    @MainActor
    public func unlockWithPasscodeFallback(reason: String) async throws(Failure) {
        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"

        do {
            try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch {
            throw Self.map(error)
        }
    }

    private static func map(_ error: Error) -> Failure {
        guard let laError = error as? LAError else {
            return .unknown(error.localizedDescription)
        }
        switch laError.code {
        case .userCancel, .systemCancel, .appCancel: return .cancelled
        case .userFallback: return .userFallback
        case .biometryLockout: return .biometryLockedOut
        case .biometryNotAvailable: return .biometryNotAvailable
        case .biometryNotEnrolled: return .biometryNotEnrolled
        case .passcodeNotSet: return .passcodeNotSet
        default: return .unknown(laError.localizedDescription)
        }
    }
}

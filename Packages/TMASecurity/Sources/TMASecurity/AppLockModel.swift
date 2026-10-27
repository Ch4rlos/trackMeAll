import Foundation
import Observation
import TMACore
import LocalAuthentication

/// Estado de bloqueo de la app. Vive en memoria: al volver del background se
/// cierra sola, y si la biometría falla se puede caer al código del dispositivo.
@MainActor
@Observable
public final class AppLockModel {

    public enum State: Equatable, Sendable {
        case locked
        case unlocking
        case unlocked
    }

    public private(set) var state: State = .locked
    public private(set) var lastErrorMessage: String?
    public private(set) var biometry: BiometricAuthenticator.Biometry
    public private(set) var failedAttempts = 0

    /// Preferencia del usuario: pedir biometría al abrir. Se guarda en UserDefaults.
    public var biometricsEnabled: Bool {
        didSet {
            defaults.set(biometricsEnabled, forKey: Self.enabledKey)
            if !biometricsEnabled { state = .unlocked }
        }
    }

    private static let enabledKey = "tma.biometrics.enabled"
    private let authenticator: BiometricAuthenticator
    private let defaults: UserDefaults
    private let keychain: KeychainStore

    public init(authenticator: BiometricAuthenticator = BiometricAuthenticator(),
                defaults: UserDefaults = .standard,
                keychain: KeychainStore = KeychainStore()) {
        self.authenticator = authenticator
        self.defaults = defaults
        self.keychain = keychain
        self.biometry = authenticator.availableBiometry()

        if defaults.object(forKey: Self.enabledKey) == nil {
            self.biometricsEnabled = true
        } else {
            self.biometricsEnabled = defaults.bool(forKey: Self.enabledKey)
        }

        if !biometricsEnabled || !authenticator.canUseBiometrics() {
            self.state = biometricsEnabled ? .locked : .unlocked
        }
    }

    public var biometryAvailable: Bool {
        authenticator.canUseBiometrics()
    }

    public var requiresAuthentication: Bool {
        biometricsEnabled && biometryAvailable
    }

    public func lock() {
        guard biometricsEnabled else { return }
        state = .locked
        lastErrorMessage = nil
    }

    /// Se llama al volver del background: bloquea sin animación.
    public func lockIfNeeded() {
        guard biometricsEnabled, state == .unlocked else { return }
        state = .locked
    }

    public func unlock() async {
        guard state != .unlocking else { return }
        state = .unlocking
        lastErrorMessage = nil
        TMAHaptics.tap()

        do {
            try await authenticator.unlock(reason: "Desbloquear trackMeAll")
            state = .unlocked
            failedAttempts = 0
            TMAHaptics.success()
        } catch {
            failedAttempts += 1
            lastErrorMessage = error.message
            state = .locked
            TMAHaptics.error()
        }
    }

    public func unlockWithDevicePasscode() async {
        guard state != .unlocking else { return }
        state = .unlocking
        lastErrorMessage = nil

        do {
            try await authenticator.unlockWithPasscodeFallback(reason: "Desbloquear trackMeAll")
            state = .unlocked
            failedAttempts = 0
            TMAHaptics.success()
        } catch {
            lastErrorMessage = error.message
            state = .locked
            TMAHaptics.error()
        }
    }

    // MARK: Keychain con biometría

    /// Guarda un secreto protegido por el juego actual de rostros/huellas.
    public func storeSecret(_ secret: Data, account: String) throws(KeychainError) {
        do {
            try keychain.save(secret, account: account, accessibility: .biometryCurrentSet)
        } catch let error as KeychainError {
            throw error
        } catch {
            throw KeychainError.write(errSecInternalError)
        }
    }

    public func readSecret(account: String) throws(KeychainError) -> Data {
        do {
            return try keychain.read(account: account)
        } catch let error as KeychainError {
            throw error
        } catch {
            throw KeychainError.read(errSecInternalError)
        }
    }
}

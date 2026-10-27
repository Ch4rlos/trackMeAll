import Testing
import Foundation
@testable import TMASecurity

/// Biometría falsa: se le programa el resultado de cada intento.
@MainActor
final class FakeBiometrics: BiometricEvaluating {
    var biometry: BiometricAuthenticator.Biometry
    var canUse: Bool
    var unlockResult: Result<Void, BiometricAuthenticator.Failure>
    var passcodeResult: Result<Void, BiometricAuthenticator.Failure>
    private(set) var unlockCalls = 0
    private(set) var passcodeCalls = 0

    init(biometry: BiometricAuthenticator.Biometry = .faceID,
         canUse: Bool = true,
         unlockResult: Result<Void, BiometricAuthenticator.Failure> = .success(()),
         passcodeResult: Result<Void, BiometricAuthenticator.Failure> = .success(())) {
        self.biometry = biometry
        self.canUse = canUse
        self.unlockResult = unlockResult
        self.passcodeResult = passcodeResult
    }

    func availableBiometry() -> BiometricAuthenticator.Biometry { biometry }
    func canUseBiometrics() -> Bool { canUse }

    func unlock(reason: String) async throws(BiometricAuthenticator.Failure) {
        unlockCalls += 1
        try unlockResult.get()
    }

    func unlockWithPasscodeFallback(reason: String) async throws(BiometricAuthenticator.Failure) {
        passcodeCalls += 1
        try passcodeResult.get()
    }
}

@MainActor
@Suite("Bloqueo de la app")
struct AppLockModelTests {

    private func makeDefaults() -> UserDefaults {
        let suite = "tma.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func makeLock(_ fake: FakeBiometrics) -> AppLockModel {
        AppLockModel(authenticator: fake, defaults: makeDefaults())
    }

    @Test("Arranca bloqueada cuando hay biometría y la preferencia está activa")
    func startsLocked() {
        let lock = makeLock(FakeBiometrics())
        #expect(lock.state == .locked)
        #expect(lock.requiresAuthentication)
        #expect(lock.biometry == .faceID)
    }

    @Test("Desbloqueo correcto deja la app abierta y sin errores")
    func unlockSucceeds() async {
        let fake = FakeBiometrics()
        let lock = makeLock(fake)

        await lock.unlock()

        #expect(lock.state == .unlocked)
        #expect(lock.lastErrorMessage == nil)
        #expect(lock.failedAttempts == 0)
        #expect(fake.unlockCalls == 1)
    }

    @Test("Un fallo de biometría mantiene el bloqueo y cuenta el intento")
    func unlockFails() async {
        let fake = FakeBiometrics(unlockResult: .failure(.biometryLockedOut))
        let lock = makeLock(fake)

        await lock.unlock()

        #expect(lock.state == .locked)
        #expect(lock.failedAttempts == 1)
        #expect(lock.lastErrorMessage == BiometricAuthenticator.Failure.biometryLockedOut.message)

        await lock.unlock()
        #expect(lock.failedAttempts == 2)
    }

    @Test("El código del dispositivo abre cuando la biometría está bloqueada")
    func passcodeFallback() async {
        let fake = FakeBiometrics(unlockResult: .failure(.biometryLockedOut))
        let lock = makeLock(fake)

        await lock.unlock()
        #expect(lock.state == .locked)

        await lock.unlockWithDevicePasscode()
        #expect(lock.state == .unlocked)
        #expect(lock.failedAttempts == 0)
        #expect(fake.passcodeCalls == 1)
    }

    @Test("Volver del background cierra la app otra vez")
    func relockOnBackground() async {
        let lock = makeLock(FakeBiometrics())
        await lock.unlock()
        #expect(lock.state == .unlocked)

        lock.lockIfNeeded()

        #expect(lock.state == .locked)
    }

    @Test("Con la preferencia apagada no se pide biometría")
    func disabledPreference() {
        let lock = makeLock(FakeBiometrics())
        lock.biometricsEnabled = false

        #expect(lock.state == .unlocked)
        #expect(!lock.requiresAuthentication)
    }

    @Test("Sin biometría disponible la app no se cierra en falso")
    func noBiometricsOnDevice() {
        let lock = makeLock(FakeBiometrics(biometry: .none, canUse: false))

        #expect(!lock.requiresAuthentication)
        #expect(!lock.biometryAvailable)
    }
}

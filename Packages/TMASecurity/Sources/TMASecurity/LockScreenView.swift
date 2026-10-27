import SwiftUI
import TMACore

/// Pantalla de bloqueo. Se muestra encima de toda la app y arranca el diálogo
/// de Face ID/Touch ID en cuanto aparece.
public struct LockScreenView: View {
    @Bindable private var lock: AppLockModel
    @State private var appeared = false

    public init(lock: AppLockModel) {
        self.lock = lock
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [TMATheme.accent.opacity(0.35), Color.black.opacity(0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()

                Image(systemName: lock.biometry.symbolName)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, options: .repeating.speed(0.4), value: lock.state == .unlocking)
                    .accessibilityHidden(true)

                VStack(spacing: 6) {
                    Text("trackMeAll")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Tus datos de salud, dinero y días en un solo lugar.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                if let error = lock.lastErrorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .transition(.opacity)
                }

                VStack(spacing: 10) {
                    Button {
                        Task { await lock.unlock() }
                    } label: {
                        HStack(spacing: 8) {
                            if lock.state == .unlocking {
                                ProgressView().tint(.black)
                            } else {
                                Image(systemName: lock.biometry.symbolName)
                            }
                            Text(lock.state == .unlocking ? "Autenticando…" : "Desbloquear")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(.black)
                    .disabled(lock.state == .unlocking)
                    .accessibilityLabel("Desbloquear con \(lock.biometry.displayName)")

                    Button("Usar código del dispositivo") {
                        Task { await lock.unlockWithDevicePasscode() }
                    }
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
                    .disabled(lock.state == .unlocking)
                }
                .padding(.horizontal, 28)

                if lock.failedAttempts >= 3 {
                    Text("Si la biometría está bloqueada, escribe el código del iPhone. Se reinicia al desbloquear el equipo con el código.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                }

                Spacer()

                Text(lock.biometryAvailable
                     ? "Protegido con \(lock.biometry.displayName)"
                     : "Este equipo no tiene biometría: la app queda abierta")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.bottom, 24)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: lock.lastErrorMessage)
        .task {
            guard !appeared else { return }
            appeared = true
            guard lock.requiresAuthentication, lock.state != .unlocked else { return }
            await lock.unlock()
        }
    }
}

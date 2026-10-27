import SwiftUI
import TMASecurity

@main
struct TrackMeAllApp: App {
    @State private var lock = AppLockModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView(lock: lock)

                if lock.requiresAuthentication && lock.state != .unlocked {
                    LockScreenView(lock: lock)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.18), value: lock.state)
            .onChange(of: scenePhase) { _, phase in
                // Se cierra al mandar la app al fondo: nadie ve datos ajenos
                // al volver a abrirla.
                if phase == .background {
                    lock.lockIfNeeded()
                }
            }
        }
    }
}

import Foundation
// ActivityKit aún no declara `Sendable` en sus tipos: se baja el chequeo estricto
// de aislamiento solo para este framework, no para el resto del paquete.
@preconcurrency import ActivityKit

/// Atributos de la Live Activity del "día en curso": minutos activos y app en foco.
/// El widget/Live Activity se dibuja en la extensión; aquí viven los datos.
public struct DayTrackerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var activeMinutes: Int
        public var focusApp: String
        public var lastPlace: String

        public init(activeMinutes: Int, focusApp: String, lastPlace: String) {
            self.activeMinutes = activeMinutes
            self.focusApp = focusApp
            self.lastPlace = lastPlace
        }
    }

    public var startedAt: Date

    public init(startedAt: Date = .now) {
        self.startedAt = startedAt
    }
}

/// Arranca, actualiza y cierra la Live Activity. Requiere
/// `NSSupportsLiveActivities = YES` en el Info.plist (ya está en project.yml).
@MainActor
public final class LiveActivityController {

    public enum LiveActivityError: Error, Sendable {
        case notEnabled
        case requestFailed(String)
    }

    private var activity: Activity<DayTrackerAttributes>?

    public init() {}

    public var isEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    public func start(startedAt: Date = .now,
                      initialState: DayTrackerAttributes.ContentState) throws(LiveActivityError) -> String {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            throw .notEnabled
        }
        do {
            let attributes = DayTrackerAttributes(startedAt: startedAt)
            let activity = try Activity<DayTrackerAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil
            )
            self.activity = activity
            return activity.id
        } catch {
            throw .requestFailed(error.localizedDescription)
        }
    }

    public func update(_ state: DayTrackerAttributes.ContentState) async {
        await activity?.update(ActivityContent(state: state, staleDate: nil))
    }

    /// Cierra la actividad. El estado final se publica con `update(_:)` antes de
    /// cerrar; `ActivityContent` no es `Sendable` en el SDK y pasarlo a `end`
    /// rompe el aislamiento estricto de Swift 6.
    public func end() async {
        await activity?.end(nil, dismissalPolicy: .immediate)
        activity = nil
    }
}

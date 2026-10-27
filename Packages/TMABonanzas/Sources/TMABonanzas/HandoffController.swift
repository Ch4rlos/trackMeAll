import Foundation
#if canImport(UIKit)
import UIKit
#endif
import TMACore

/// Handoff: la actividad que estaba abierta en el iPhone se puede retomar en el
/// iPad o la Mac. Requiere `NSUserActivityTypes` en el Info.plist (ya está en
/// project.yml) y la misma app firmada con el mismo equipo.
@MainActor
public final class HandoffController {

    public enum Section: String, Sendable, CaseIterable {
        case salud, finanzas, actividades, blog
    }

    public static let activityType = "com.carlosquiroga.trackmeall.section"

    #if canImport(UIKit)
    private var current: NSUserActivity?
    #endif

    public init() {}

    public func start(section: Section, detail: String? = nil) {
        #if canImport(UIKit)
        let activity = NSUserActivity(activityType: Self.activityType)
        activity.title = "trackMeAll · \(section.rawValue.capitalized)"
        activity.userInfo = ["section": section.rawValue, "detail": detail ?? ""]
        activity.isEligibleForHandoff = true
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.becomeCurrent()
        current = activity
        #endif
    }

    public func stop() {
        #if canImport(UIKit)
        current?.invalidate()
        current = nil
        #endif
    }
}

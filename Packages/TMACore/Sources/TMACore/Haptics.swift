import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Feedback táctil. En el simulador no se siente nada, en dispositivo sí.
@MainActor
public enum TMAHaptics {
    #if canImport(UIKit)
    public static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    public static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    public static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    public static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    #else
    public static func tap() {}
    public static func success() {}
    public static func warning() {}
    public static func error() {}
    #endif
}

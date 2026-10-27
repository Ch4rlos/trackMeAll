import Foundation
import AppIntents
import TMACore

// MARK: - Captura rápida desde Siri, Atajos y Spotlight

public struct RegistrarGastoIntent: AppIntent {
    public static let title: LocalizedStringResource = "Registrar un gasto"
    public static let description = IntentDescription(
        "Agrega un movimiento a Finanzas sin abrir la app.",
        categoryName: "Finanzas"
    )
    public static var openAppWhenRun: Bool { false }

    @Parameter(title: "Monto en pesos")
    public var monto: Double

    @Parameter(title: "Comercio")
    public var comercio: String

    @Parameter(title: "Categoría", default: "General")
    public var categoria: String

    public init() {}

    public init(monto: Double, comercio: String, categoria: String = "General") {
        self.monto = monto
        self.comercio = comercio
        self.categoria = categoria
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        // Etapa 1: no persiste; la captura real se conecta al store en la etapa 2.
        let formateado = TMATheme.currency(Decimal(monto))
        return .result(dialog: "Gasto de \(formateado) en \(comercio) anotado en \(categoria).")
    }
}

public struct RegistrarAnimoIntent: AppIntent {
    public static let title: LocalizedStringResource = "Registrar cómo me siento"
    public static let description = IntentDescription(
        "Anota tu estado de ánimo en Salud (equivalente a HKStateOfMind).",
        categoryName: "Salud"
    )

    public enum Animo: String, AppEnum {
        case muyBien, bien, neutral, bajo, muyBajo

        public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Ánimo")
        public static var caseDisplayRepresentations: [Animo: DisplayRepresentation] {
            [
                .muyBien: "Muy bien",
                .bien: "Bien",
                .neutral: "Neutral",
                .bajo: "Bajo",
                .muyBajo: "Muy bajo"
            ]
        }

        /// Valencia -1...1, igual que HKStateOfMind.
        public var valence: Double {
            switch self {
            case .muyBien: 1.0
            case .bien: 0.5
            case .neutral: 0.0
            case .bajo: -0.5
            case .muyBajo: -1.0
            }
        }
    }

    @Parameter(title: "Ánimo")
    public var animo: Animo

    @Parameter(title: "Nota")
    public var nota: String?

    public init() {}

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "Anotado: \(animo.rawValue) (valencia \(animo.valence)).")
    }
}

public struct AbrirSeccionIntent: AppIntent {
    public static let title: LocalizedStringResource = "Abrir una sección de trackMeAll"
    public static let description = IntentDescription("Abre Salud, Finanzas, Actividades o Blog.",
                                                      categoryName: "Navegación")
    public static var openAppWhenRun: Bool { true }

    public enum Seccion: String, AppEnum {
        case salud, finanzas, actividades, blog

        public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Sección")
        public static var caseDisplayRepresentations: [Seccion: DisplayRepresentation] {
            [
                .salud: "Salud",
                .finanzas: "Finanzas",
                .actividades: "Actividades",
                .blog: "Blog"
            ]
        }
    }

    @Parameter(title: "Sección")
    public var seccion: Seccion

    public init() {}
    public init(seccion: Seccion) { self.seccion = seccion }

    public func perform() async throws -> some IntentResult {
        .result()
    }
}

// MARK: - Frases para Siri y la app Atajos

public struct TrackMeAllShortcuts: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: RegistrarGastoIntent(),
            phrases: [
                "Registra un gasto en \(.applicationName)",
                "Anota un gasto en \(.applicationName)"
            ],
            shortTitle: "Registrar gasto",
            systemImageName: "creditcard"
        )
        AppShortcut(
            intent: RegistrarAnimoIntent(),
            phrases: ["Registra mi ánimo en \(.applicationName)"],
            shortTitle: "Registrar ánimo",
            systemImageName: "brain.head.profile"
        )
        AppShortcut(
            intent: AbrirSeccionIntent(),
            phrases: ["Abre \(\.$seccion) en \(.applicationName)"],
            shortTitle: "Abrir sección",
            systemImageName: "square.grid.2x2"
        )
    }
}

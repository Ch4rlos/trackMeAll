import SwiftUI
import WidgetKit
import TMACore

/// Widgets de pantalla de inicio y pantalla de bloqueo. El código vive aquí;
/// para publicarlos hace falta una extensión WidgetKit en el proyecto Xcode
/// (se agrega cuando haya cuenta de desarrollador y equipo de firma).
public struct SaludSummaryEntry: TimelineEntry {
    public let date: Date
    public let steps: Int
    public let goal: Int
    public let sleepHours: Double

    public init(date: Date = .now, steps: Int, goal: Int, sleepHours: Double) {
        self.date = date
        self.steps = steps
        self.goal = goal
        self.sleepHours = sleepHours
    }
}

public struct SaludSummaryProvider: TimelineProvider {
    public init() {}

    public func placeholder(in context: Context) -> SaludSummaryEntry {
        SaludSummaryEntry(steps: 6_400, goal: 10_000, sleepHours: 7.1)
    }

    public func getSnapshot(in context: Context, completion: @escaping (SaludSummaryEntry) -> Void) {
        let steps = MockData.healthMetrics().first { $0.kind == .steps }
        completion(SaludSummaryEntry(steps: 8_432, goal: 10_000, sleepHours: 6.9))
        _ = steps
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<SaludSummaryEntry>) -> Void) {
        let entry = SaludSummaryEntry(steps: 8_432, goal: 10_000, sleepHours: 6.9)
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

public struct SaludSummaryWidget: Widget {
    public let kind = "SaludSummaryWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SaludSummaryProvider()) { entry in
            VStack(alignment: .leading, spacing: 4) {
                Label("Pasos", systemImage: "figure.walk")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.steps.formatted())
                    .font(.title2.weight(.semibold))
                ProgressView(value: Double(entry.steps), total: Double(entry.goal))
                    .tint(TMATheme.accent)
                Text("Sueño \(entry.sleepHours, specifier: "%.1f") h")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Salud de hoy")
        .description("Pasos, meta y sueño de la noche anterior.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
    }
}

public struct FinanzasSummaryEntry: TimelineEntry {
    public let date: Date
    public let balance: Decimal
    public let monthSpend: Decimal

    public init(date: Date = .now, balance: Decimal, monthSpend: Decimal) {
        self.date = date
        self.balance = balance
        self.monthSpend = monthSpend
    }
}

public struct FinanzasSummaryProvider: TimelineProvider {
    public init() {}

    public func placeholder(in context: Context) -> FinanzasSummaryEntry {
        FinanzasSummaryEntry(balance: 18_420, monthSpend: 6_240)
    }

    public func getSnapshot(in context: Context, completion: @escaping (FinanzasSummaryEntry) -> Void) {
        completion(FinanzasSummaryEntry(balance: 18_420, monthSpend: 6_240))
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<FinanzasSummaryEntry>) -> Void) {
        let entry = FinanzasSummaryEntry(balance: 18_420, monthSpend: 6_240)
        let next = Calendar.current.date(byAdding: .hour, value: 3, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

public struct FinanzasSummaryWidget: Widget {
    public let kind = "FinanzasSummaryWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FinanzasSummaryProvider()) { entry in
            VStack(alignment: .leading, spacing: 4) {
                Label("Balance", systemImage: "creditcard")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(TMATheme.currency(entry.balance))
                    .font(.headline)
                Text("Gasto: \(TMATheme.currency(entry.monthSpend))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Finanzas")
        .description("Balance total y gasto registrado.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

public struct TrackMeAllWidgetBundle: WidgetBundle {
    public init() {}

    public var body: some Widget {
        SaludSummaryWidget()
        FinanzasSummaryWidget()
    }
}

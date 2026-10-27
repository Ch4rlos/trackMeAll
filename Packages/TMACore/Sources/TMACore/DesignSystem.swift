import SwiftUI

/// Lenguaje visual mínimo, nativo de iOS: nada de clip-art, tipografía del sistema,
/// color de acento único y tarjetas con material del sistema.
public enum TMATheme {
    public static let accent = Color(red: 0.10, green: 0.45, blue: 0.42)
    public static let positive = Color.green
    public static let negative = Color.red
    public static let muted = Color.secondary

    public static func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: value as NSDecimalNumber) ?? "—"
    }

    public static func minutes(_ value: Int) -> String {
        if value < 60 { return "\(value) min" }
        let hours = value / 60
        let rest = value % 60
        return rest == 0 ? "\(hours) h" : "\(hours) h \(rest) min"
    }

    public static func shortDate(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(Locale(identifier: "es_MX")))
    }

    public static func time(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute().locale(Locale(identifier: "es_MX")))
    }
}

/// Tarjeta base de toda la app.
public struct TMACard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// Fila valor/detalle reutilizable dentro de una tarjeta.
public struct TMAStatRow: View {
    public let title: String
    public let value: String
    public let detail: String?
    public let symbol: String

    public init(title: String, value: String, detail: String? = nil, symbol: String) {
        self.title = title
        self.value = value
        self.detail = detail
        self.symbol = symbol
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(TMATheme.accent)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).foregroundStyle(.secondary)
                Text(value).font(.headline)
                if let detail {
                    Text(detail).font(.footnote).foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

/// Encabezado de sección dentro de un scroll.
public struct TMASectionTitle: View {
    public let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}

/// Aviso para zonas del producto que Apple todavía no permite (o que van a backend).
public struct TMANotice: View {
    public let title: String
    public let message: String

    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    public var body: some View {
        TMACard {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(message).font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
    }
}

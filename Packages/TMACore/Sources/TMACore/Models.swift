import Foundation

// MARK: - Salud

/// Una lectura resumida que puede venir de HealthKit o de una fuente manual.
public struct HealthMetric: Identifiable, Sendable, Hashable {
    public enum Kind: String, Sendable, CaseIterable {
        case steps, heartRate, hrv, sleep, workout, vo2Max, nutrition, mindfulness
    }

    public let id: UUID
    public let kind: Kind
    public let title: String
    public let value: String
    public let detail: String
    public let date: Date

    public init(id: UUID = UUID(), kind: Kind, title: String, value: String, detail: String, date: Date) {
        self.id = id
        self.kind = kind
        self.title = title
        self.value = value
        self.detail = detail
        self.date = date
    }
}

/// Serie diaria para gráficas (Swift Charts).
public struct DailyMetric: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let date: Date
    public let label: String
    public let value: Double

    public init(id: UUID = UUID(), date: Date, label: String, value: Double) {
        self.id = id
        self.date = date
        self.label = label
        self.value = value
    }
}

/// Equivalente mock de `HKStateOfMind`: valencia -1...1 y etiquetas.
public struct MoodEntry: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let date: Date
    public let valence: Double
    public let labels: [String]
    public let note: String?

    public init(id: UUID = UUID(), date: Date, valence: Double, labels: [String], note: String? = nil) {
        self.id = id
        self.date = date
        self.valence = valence
        self.labels = labels
        self.note = note
    }
}

public struct NutritionDay: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let date: Date
    public let calories: Int
    public let proteinGrams: Int
    public let carbsGrams: Int
    public let fatGrams: Int
    public let waterLiters: Double

    public init(id: UUID = UUID(), date: Date, calories: Int, proteinGrams: Int,
                carbsGrams: Int, fatGrams: Int, waterLiters: Double) {
        self.id = id
        self.date = date
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.waterLiters = waterLiters
    }
}

// MARK: - Finanzas

public struct Transaction: Identifiable, Sendable, Hashable {
    /// De dónde salió el dato: la app nunca lee SMS; el correo y el OCR son las vías reales.
    public enum Source: String, Sendable, CaseIterable {
        case manual, gmail, ocr, csv
    }

    public let id: UUID
    public let merchant: String
    public let amount: Decimal
    public let date: Date
    public let category: String
    public let source: Source

    public init(id: UUID = UUID(), merchant: String, amount: Decimal, date: Date,
                category: String, source: Source) {
        self.id = id
        self.merchant = merchant
        self.amount = amount
        self.date = date
        self.category = category
        self.source = source
    }

    public var isExpense: Bool { amount < 0 }
    public var absoluteAmount: Decimal { amount < 0 ? -amount : amount }
}

public struct AccountSummary: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let name: String
    public let institution: String
    public let balance: Decimal
    public let lastSyncedAt: Date

    public init(id: UUID = UUID(), name: String, institution: String, balance: Decimal, lastSyncedAt: Date) {
        self.id = id
        self.name = name
        self.institution = institution
        self.balance = balance
        self.lastSyncedAt = lastSyncedAt
    }
}

// MARK: - Actividades

public struct AppUsage: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let appName: String
    public let category: String
    public let minutes: Int

    public init(id: UUID = UUID(), appName: String, category: String, minutes: Int) {
        self.id = id
        self.appName = appName
        self.category = category
        self.minutes = minutes
    }
}

public struct PlaceVisit: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let name: String
    public let arrivedAt: Date
    public let durationMinutes: Int
    public let latitude: Double
    public let longitude: Double

    public init(id: UUID = UUID(), name: String, arrivedAt: Date, durationMinutes: Int,
                latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.arrivedAt = arrivedAt
        self.durationMinutes = durationMinutes
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct AgendaEvent: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let title: String
    public let start: Date
    public let end: Date
    public let calendar: String

    public init(id: UUID = UUID(), title: String, start: Date, end: Date, calendar: String) {
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.calendar = calendar
    }
}

// MARK: - Blog

public struct BlogPost: Identifiable, Sendable, Hashable {
    public enum Status: String, Sendable, CaseIterable {
        case draft, scheduled, published
    }

    public let id: UUID
    public let title: String
    public let slug: String
    public let status: Status
    public let updatedAt: Date
    public let excerpt: String
    public let tags: [String]
    public let coverKey: String?

    public init(id: UUID = UUID(), title: String, slug: String, status: Status,
                updatedAt: Date, excerpt: String, tags: [String], coverKey: String? = nil) {
        self.id = id
        self.title = title
        self.slug = slug
        self.status = status
        self.updatedAt = updatedAt
        self.excerpt = excerpt
        self.tags = tags
        self.coverKey = coverKey
    }
}

/// Objeto en el bucket S3/R2. La app nunca sube credenciales: usa URLs prefirmadas.
public struct MediaAsset: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let key: String
    public let filename: String
    public let contentType: String
    public let byteSize: Int
    public let publicURL: URL?

    public init(id: UUID = UUID(), key: String, filename: String, contentType: String,
                byteSize: Int, publicURL: URL? = nil) {
        self.id = id
        self.key = key
        self.filename = filename
        self.contentType = contentType
        self.byteSize = byteSize
        self.publicURL = publicURL
    }
}

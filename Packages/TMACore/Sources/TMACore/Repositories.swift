import Foundation

/// Contratos de datos. En la etapa 1 los cumple `Mock*Repository`;
/// en la etapa 2 los cumple la implementación real (HealthKit, EventKit,
/// CoreLocation, DeviceActivity, Gmail API, R2).
public protocol HealthRepository: Sendable {
    func metrics() async throws -> [HealthMetric]
    func stepsLastWeek() async throws -> [DailyMetric]
    func moods() async throws -> [MoodEntry]
    func nutrition() async throws -> [NutritionDay]
}

public protocol FinanceRepository: Sendable {
    func accounts() async throws -> [AccountSummary]
    func transactions() async throws -> [Transaction]
}

public protocol ActivityRepository: Sendable {
    func appUsage() async throws -> [AppUsage]
    func visits() async throws -> [PlaceVisit]
    func agenda() async throws -> [AgendaEvent]
}

public protocol BlogRepository: Sendable {
    func posts() async throws -> [BlogPost]
    func media() async throws -> [MediaAsset]
    /// En la etapa 2: pide una URL prefirmada al backend y sube el archivo con PUT.
    func uploadURL(for filename: String) async throws -> URL
}

public enum RepositoryError: Error, Sendable {
    case notImplementedYet(String)
    case unavailable(String)
}

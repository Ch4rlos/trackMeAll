import Foundation

/// Implementaciones de la etapa 1: mismos contratos que tendrá la app real,
/// pero con datos locales. Cambiar a datos reales = inyectar otro repository.

private func mockDelay() async {
    try? await Task.sleep(for: .milliseconds(200))
}

public struct MockHealthRepository: HealthRepository {
    public init() {}
    public func metrics() async throws -> [HealthMetric] { await mockDelay(); return MockData.healthMetrics() }
    public func stepsLastWeek() async throws -> [DailyMetric] { await mockDelay(); return MockData.stepsLastWeek() }
    public func moods() async throws -> [MoodEntry] { await mockDelay(); return MockData.moods() }
    public func nutrition() async throws -> [NutritionDay] { await mockDelay(); return MockData.nutrition() }
}

public struct MockFinanceRepository: FinanceRepository {
    public init() {}
    public func accounts() async throws -> [AccountSummary] { await mockDelay(); return MockData.accounts() }
    public func transactions() async throws -> [Transaction] { await mockDelay(); return MockData.transactions() }
}

public struct MockActivityRepository: ActivityRepository {
    public init() {}
    public func appUsage() async throws -> [AppUsage] { await mockDelay(); return MockData.appUsage() }
    public func visits() async throws -> [PlaceVisit] { await mockDelay(); return MockData.visits() }
    public func agenda() async throws -> [AgendaEvent] { await mockDelay(); return MockData.agenda() }
}

public struct MockBlogRepository: BlogRepository {
    public init() {}
    public func posts() async throws -> [BlogPost] { await mockDelay(); return MockData.posts() }
    public func media() async throws -> [MediaAsset] { await mockDelay(); return MockData.media() }
    public func uploadURL(for filename: String) async throws -> URL {
        throw RepositoryError.notImplementedYet("URL prefirmada de R2 llega en la etapa 2 (\(filename))")
    }
}

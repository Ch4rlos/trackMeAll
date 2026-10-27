import Foundation
import Observation
import TMACore

@MainActor
@Observable
public final class SaludViewModel {
    public private(set) var metrics: [HealthMetric] = []
    public private(set) var steps: [DailyMetric] = []
    public private(set) var moods: [MoodEntry] = []
    public private(set) var nutrition: [NutritionDay] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let repository: any HealthRepository

    public init(repository: any HealthRepository = MockHealthRepository()) {
        self.repository = repository
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let metrics = repository.metrics()
            async let steps = repository.stepsLastWeek()
            async let moods = repository.moods()
            async let nutrition = repository.nutrition()
            self.metrics = try await metrics
            self.steps = try await steps
            self.moods = try await moods
            self.nutrition = try await nutrition
        } catch {
            errorMessage = "No se pudieron leer los datos de salud: \(error)"
        }
        isLoading = false
    }

    /// HealthKit real (etapa 2) pedirá permiso por tipo; aquí solo se declara el plan.
    public var pendingIntegrations: [String] {
        ["HealthKit: workouts, FC, HRV, sueño, VO₂ máx",
         "HKStateOfMind para salud mental (iOS 18+)",
         "Datos de nutrición: manual o API externa"]
    }
}

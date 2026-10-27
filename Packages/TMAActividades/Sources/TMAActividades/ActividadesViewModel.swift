import Foundation
import Observation
import TMACore

@MainActor
@Observable
public final class ActividadesViewModel {
    public private(set) var usage: [AppUsage] = []
    public private(set) var visits: [PlaceVisit] = []
    public private(set) var agenda: [AgendaEvent] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let repository: any ActivityRepository

    public init(repository: any ActivityRepository = MockActivityRepository()) {
        self.repository = repository
    }

    public var maxUsageMinutes: Int {
        max(usage.map(\.minutes).max() ?? 1, 1)
    }

    public var screenTimeTotal: Int {
        usage.reduce(0) { $0 + $1.minutes }
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let usage = repository.appUsage()
            async let visits = repository.visits()
            async let agenda = repository.agenda()
            self.usage = try await usage
            self.visits = try await visits
            self.agenda = try await agenda
        } catch {
            errorMessage = "No se pudieron leer las actividades: \(error)"
        }
        isLoading = false
    }
}

import Testing
import Foundation
@testable import TMACore

@Suite("Mock data y contratos")
struct MockDataTests {

    @Test("Los mocks de salud tienen datos de Watch, alimentación y mente")
    func healthMocks() {
        let metrics = MockData.healthMetrics()
        #expect(metrics.count >= 8)
        #expect(metrics.contains { $0.kind == .heartRate })
        #expect(metrics.contains { $0.kind == .nutrition })
        #expect(metrics.contains { $0.kind == .mindfulness })
        #expect(!MockData.moods().isEmpty)
        #expect(MockData.stepsLastWeek().count == 7)
    }

    @Test("Los mocks de finanzas distinguen ingreso de gasto")
    func financeMocks() {
        let transactions = MockData.transactions()
        #expect(transactions.contains { $0.isExpense })
        #expect(transactions.contains { !$0.isExpense })
        #expect(transactions.allSatisfy { !$0.category.isEmpty })
    }

    @Test("Actividades cubre uso de apps, lugares y agenda")
    func activityMocks() {
        #expect(!MockData.appUsage().isEmpty)
        #expect(!MockData.visits().isEmpty)
        #expect(!MockData.agenda().isEmpty)
    }

    @Test("El blog trae estados y assets de R2/S3")
    func blogMocks() {
        let posts = MockData.posts()
        #expect(posts.contains { $0.status == .draft })
        #expect(posts.contains { $0.status == .published })
        #expect(MockData.media().allSatisfy { !$0.key.isEmpty })
    }

    @Test("El formateo de moneda y minutos es estable")
    func formatting() {
        #expect(TMATheme.minutes(95) == "1 h 35 min")
        #expect(TMATheme.minutes(45) == "45 min")
        #expect(TMATheme.minutes(120) == "2 h")
    }
}

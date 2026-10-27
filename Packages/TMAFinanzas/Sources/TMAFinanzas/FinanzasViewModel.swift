import Foundation
import Observation
import TMACore

@MainActor
@Observable
public final class FinanzasViewModel {
    public private(set) var accounts: [AccountSummary] = []
    public private(set) var transactions: [Transaction] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let repository: any FinanceRepository

    public init(repository: any FinanceRepository = MockFinanceRepository()) {
        self.repository = repository
    }

    public var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }

    public var monthSpend: Decimal {
        transactions
            .filter { $0.isExpense }
            .reduce(0) { $0 + $1.absoluteAmount }
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let accounts = repository.accounts()
            async let transactions = repository.transactions()
            self.accounts = try await accounts
            self.transactions = try await transactions
        } catch {
            errorMessage = "No se pudieron leer las finanzas: \(error)"
        }
        isLoading = false
    }

    public func sourceLabel(for source: Transaction.Source) -> String {
        switch source {
        case .manual: "Manual"
        case .gmail: "Correo"
        case .ocr: "OCR"
        case .csv: "CSV"
        }
    }
}

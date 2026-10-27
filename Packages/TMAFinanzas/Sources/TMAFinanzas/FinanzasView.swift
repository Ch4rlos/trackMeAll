import SwiftUI
import TMACore

@MainActor
public struct FinanzasView: View {
    @State private var viewModel = FinanzasViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    TMACard {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Balance total").font(.subheadline).foregroundStyle(.secondary)
                            Text(TMATheme.currency(viewModel.totalBalance)).font(.largeTitle.weight(.semibold))
                            Text("Gasto registrado: \(TMATheme.currency(viewModel.monthSpend))")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    }

                    TMASectionTitle("Cuentas")
                    ForEach(viewModel.accounts) { account in
                        TMACard {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(account.name).font(.headline)
                                    Text(account.institution).font(.footnote).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(TMATheme.currency(account.balance))
                                    .font(.headline)
                                    .foregroundStyle(account.balance < 0 ? TMATheme.negative : .primary)
                            }
                        }
                    }

                    TMASectionTitle("Movimientos")
                    ForEach(viewModel.transactions) { movement in
                        TMACard {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: movement.isExpense ? "arrow.down.left" : "arrow.up.right")
                                    .foregroundStyle(movement.isExpense ? TMATheme.negative : TMATheme.positive)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(movement.merchant).font(.subheadline.weight(.semibold))
                                    Text("\(movement.category) · \(TMATheme.shortDate(movement.date)) · \(viewModel.sourceLabel(for: movement.source))")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(TMATheme.currency(movement.amount)).font(.subheadline.weight(.medium))
                            }
                        }
                    }

                    TMANotice(title: "Alcance real de Finanzas",
                              message: "iOS no permite leer SMS ni el historial de Wallet. Las vías viables son: correo bancario por Gmail API, captura con OCR on-device y CSV. Apple Card/Cash exige el entitlement gestionado de FinanceKit con cuenta de organización.")
                }
                .padding(16)
            }
            .navigationTitle("Finanzas")
            .refreshable { await viewModel.load() }
            .overlay {
                if viewModel.isLoading && viewModel.accounts.isEmpty { ProgressView() }
            }
            .task { await viewModel.load() }
        }
    }
}

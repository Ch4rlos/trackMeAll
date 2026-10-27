import SwiftUI
import Charts
import TMACore

@MainActor
public struct SaludView: View {
    @State private var viewModel = SaludViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    if let error = viewModel.errorMessage {
                        TMANotice(title: "Error", message: error)
                    }

                    TMASectionTitle("Últimos 7 días")
                    TMACard {
                        Chart(viewModel.steps) { metric in
                            BarMark(
                                x: .value("Día", metric.label),
                                y: .value("Pasos", metric.value)
                            )
                            .foregroundStyle(TMATheme.accent.gradient)
                            .cornerRadius(6)
                        }
                        .frame(height: 160)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                    }

                    TMASectionTitle("Hoy")
                    ForEach(viewModel.metrics) { metric in
                        TMACard {
                            TMAStatRow(title: metric.title,
                                       value: metric.value,
                                       detail: metric.detail,
                                       symbol: symbol(for: metric.kind))
                        }
                    }

                    TMASectionTitle("Salud mental")
                    ForEach(viewModel.moods) { mood in
                        TMACard {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(mood.valence >= 0 ? "Ánimo positivo" : "Ánimo bajo")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(TMATheme.shortDate(mood.date))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(mood.labels.joined(separator: " · "))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                if let note = mood.note {
                                    Text(note).font(.footnote)
                                }
                            }
                        }
                    }

                    TMASectionTitle("Alimentación")
                    ForEach(viewModel.nutrition) { day in
                        TMACard {
                            TMAStatRow(title: TMATheme.shortDate(day.date),
                                       value: "\(day.calories) kcal",
                                       detail: "P \(day.proteinGrams) g · C \(day.carbsGrams) g · G \(day.fatGrams) g · Agua \(String(format: "%.1f", day.waterLiters)) L",
                                       symbol: "fork.knife")
                        }
                    }

                    TMANotice(title: "Etapa 1 · datos mock",
                              message: "HealthKit real requiere permisos por tipo y un dispositivo que genere datos. El simulador no produce lecturas del Watch.")
                }
                .padding(16)
            }
            .navigationTitle("Salud")
            .refreshable { await viewModel.load() }
            .overlay {
                if viewModel.isLoading && viewModel.metrics.isEmpty {
                    ProgressView()
                }
            }
            .task { await viewModel.load() }
        }
    }

    private func symbol(for kind: HealthMetric.Kind) -> String {
        switch kind {
        case .steps: "figure.walk"
        case .heartRate: "heart.fill"
        case .hrv: "waveform.path.ecg"
        case .sleep: "bed.double.fill"
        case .workout: "dumbbell.fill"
        case .vo2Max: "lungs.fill"
        case .nutrition: "fork.knife"
        case .mindfulness: "brain.head.profile"
        }
    }
}

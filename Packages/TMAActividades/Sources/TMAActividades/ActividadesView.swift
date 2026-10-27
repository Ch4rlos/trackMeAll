import SwiftUI
import TMACore

@MainActor
public struct ActividadesView: View {
    @State private var viewModel = ActividadesViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    TMASectionTitle("Uso de apps")
                    TMACard {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Total hoy").font(.subheadline).foregroundStyle(.secondary)
                                Spacer()
                                Text(TMATheme.minutes(viewModel.screenTimeTotal)).font(.headline)
                            }
                            ForEach(viewModel.usage) { app in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(app.appName).font(.subheadline.weight(.medium))
                                        Spacer()
                                        Text(TMATheme.minutes(app.minutes)).font(.caption).foregroundStyle(.secondary)
                                    }
                                    ProgressView(value: Double(app.minutes),
                                                 total: Double(viewModel.maxUsageMinutes))
                                        .tint(TMATheme.accent)
                                    Text(app.category).font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    TMASectionTitle("Dónde he estado")
                    ForEach(viewModel.visits) { visit in
                        TMACard {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(TMATheme.accent)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(visit.name).font(.subheadline.weight(.semibold))
                                    Text("Llegada \(TMATheme.time(visit.arrivedAt)) · \(TMATheme.minutes(visit.durationMinutes))")
                                        .font(.caption).foregroundStyle(.secondary)
                                    Text(String(format: "%.4f, %.4f", visit.latitude, visit.longitude))
                                        .font(.caption2).foregroundStyle(.tertiary)
                                }
                                Spacer()
                            }
                        }
                    }

                    TMASectionTitle("Agenda")
                    ForEach(viewModel.agenda) { event in
                        TMACard {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "calendar")
                                    .foregroundStyle(TMATheme.accent)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title).font(.subheadline.weight(.semibold))
                                    Text("\(TMATheme.shortDate(event.start)) · \(TMATheme.time(event.start))-\(TMATheme.time(event.end)) · \(event.calendar)")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }

                    TMANotice(title: "Permisos que pedirá la etapa 2",
                              message: "DeviceActivity + Family Controls para uso de apps (entitlement), visit monitoring de CoreLocation para lugares y EventKit para la agenda. Sin esos permisos, esta sección corre con mocks.")
                }
                .padding(16)
            }
            .navigationTitle("Actividades")
            .refreshable { await viewModel.load() }
            .overlay {
                if viewModel.isLoading && viewModel.usage.isEmpty { ProgressView() }
            }
            .task { await viewModel.load() }
        }
    }
}

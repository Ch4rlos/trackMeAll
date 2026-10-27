import SwiftUI
import TMACore
import TMASecurity

struct SettingsView: View {
    @Bindable var lock: AppLockModel

    @State private var keychainResult: String?
    @State private var isTestingKeychain = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $lock.biometricsEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pedir \(lock.biometry.displayName) al abrir")
                            Text(lock.biometryAvailable
                                 ? "Al volver del fondo la app se cierra sola."
                                 : "Este equipo no tiene biometría disponible.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(!lock.biometryAvailable)

                    Button {
                        lock.lock()
                        TMAHaptics.tap()
                    } label: {
                        Label("Bloquear ahora", systemImage: "lock.fill")
                    }
                    .disabled(!lock.biometricsEnabled)
                } header: {
                    Text("Seguridad")
                } footer: {
                    Text("Face ID / Touch ID los evalúa el sistema: la app nunca ve tu rostro ni tu huella. El código del dispositivo sirve como respaldo cuando la biometría se bloquea.")
                }

                Section {
                    Button {
                        Task { await testKeychain() }
                    } label: {
                        HStack {
                            Label("Probar Keychain protegido", systemImage: "key.fill")
                            Spacer()
                            if isTestingKeychain { ProgressView() }
                        }
                    }
                    .disabled(isTestingKeychain)

                    if let keychainResult {
                        Text(keychainResult)
                            .font(.caption)
                            .foregroundStyle(keychainResult.hasPrefix("OK") ? Color.green : Color.orange)
                    }
                } header: {
                    Text("Keychain")
                } footer: {
                    Text("Escribe un nonce con política `biometryCurrentSet`: si agregas o borras un rostro/huella, el item se invalida y hay que volver a guardarlo.")
                }

                Section("Ecosistema Apple") {
                    IntegrationRow(name: "Siri y Atajos", detail: "App Intents + frases en español", status: .ready)
                    IntegrationRow(name: "Spotlight", detail: "Indexa las publicaciones del blog", status: .ready)
                    IntegrationRow(name: "Handoff", detail: "Retoma la sección en otro equipo", status: .ready)
                    IntegrationRow(name: "Keychain biométrico", detail: "Secretos atados a tu biometría", status: .ready)
                    IntegrationRow(name: "Widgets", detail: "Salud y Finanzas en pantalla de inicio", status: .needsExtension)
                    IntegrationRow(name: "Live Activities", detail: "Día en curso en la Dynamic Island", status: .needsExtension)
                    IntegrationRow(name: "HealthKit", detail: "Watch, alimentación y ánimo", status: .needsSigning)
                    IntegrationRow(name: "Uso de apps", detail: "DeviceActivity + Family Controls", status: .needsEntitlement)
                }

                Section("Acerca de") {
                    LabeledContent("Versión", value: "0.1.0 (prototipo)")
                    LabeledContent("Datos", value: "mock, sin permisos")
                    LabeledContent("Arquitectura", value: "MVVM + @Observable")
                }
            }
            .navigationTitle("Ajustes")
        }
    }

    private func testKeychain() async {
        isTestingKeychain = true
        defer { isTestingKeychain = false }

        let nonce = UUID().uuidString
        do {
            try lock.storeSecret(Data(nonce.utf8), account: "diagnostics.nonce")
            let stored = try lock.readSecret(account: "diagnostics.nonce")
            let roundTrip = String(data: stored, encoding: .utf8)
            keychainResult = roundTrip == nonce ? "OK · nonce guardado y leído" : "Falló: no coincide"
            TMAHaptics.success()
        } catch {
            keychainResult = "Error: \(error.message)"
            TMAHaptics.error()
        }
    }
}

private struct IntegrationRow: View {
    enum Status {
        case ready, needsExtension, needsSigning, needsEntitlement

        var label: String {
            switch self {
            case .ready: "Listo"
            case .needsExtension: "Requiere extensión"
            case .needsSigning: "Requiere firma"
            case .needsEntitlement: "Requiere permiso de Apple"
            }
        }

        var color: Color {
            switch self {
            case .ready: .green
            case .needsExtension: .blue
            case .needsSigning: .orange
            case .needsEntitlement: .red
            }
        }
    }

    let name: String
    let detail: String
    let status: Status

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline.weight(.medium))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(status.label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(status.color)
        }
    }
}

#Preview {
    SettingsView(lock: AppLockModel())
}

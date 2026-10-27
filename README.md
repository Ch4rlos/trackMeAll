# trackMeAll

App iOS personal para concentrar cuatro frentes en un solo lugar: **Salud**, **Finanzas**,
**Actividades** y **Blog**. SwiftUI + MVVM + `@Observable`, un paquete SPM por sección,
datos mock en la etapa 1.

- **Xcode**: 26.6 (arm64) · **iOS mínimo**: 18.0 · **Swift**: 6.0 (modo estricto)
- **Arquitectura**: MVVM con `@Observable`, `Repository` por dominio y `MockRepository` inyectable
- **Licencia**: MIT

## Estructura

```
App/
  TrackMeAllApp.swift      # arranque, bloqueo por biometría, auto-lock en background
  RootTabView.swift        # 5 pestañas: Salud, Finanzas, Actividades, Blog, Ajustes
  SettingsView.swift       # seguridad, prueba de Keychain, estado de integraciones
  Info.plist               # generado por XcodeGen (no se versiona)
Packages/
  TMACore/                 # modelos, protocolos Repository, MockData, design system, hápticos, tests
  TMASalud/                # HealthKit: Watch, alimentación, salud mental
  TMAFinanzas/             # cuentas y movimientos (correo, OCR, CSV)
  TMAActividades/          # uso de apps, lugares, agenda
  TMABlog/                 # publicaciones y multimedia (R2/S3)
  TMASecurity/             # LocalAuthentication, Keychain biométrico, pantalla de bloqueo
  TMABonanzas/             # App Intents, Spotlight, Handoff, Live Activity, widgets
```

El `.xcodeproj` y el `Info.plist` **no se versionan**: se generan.

```bash
brew install xcodegen
xcodegen generate
open trackMeAll.xcodeproj
```

## Estado de verificación

| Qué | Cómo se verificó |
|---|---|
| Los 7 paquetes compilan | `swiftc -emit-module` con Swift 6 contra `iPhoneSimulator26.5.sdk` |
| El target de app compila | `swiftc -typecheck` de `App/*.swift` con los 7 módulos |
| Cero warnings en los paquetes nuevos | conteo de `warning:` en la salida del compilador |
| Ejecutar en simulador | **pendiente**: falta el componente "iOS 26.5 platform" en Xcode |
| Biometría real, Keychain, widgets, Live Activity | **pendiente**: requieren dispositivo/simulador con runtime |

## Seguridad biométrica

- `BiometricAuthenticator` (LocalAuthentication) detecta Face ID / Touch ID / Optic ID y
  distingue cancelación, bloqueo por intentos y falta de enrolamiento.
- `AppLockModel` bloquea al volver del background y cae al código del dispositivo cuando
  la biometría se bloquea.
- `KeychainStore` guarda secretos con `biometryCurrentSet`: si se agrega o borra un
  rostro/huella, el item se invalida. La app nunca ve tu rostro ni tu huella.
- Ajustes tiene un botón de diagnóstico que hace round-trip de un nonce en el Keychain.

## Ecosistema Apple

| Integración | Estado | Requisito |
|---|---|---|
| Siri y Atajos (App Intents) | código listo | ninguno |
| Spotlight (indexa blog) | código listo | ninguno |
| Handoff | código listo | `NSUserActivityTypes` (ya en `project.yml`) |
| Keychain biométrico | código listo | dispositivo con biometría |
| Widgets (Salud, Finanzas) | código listo | extensión WidgetKit en el proyecto |
| Live Activities | código listo | extensión + `NSSupportsLiveActivities` |
| HealthKit | por implementar | firma con Apple ID/equipo |
| DeviceActivity / Family Controls | por implementar | entitlement aprobado por Apple |

## Alcance real por sección

| Sección | Etapa 1 (mock) | Etapa 2 (datos reales) | Bloqueo |
|---|---|---|---|
| Salud | 8 métricas, serie de pasos, ánimo, nutrición | HealthKit (`HKQuantityType`, `HKWorkout`, `HKStateOfMind`) | El simulador no genera datos del Watch: requiere iPhone |
| Finanzas | cuentas + movimientos con origen | Gmail API (correo bancario), OCR on-device (Vision), CSV | **SMS: imposible** (sin API pública). **Wallet/Apple Card**: FinanceKit exige entitlement gestionado y cuenta a nivel organización |
| Actividades | uso de apps, visitas, agenda | DeviceActivity + Family Controls, CoreLocation visit monitoring, EventKit | Family Controls requiere entitlement; uso individual funciona en build propio |
| Blog | posts con estado + assets R2 | API de publicación + URLs prefirmadas a R2 (compatible S3) | Ninguno técnico: depende del backend del sitio |

## Reglas del proyecto

- La app **nunca** maneja credenciales de servicios: las firmas viajan al backend.
- Nada de leer SMS ni APIs privadas.
- Toda sección nueva entra con su `Repository` + `MockRepository` + tests antes de tocar datos reales.
- `trackMeAll` es nombre de trabajo del prototipo.

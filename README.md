# trackMeAll

App iOS personal para concentrar cuatro frentes en un solo lugar: **Salud**, **Finanzas**,
**Actividades** y **Blog**. SwiftUI + MVVM + `@Observable`, un paquete SPM por sección,
datos mock en la etapa 1.

- **Xcode**: 26.6 (arm64) · **iOS mínimo**: 18.0 · **Swift**: 6.0
- **Arquitectura**: MVVM con `@Observable`, `Repository` por dominio y `MockRepository` inyectable
- **Licencia**: MIT

## Estructura

```
App/                       # arranque y TabView (4 pestañas)
Packages/
  TMACore/                 # modelos, protocolos Repository, MockData, design system, tests
  TMASalud/                # HealthKit: Watch, alimentación, salud mental
  TMAFinanzas/             # cuentas y movimientos (correo, OCR, CSV)
  TMAActividades/          # uso de apps, lugares, agenda
  TMABlog/                 # publicaciones y multimedia (R2/S3)
project.yml                # definición del proyecto para XcodeGen
```

El `.xcodeproj` **no se versiona**: se genera.

```bash
brew install xcodegen
xcodegen generate
open trackMeAll.xcodeproj
```

Build por CLI:

```bash
xcodebuild -project trackMeAll.xcodeproj -scheme trackMeAll \
  -destination 'generic/platform=iOS Simulator' build
```

Tests de los mocks:

```bash
xcodebuild test -scheme TMACore -destination 'platform=iOS Simulator,name=iPhone 17'
```

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

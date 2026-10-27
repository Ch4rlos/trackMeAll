# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).
Versionado semántico mientras sea prototipo: `0.x`.

## [0.1.0] — 2026-10-27

Primera entrega del prototipo. Todo con datos mock; ninguna API del sistema activada.

### Agregado

- **Arquitectura**: 7 paquetes SwiftPM (`TMACore`, `TMASalud`, `TMAFinanzas`,
  `TMAActividades`, `TMABlog`, `TMASecurity`, `TMABonanzas`) con regla de no dependencia
  entre secciones.
- **App**: `TabView` de cinco pestañas (Salud, Finanzas, Actividades, Blog, Ajustes) y
  `App` con bloqueo biométrico encima de toda la UI.
- **Salud**: métricas de Watch, serie de pasos con Swift Charts, ánimo (`HKStateOfMind`
  modelado) y nutrición, sobre datos mock.
- **Finanzas**: cuentas, balance total, movimientos con origen (`manual`, `correo`, `OCR`,
  `CSV`) y aviso explícito del alcance real de Wallet/SMS.
- **Actividades**: uso de apps con barras, visitas a lugares y agenda.
- **Blog**: publicaciones por estado y assets de R2/S3 con metadatos.
- **Seguridad**: `BiometricEvaluating` (Face ID / Touch ID / Optic ID), `AppLockModel`
  con auto-bloqueo al pasar a background, `KeychainStore` con `biometryCurrentSet` y
  `LockScreenView`.
- **Ecosistema**: App Intents con frases en español, `SpotlightIndexer`,
  `HandoffController`, Live Activity del día en curso y widgets de Salud/Finanzas.
- **Tooling**: `project.yml` para XcodeGen, `Info.plist` generado con las descripciones de
  uso, CI en macOS, script de capturas automatizadas.

### Verificado

- 12 tests ejecutados en macOS (`swift test`): 5 de dominio y 7 de la máquina de estados
  del bloqueo.
- Los 7 paquetes y el target de app compilan sin errores ni warnings con Swift 6 contra el
  SDK `iPhoneSimulator26.5`.
- CI en GitHub Actions: ambos jobs en verde (`Tests de dominio` y `Build de la app`), con
  `BUILD SUCCEEDED` sobre un simulador iPhone 17 Pro.

### Pendiente

- Ejecución en simulador (requiere el componente *iOS platform* en Xcode).
- Validación en dispositivo de biometría, Keychain, widgets y Live Activity.
- Persistencia con SwiftData y `FileProtection`.

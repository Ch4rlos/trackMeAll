# trackMeAll — reglas para agentes

App iOS personal: Salud, Finanzas, Actividades y Blog. SwiftUI + MVVM + `@Observable`,
un paquete SwiftPM por dominio. Repo privado hoy; su destino es **público y carta de
presentación**, así que la calidad es de portafolio.

## Estructura

```
App/                 target de app (TrackMeAllApp, RootTabView, SettingsView)
Package.swift        manifiesto raiz: publica los 7 modulos como productos SPM
Packages/
  TMACore/           modelos, Repository protocols, MockData, design system, tests
  TMASalud/          HealthKit (etapa 2)
  TMAFinanzas/       finanzas (entrada manual / Gmail / OCR)
  TMAActividades/    DeviceActivity, CoreLocation, EventKit
  TMABlog/           publicaciones + assets R2/S3
  TMASecurity/       biometría (LocalAuthentication) + Keychain
  TMABonanzas/       App Intents, Spotlight, Handoff, Live Activity, widgets
docs/                ARQUITECTURA, DECISIONES (ADR), ALCANCE-APPLE, DISPOSITIVO, CAPTURAS
```

Regla dura: **los paquetes de sección no se importan entre sí.** Lo compartido va en
`TMACore`.

`Package.swift` en la raíz no es opcional: SwiftPM solo lee el manifiesto de la raíz de un
repo remoto, y sin él ningún otro proyecto puede depender de `TMACore` por URL y tag. Si
agregas un módulo, decláralo también ahí.

## Build y verificación

```bash
export DEVELOPER_DIR=/Applications/Xcode-26.6.0.app/Contents/Developer
cd ~/dev/trackMeAll && xcodegen generate      # el .xcodeproj NO se versiona

# tests (corren en macOS, sin simulador)
swift test --package-path Packages/TMACore
swift test --package-path Packages/TMASecurity

# build de la app (dispositivo; no requiere runtime de simulador)
xcodebuild -project trackMeAll.xcodeproj -scheme trackMeAll \
  -destination 'generic/platform=iOS' -derivedDataPath /tmp/dd \
  CODE_SIGNING_ALLOWED=NO build

# CI
gh run list --limit 3
```

En esta Mac el runtime de simulador iOS 26.5 **sí está instalado**: se puede compilar,
arrancar y capturar pantalla. El shell de herramientas no hereda `DEVELOPER_DIR` de
`~/.zshrc`, así que expórtalo o `xcrun` no encuentra `simctl`. Escalera completa de
verificación: skill `ios-verificar-sin-simulador`.

## Reglas de trabajo

- No digas "funciona" sin salida real de herramienta. Lo no ejecutado se declara NO VALIDADO.
- Mock data en la etapa 1. Nada de credenciales ni endpoints reales en el repo.
- Secretos en `.env`, nunca en el código ni en docs.
- `.xcodeproj` e `App/Info.plist` son generados: no se commitean.
- Commits en español, imperativo, asunto sin acentos.
- Cambios de alcance o de arquitectura → ADR en `docs/DECISIONES.md`.

## Fronteras

Este repo es de **desarrollo de producto**. Firmas, componentes de Xcode, disco, respaldos
y otros proyectos son del perfil **willy** (sysadmin). Quien trabaje aquí no usa `sudo`,
no instala nada del sistema, no toca credenciales y no crea repos públicos sin aprobación.

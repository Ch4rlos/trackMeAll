# Decisiones (ADR)

Registro corto de las decisiones que no se explican solas. Formato: contexto → decisión →
lo que se gana y lo que se paga.

---

## ADR-001 · MVVM con `@Observable` en lugar de VIPER o TCA

**Contexto.** Proyecto de una sola persona, SwiftUI, cuatro dominios independientes,
muchas pantallas de lectura (paneles) y pocas de flujo complejo.

**Decisión.** MVVM con `@Observable` (Observation framework) y `Repository` por dominio.

**Por qué.**
- VIPER nació para UIKit: interactor/presenter/router por pantalla. En SwiftUI el árbol de
  vistas ya es el router y el binding es el presentador; VIPER deja 5 archivos por pantalla
  con la mitad vacíos. Con un solo desarrollador, la ceremonia se paga sin interés.
- TCA (The Composable Architecture, pointfree) es una gran opción y muy activa (≈15k ★),
  pero impone su propio modelo mental (State/Action/Reducer) y una dependencia externa
  grande para un prototipo que todavía define alcance.
- `@Observable` elimina `ObservableObject`/`@Published` y da observación por propiedad:
  menos invalidaciones de vista, menos código.

**Se paga.** Si el equipo crece a 4+ personas o el flujo de navegación se vuelve profundo,
el router explícito se echará de menos. La migración a TCA es posible porque los
ViewModel no conocen la vista.

---

## ADR-002 · Un paquete SwiftPM por dominio

**Contexto.** Cuatro áreas que crecen con ritmos distintos; dos de ellas dependen de
frameworks con permisos especiales (HealthKit, DeviceActivity).

**Decisión.** `Packages/TMACore`, `TMASalud`, `TMAFinanzas`, `TMAActividades`, `TMABlog`,
más dos transversales (`TMASecurity`, `TMABonanzas`).

**Por qué.** El compilador hace cumplir la separación: si `TMAFinanzas` intenta importar
`TMASalud`, no compila. Los tests corren por paquete, no por app. Y los frameworks con
permiso quedan aislados: si Apple rechaza el entitlement de `DeviceActivity`, solo se
desactiva `TMAActividades`.

**Se paga.** Más `Package.swift` y builds incrementales un poco más lentos.

---

## ADR-003 · El `.xcodeproj` no se versiona (XcodeGen)

**Problema que evita.** Los conflictos de merge en `project.pbxproj` son el ruido más caro
de cualquier repo iOS.

**Decisión.** `project.yml` es la fuente de verdad; `xcodegen generate` produce el proyecto
y el `Info.plist`. Ambos van en `.gitignore`.

**Se paga.** Un paso extra en el *onboarding* (`brew install xcodegen`). Se documenta en el
README.

---

## ADR-004 · `info:` de XcodeGen en lugar de `GENERATE_INFOPLIST_FILE`

**Contexto.** `NSUserActivityTypes` es un arreglo y las claves `INFOPLIST_KEY_*` solo
admiten escalares.

**Decisión.** Generar el plist completo desde `project.yml` con `info:`.

**Se gana.** Un solo lugar para todas las descripciones de uso (Face ID, HealthKit,
ubicación, calendario, movimiento) y soporte de arreglos.

---

## ADR-005 · `@preconcurrency import ActivityKit` acotado

**Contexto.** Con Swift 6 en modo estricto, `ActivityContent` no es `Sendable` y pasarlo a
`Activity.end(_:dismissalPolicy:)` es un error de compilación (`SendingRisksDataRace`).

**Decisión.** Bajar el chequeo **solo en el archivo de Live Activity**
(`@preconcurrency import ActivityKit`) y no exponer una API que pase `ActivityContent`
entre dominios de aislamiento: `end()` cierra sin estado final y el estado final se publica
con `update(_:)` antes.

**Por qué no `unsafe`.** No se silencia el chequeo de todo el paquete ni se marca `Activity`
como `@unchecked Sendable`; el riesgo queda confinado a una llamada.

---

## ADR-006 · macOS declarado en `TMACore` y `TMASecurity`

**Contexto.** Sin el componente *iOS platform* de Xcode no hay simulador, y los tests no
podían ejecutarse.

**Decisión.** Declarar `.macOS(.v14)` en esos dos paquetes para poder correr `swift test`
en el host. La app sigue siendo exclusivamente iOS.

**Se gana.** 12 tests reales corriendo en CI y en local, sin simulador. Detecta regresiones
de lógica de dominio y de la máquina de estados del bloqueo.

**Se paga.** Hay que cuidar que el código de esos dos paquetes no use APIs solo-iOS.
`TMAHaptics` ya está protegido con `#if canImport(UIKit)`.

---

## ADR-007 · Datos mock como camino de primera clase

**Contexto.** El backend no existe y varias APIs del sistema requieren permisos que no se
pueden garantizar durante el desarrollo.

**Decisión.** `MockRepository` no es un stub temporal: es una implementación completa del
protocolo, con formas reales y retardos, y se queda para demos y tests.

**Se gana.** Se puede enseñar y probar el producto entero sin cuenta de desarrollador ni
datos personales. Cambiar a datos reales es inyectar otro `Repository`.

---

## ADR-008 · Límites de plataforma documentados, no disimulados

**Contexto.** Tres requisitos del producto no son alcanzables con APIs públicas: leer SMS,
historial completo de Wallet, y uso de apps sin entitlement.

**Decisión.** Documentarlos en `docs/ALCANCE-APPLE.md` con la cita de Apple, y ofrecer el
sustituto viable para cada uno (correo/OCR/CSV; FinanceKit solo para productos Apple;
Family Controls con entitlement).

**Por qué.** Un prototipo que promete lo imposible se cae en la primera demo técnica.
Documentar el límite y el plan B es parte del trabajo.

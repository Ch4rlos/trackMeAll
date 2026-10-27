# Cómo contribuir

Proyecto personal, pero las reglas son las de cualquier repo serio.

## Requisitos

- macOS con Xcode 26.6 o superior y el componente **iOS platform** instalado.
- `brew install xcodegen`

## Flujo

```bash
git clone https://github.com/Ch4rlos/trackMeAll.git
cd trackMeAll
xcodegen generate
open trackMeAll.xcodeproj
```

Pruebas (no requieren simulador):

```bash
swift test --package-path Packages/TMACore
swift test --package-path Packages/TMASecurity
```

## Reglas de arquitectura

1. **Ningún paquete de sección importa a otro.** Todo pasa por `TMACore`.
2. **La vista no hace red ni lógica de negocio.** ViewModel `@MainActor` + `@Observable`,
   dependencias inyectadas por `init`.
3. **Todo dato del sistema entra por un `Repository`.** Cada protocolo nuevo necesita su
   `MockRepository` y sus tests antes de tocar APIs reales.
4. **Nada de credenciales en el cliente.** Subidas con URLs prefirmadas.
5. **Nada de APIs privadas de Apple.** Ver `docs/ALCANCE-APPLE.md`.
6. **El `.xcodeproj` no se edita a mano ni se versiona.** Se regenera con XcodeGen.

## Decisiones

Si tu cambio contradice un ADR de `docs/DECISIONES.md`, agrega un ADR nuevo explicando por
qué. No se reescribe el historial.

## Antes de abrir un PR

- [ ] `swift test` pasa en `TMACore` y `TMASecurity`
- [ ] `xcodebuild build` compila sin errores nuevos
- [ ] Sin warnings nuevos en los paquetes tocados
- [ ] Sin secretos, rutas absolutas personales ni `.env`
- [ ] Si cambia el alcance, se actualizó `README.md` o `docs/`

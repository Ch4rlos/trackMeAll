# Arquitectura

## Principios

1. **Un dominio, un paquete.** Cada sección del producto es un módulo SwiftPM con su
   `ViewModel`, sus vistas y su `Repository`. Si un dominio crece, se parte el paquete,
   no el archivo.
2. **Los módulos de sección no se conocen entre sí.** La única dependencia permitida es
   hacia `TMACore`. Comunicación cruzada = evento en Core, no `import` entre secciones.
3. **La vista no sabe de dónde vienen los datos.** Siempre a través de un protocolo
   `Repository`, con implementación mock inyectable.
4. **Estado observable por el sistema**, no por magia: `@Observable` + `@MainActor` en el
   ViewModel; la vista nunca guarda lógica.
5. **Nada de credenciales en el cliente.** Las subidas usan URLs prefirmadas que emite el
   backend.

## Capas

```
Vista (SwiftUI)  →  ViewModel (@Observable, @MainActor)  →  Repository (protocolo)
                                                                    │
                                              ┌─────────────────────┴─────────────────────┐
                                        MockRepository                          Implementación real
                                        (etapa 1, sin permisos)            (HealthKit, EventKit, Gmail…)
```

La vista no conoce `URLSession`, `HKHealthStore` ni `CSSearchableIndex`. El ViewModel no
conoce SwiftUI. El Repository no conoce la vista.

## Grafo de dependencias

| Paquete | Depende de | Nunca debe depender de |
|---|---|---|
| `TMACore` | — | cualquier otro paquete |
| `TMASalud` | `TMACore` | otras secciones |
| `TMAFinanzas` | `TMACore` | otras secciones |
| `TMAActividades` | `TMACore` | otras secciones |
| `TMABlog` | `TMACore` | otras secciones |
| `TMASecurity` | `TMACore` | secciones de producto |
| `TMABonanzas` | `TMACore` | secciones de producto |

`TMASecurity` y `TMABonanzas` son transversales: la app las usa, las secciones no.

## Seguridad

- **Autenticación**: `BiometricEvaluating` (protocolo) implementado por
  `BiometricAuthenticator` (LocalAuthentication). `AppLockModel` es la máquina de estados:
  `locked → unlocking → unlocked`, con contador de fallos y caída al código del dispositivo.
- **Secretos**: `KeychainStore` con `kSecAttrAccessControl` y `.biometryCurrentSet`.
  Invalidar la biometría invalida el secreto, que es el comportamiento correcto.
- **Ciclo de vida**: `.onChange(of: scenePhase)` bloquea al pasar a `.background`.
- **Alcance**: el bloqueo protege la app abierta. El cifrado en reposo se resuelve con
  SwiftData + `FileProtection` (pendiente, Fase 4 del roadmap).

## Integraciones del sistema

| Framework | Dónde vive | Nota de diseño |
|---|---|---|
| `LocalAuthentication` | `TMASecurity` | Probado con un doble de prueba; nunca se toca el hardware real en tests |
| `Security` (Keychain) | `TMASecurity` | Política `biometryCurrentSet`; round-trip de diagnóstico en Ajustes |
| `AppIntents` | `TMABonanzas` | Frases en español; el intent no abre la app cuando no hace falta |
| `CoreSpotlight` | `TMABonanzas` | Índice por dominio (`…trackmeall.blog`) para poder borrarlo completo |
| `NSUserActivity` | `TMABonanzas` | Handoff con `section` en `userInfo` |
| `WidgetKit` / `ActivityKit` | `TMABonanzas` | El código compila; publicar exige extensión en el target |
| `HealthKit` | `TMASalud` (fase 2) | Descripciones de uso ya en el `Info.plist` |

## Persistencia (fase 4)

- SwiftData con modelos versionados (`VersionedSchema` + `SchemaMigrationPlan`).
- `FileProtectionType.completeUntilFirstUserAuthentication` como piso.
- Los mocks seguirán existiendo: son el camino para demos y para tests sin datos reales.

## Convenciones

- Un `ViewModel` por pantalla, `@MainActor`, `@Observable`, dependencias por `init`.
- Nombres de dominio en español, APIs públicas en inglés solo cuando el framework lo exige.
- Los errores de dominio son `enum` con `message` legible; nunca se muestra un `NSError` crudo.
- Cada sección nace con tests de sus mocks antes de tocar datos reales.

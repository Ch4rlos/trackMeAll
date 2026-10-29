# Seguridad

## Cómo reportar

Si encuentras una vulnerabilidad, abre un aviso privado en
[Security Advisories](https://github.com/Ch4rlos/trackMeAll/security/advisories/new).
No abras un issue público con el detalle.

## Qué protege la app

| Capa | Implementación |
|---|---|
| Acceso a la app | `LocalAuthentication` (Face ID / Touch ID / Optic ID) con caída al código del dispositivo |
| Auto-bloqueo | `.onChange(of: scenePhase)` al pasar a background |
| Secretos locales | Keychain con `kSecAttrAccessControl` y `.biometryCurrentSet` |
| Credenciales de servicios | **no existen en el cliente**: subida con URLs prefirmadas emitidas por el backend |

## Límites conocidos y declarados

- El bloqueo biométrico protege la app **abierta**; no cifra el archivo de datos en disco.
  El cifrado en reposo (SwiftData + `FileProtection`) está en el roadmap.
- En un equipo sin código de desbloqueo, `deviceOwnerAuthentication` falla: la app queda
  bloqueada y lo dice en pantalla.
- Los datos mock no contienen información personal real.

## Lo que este repo nunca va a contener

- Llaves, tokens, `.env` con credenciales ni perfiles de aprovisionamiento.
- APIs privadas de Apple (por ejemplo, lectura de SMS).
- Dependencias que pidan permisos que el proyecto no puede justificar.

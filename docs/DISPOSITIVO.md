# Correr en un iPhone físico (incluido por Wi-Fi)

## Lo que se verificó en esta Mac

| Prueba | Comando | Resultado |
|---|---|---|
| Build para dispositivo | `xcodebuild -destination 'generic/platform=iOS' build` | **BUILD SUCCEEDED** |
| Build para simulador | `xcodebuild -destination 'generic/platform=iOS Simulator' build` | falla: falta el componente *iOS 26.5 platform* |
| Dispositivos pareados | `xcrun devicectl list devices` | `No devices found` |
| Cuentas de desarrollador en Xcode | `defaults read com.apple.dt.Xcode IDEProvisioningTeams` | sin cuentas |

**Conclusión:** para correr en el iPhone **no hace falta** bajar el runtime del simulador.
Sí hace falta firma (Apple ID), Modo Desarrollador en el teléfono y un pareo inicial.

## ¿Wi-Fi? Sí, pero el primer pareo es con cable

Xcode permite depurar por red, y es el flujo normal de todos los días:

1. **Cable, una sola vez.** Conectar el iPhone a la Mac, desbloquearlo y tocar
   *Confiar en este equipo*.
2. Xcode → **Window → Devices and Simulators** → elegir el iPhone.
3. Marcar **Connect via network**. Desde ese momento aparece en la lista sin cable.
4. Desconectar. Con el iPhone en la **misma red Wi-Fi** que la Mac, Xcode lo ve solo.

**Requisitos que sí se rompen en la práctica:**

- **Misma red y sin aislamiento de clientes.** Muchos routers (y las redes de invitados)
  bloquean el multicast/Bonjour. Si no aparece, se puede fijar la IP a mano:
  *Devices and Simulators → Connect via IP Address*.
- **Modo Desarrollador activo en el iPhone** (iOS 16+):
  Ajustes → Privacidad y seguridad → **Modo desarrollador** → activar → reiniciar el equipo.
- **El Mac y el iPhone con sesión iniciada… no es necesario**: no se requiere iCloud, solo
  confiar en el equipo.

## Firma

1. Xcode → **Settings → Accounts** → `+` → Apple ID → iniciar sesión.
2. En el target `trackMeAll` → **Signing & Capabilities** → marcar *Automatically manage
   signing* → elegir el equipo personal.
3. Si el bundle ID choca, cambiarlo por uno propio (`com.tunombre.trackmeall`).

Con **Apple ID gratis** se puede instalar y depurar: el perfil caduca a los 7 días y hay
límite de apps activas. Los *entitlements* del proyecto (HealthKit, Family Controls) hay
que confirmarlos en Xcode con la cuenta que se use; para el prototipo con datos mock y la
biometría no se necesitan.

**No se versiona nada de esto:** el `DEVELOPMENT_TEAM` y los perfiles quedan en tu Xcode,
no en el repo (ver `.gitignore`).

## iPhone 13 + iOS 26.5

El iPhone 13 es compatible con iOS 26, así que el SDK `iOS 26.5` del proyecto lo cubre.
Tiene Face ID: sirve para validar el bloqueo biométrico de verdad, cosa que el simulador
solo imita.

## Validación en el teléfono

| Qué probar | Cómo |
|---|---|
| Bloqueo biométrico | Abrir la app → debe pedir Face ID; mandarla al fondo y volver → se cierra otra vez |
| Keychain protegido | Ajustes → *Probar Keychain protegido* → debe decir `OK · nonce guardado y leído` |
| Preferencia apagada | Ajustes → apagar el toggle → la app deja de pedir biometría |
| Hápticos | Botón *Bloquear ahora* |
| 4 secciones con datos | Navegar las pestañas; todo viene de mocks |

## Si algo falla

| Síntoma | Causa típica |
|---|---|
| "Untrusted Developer" | Ajustes → General → VPN y gestión de dispositivos → confiar en tu Apple ID |
| El iPhone no aparece por red | Red con aislamiento de clientes o distinta VLAN: usar IP manual o cable |
| "Unable to install" por bundle ID | Alguien más ya usa ese identificador; cambiarlo |
| La app se cierra al abrir | Perfil vencido (7 días con cuenta gratis): volver a correr desde Xcode |

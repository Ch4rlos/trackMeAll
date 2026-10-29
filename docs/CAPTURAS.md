# Capturas

Las capturas se generan con el simulador, nunca a mano: mismo tamaño, mismo estado, mismo
contenido. El script está en [`../scripts/capturas.sh`](../scripts/capturas.sh).

## Requisitos

- Un runtime de simulador instalado (aquí: iOS 26.5) y al menos un iPhone disponible
  (`xcrun simctl list devices available`).
- `DEVELOPER_DIR` apuntando al Xcode, o `xcrun` no encuentra `simctl`.
- `xcodegen` instalado.

## Uso

```bash
./scripts/capturas.sh              # usa el primer iPhone disponible
SIM="iPhone 16 Pro" ./scripts/capturas.sh
OPEN_SIM=1 ./scripts/capturas.sh   # además abre la ventana del Simulator
```

Salida: `docs/img/{salud,finanzas,actividades,blog,ajustes}.png`.

## Cómo funciona

La app acepta dos argumentos de lanzamiento, pensados para automatizar esto:

| Argumento | Efecto |
|---|---|
| `-tab <seccion>` | Abre la app en esa pestaña (`salud`, `finanzas`, `actividades`, `blog`, `ajustes`) |
| `-tma.biometrics.enabled NO` | No pide Face ID (si no, la captura sale de la pantalla de bloqueo) |

El script reinstala, relanza por pestaña y captura con `xcrun simctl io booted screenshot`.

## Estado

Tomadas el 28 de octubre de 2026 con iPhone 17 Pro (iOS 26.5), ejecución headless:

| Archivo | Qué muestra |
|---|---|
| `salud.png` | Gráfica de pasos de 7 días + métricas de hoy |
| `finanzas.png` | Balance total, cuentas y movimientos con su origen |
| `actividades.png` | Uso de apps con barras + lugares donde estuvo |
| `blog.png` | Publicaciones por estado + assets de R2 |
| `ajustes.png` | Seguridad, Keychain y tabla del ecosistema Apple |

Se guardan a 500 px de ancho con esquinas redondeadas. El `hero.png` es un montaje de
Salud, Finanzas y Actividades; `demo.gif` rota las cinco a 1.6 s por cuadro.

## GIF para el README

Con las 5 capturas:

```bash
ffmpeg -framerate 1 -pattern_type glob -i 'docs/img/*.png' \
  -vf "scale=390:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 docs/img/demo.gif
```

> El GIF que genera `ffmpeg` pesa más que el mismo recorrido hecho con ImageMagick
> (`magick -delay 160 -dispose previous ...`). El del repo son 278 KB.

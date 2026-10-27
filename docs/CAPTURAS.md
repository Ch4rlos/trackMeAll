# Capturas

Las capturas se generan con el simulador, nunca a mano: mismo tamaño, mismo estado, mismo
contenido. El script está en [`../scripts/capturas.sh`](../scripts/capturas.sh).

## Requisitos

- Componente **iOS platform** instalado en Xcode (Settings → Components).
- Un simulador de iPhone disponible (`xcrun simctl list devices available`).
- `xcodegen` instalado.

## Uso

```bash
./scripts/capturas.sh              # usa el primer iPhone disponible
SIM="iPhone 16 Pro" ./scripts/capturas.sh
```

Salida: `docs/img/{salud,finanzas,actividades,blog,ajustes}.png`.

## Cómo funciona

La app acepta dos argumentos de lanzamiento, pensados para automatizar esto:

| Argumento | Efecto |
|---|---|
| `-tab <seccion>` | Abre la app en esa pestaña (`salud`, `finanzas`, `actividades`, `blog`, `ajustes`) |
| `-tma.biometrics.enabled NO` | No pide Face ID (si no, la captura sale de la pantalla de bloqueo) |

El script reinstala, relanza por pestaña y captura con `xcrun simctl io booted screenshot`.

## Capturas pendientes de tomar

| Archivo | Qué debe mostrar |
|---|---|
| `salud.png` | Gráfica de pasos de 7 días + métricas de hoy + ánimo |
| `finanzas.png` | Balance total, cuentas y movimientos con su origen (correo/OCR) |
| `actividades.png` | Uso de apps con barras, lugares y agenda |
| `blog.png` | Publicaciones por estado y assets de R2 |
| `ajustes.png` | Toggle de biometría y tabla de integraciones |

## GIF para el README

Con las 5 capturas:

```bash
ffmpeg -framerate 1 -pattern_type glob -i 'docs/img/*.png' \
  -vf "scale=390:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 docs/img/demo.gif
```

> Nota honesta: el script y estos comandos están escritos y revisados sintácticamente
> (`bash -n`), pero **no ejecutados**: falta el componente iOS en Xcode. La primera corrida
> real puede requerir ajustar el nombre del simulador o el tiempo de espera.

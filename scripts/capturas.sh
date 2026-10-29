#!/usr/bin/env bash
# Genera las capturas del README abriendo la app en cada pestaña.
# Uso: ./scripts/capturas.sh        (o SIM="iPhone 16 Pro" ./scripts/capturas.sh)
# Corre headless: no abre la app Simulator. Para verla, OPEN_SIM=1 ./scripts/capturas.sh
set -euo pipefail

cd "$(dirname "$0")/.."

# simctl no está en el PATH si Xcode no está seleccionado en este shell.
if ! xcrun --find simctl >/dev/null 2>&1; then
  export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
fi

BUNDLE_ID="com.carlosquiroga.trackmeall"
OUT="docs/img"
DERIVED="build"

if [ -z "${SIM:-}" ]; then
  SIM=$(xcrun simctl list devices available --json \
    | python3 -c 'import json,sys;d=json.load(sys.stdin)["devices"];n=[x["name"] for v in d.values() for x in v if x["name"].startswith("iPhone")];print(n[0] if n else "")')
fi

if [ -z "$SIM" ]; then
  echo "No hay simulador de iPhone disponible. Instala el componente iOS en Xcode." >&2
  exit 1
fi

echo "Simulador: $SIM"
mkdir -p "$OUT"

command -v xcodegen >/dev/null || { echo "Falta xcodegen: brew install xcodegen" >&2; exit 1; }
xcodegen generate

echo "Compilando…"
xcodebuild -project trackMeAll.xcodeproj -scheme trackMeAll \
  -destination "platform=iOS Simulator,name=$SIM" \
  -derivedDataPath "$DERIVED" CODE_SIGNING_ALLOWED=NO build >/dev/null

APP="$DERIVED/Build/Products/Debug-iphonesimulator/trackMeAll.app"
[ -d "$APP" ] || { echo "No se encontró el .app en $APP" >&2; exit 1; }

xcrun simctl boot "$SIM" 2>/dev/null || true
xcrun simctl bootstatus "$SIM" -b
[ "${OPEN_SIM:-0}" = "1" ] && open -a Simulator || true

xcrun simctl install booted "$APP"

for tab in salud finanzas actividades blog ajustes; do
  echo "Capturando $tab…"
  xcrun simctl terminate booted "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl launch booted "$BUNDLE_ID" -tab "$tab" -tma.biometrics.enabled NO >/dev/null
  sleep 3
  xcrun simctl io booted screenshot "$OUT/$tab.png"
done

echo "Listo: $OUT/"
ls -1 "$OUT"

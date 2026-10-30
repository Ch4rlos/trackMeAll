#!/usr/bin/env bash
# Arma la carpeta que se sube al VPS: HTML + capturas, sin nada mas.
# Uso: ./scripts/export-demo.sh
# Salida: dist/trackmeall/  (gitignored)
set -euo pipefail

cd "$(dirname "$0")/.."

SLUG="trackmeall"
SRC="site/demos/$SLUG"
OUT="dist/$SLUG"

[ -f "$SRC/index.html" ] || { echo "Falta $SRC/index.html" >&2; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT/img"
cp "$SRC/index.html" "$OUT/index.html"

# Solo las imagenes que la pagina usa de verdad.
for img in hero.png salud.png finanzas.png actividades.png blog.png ajustes.png demo.gif; do
  [ -f "docs/img/$img" ] || { echo "Falta docs/img/$img" >&2; exit 1; }
  cp "docs/img/$img" "$OUT/img/$img"
done

# Nada de listados de directorio ni indexado.
printf 'User-agent: *\nDisallow: /\n' > "$OUT/robots.txt"

echo "Listo: $OUT"
du -sh "$OUT"
echo
echo "Para servirla en el VPS (nginx), dentro del server del sitio:"
cat <<'NGINX'
  location /d/trackmeall/ {
      alias /var/www/demos/trackmeall/;
      index index.html;
      add_header X-Robots-Tag "noindex, nofollow, noarchive" always;
      access_log /var/log/nginx/demos.log;
  }
NGINX
echo
echo "Subir con:  rsync -av dist/trackmeall/ usuario@vps:/var/www/demos/trackmeall/"

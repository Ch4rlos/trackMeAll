# Demo no listado — trackMeAll

Página de capacidades en `carlosquiroga.com` que **no se enlaza desde el sitio**. Se llega
solo con la URL. Existe para mandar tráfico desde GitHub (y desde donde se decida) y medir
qué canal trae visitas.

**Destino:** `carlosquiroga.com/d/trackmeall/`
**Archivo:** `site/demos/trackmeall/index.html` → se empaqueta con `scripts/export-demo.sh`

## Qué es y qué no es

No es un demo funcional. **No puede serlo**: es una app de iOS sin App Store, y un mock web
interactivo se cae a la primera pregunta. Lo que muestra son las capacidades reales, con
capturas reales del simulador, y una tabla de lo que la app no hace.

El posicionamiento es de uso personal: *trackear la propia vida*, no gestión de equipos ni
producto para empresas.

## Regla de la página no listada

| Se cumple | No se cumple |
|---|---|
| No hay enlace desde el sitio ni desde el menú | No es privada: quien tenga la URL entra |
| `noindex, nofollow` en el HTML y en la cabecera | No impide que alguien comparta el enlace |
| Fuera del sitemap | No impide que un buscador la indexe si la enlazan desde fuera |
| `robots.txt` con `Disallow: /` | No es control de acceso |

**Consecuencia dura:** la página se trata como pública. Nada de datos reales, capturas de
tus datos, ni nombres de clientes. Si un día lleva algo sensible, va detrás de login y eso
ya no es una página estática.

## Cómo se mide

Lo que **sí** se puede saber, con el log de nginx:

- cuántas visitas y cuántas únicas por IP
- de dónde vienen (**referrer**: `github.com` cuando entra desde el repo)
- país aproximado, dispositivo y navegador (user-agent)
- qué día y a qué hora

Lo que **no** se puede saber sin login: **quién** es la persona. Un log dice "alguien de
Monterrey entró desde GitHub", no "entró Juan". Si algún día quieres nombre y correo, la
página necesita un formulario o un enlace personalizado por destinatario.

### Un enlace por canal

Para separar canales sin analítica de terceros, se usa el mismo path con un parámetro:

| Canal | URL |
|---|---|
| GitHub (campo *Website* del repo) | `carlosquiroga.com/d/trackmeall/?ref=github` |
| LinkedIn | `carlosquiroga.com/d/trackmeall/?ref=linkedin` |
| WhatsApp / correo directo | `carlosquiroga.com/d/trackmeall/?ref=dm` |

Con eso basta:

```bash
# visitas por canal, últimos 7 días
awk '{print $7}' /var/log/nginx/demos.log \
  | grep -o 'ref=[a-z]*' | sort | uniq -c | sort -rn
```

## Publicación (WILLY)

1. `./scripts/export-demo.sh` → genera `dist/trackmeall/` (1.4 MB: HTML + 7 imágenes).
2. Subir: `rsync -av dist/trackmeall/ usuario@vps:/var/www/demos/trackmeall/`
3. En el `server` del sitio, agregar el bloque que imprime el script:

```nginx
location /d/trackmeall/ {
    alias /var/www/demos/trackmeall/;
    index index.html;
    add_header X-Robots-Tag "noindex, nofollow, noarchive" always;
    access_log /var/log/nginx/demos.log;
}
```

4. Comprobar: `curl -sI https://carlosquiroga.com/d/trackmeall/` debe dar `200` y la
   cabecera `X-Robots-Tag`. Y la portada **no** debe enlazarla.
5. Recién entonces, poner la URL en el campo *Website* del repo en GitHub.

> Pendiente aparte: `api.carlosquiroga.com` resuelve por DNS wildcard al mismo servidor y
> no tiene certificado válido (`curl` falla con error 60). Eso hay que resolverlo antes de
> conectar cualquier app a ese subdominio.

## Copy

El texto vive en `site/demos/trackmeall/index.html`. Tono: el del sitio, directo, sin
admiración y sin jerga. Si se cambia el copy, se cambia ahí y se vuelve a exportar.

# Ficha web — trackMeAll

Contenido listo para publicar en `carlosquiroga.com`, dentro de la línea **Tecnología**.
No es un README: es la página que ve alguien que llega desde GitHub o desde el sitio y
necesita saber qué es esto, por qué está bien hecho y qué no hace.

**Destino propuesto:** `carlosquiroga.com/tecnologia/trackmeall`
**Tono:** el del sitio —directo, sin jerga, sin signos de admiración—, no el de un README.

---

## Copy

### trackMeAll

Una app de iPhone que reúne en un solo lugar lo que mi teléfono ya sabe de mí: salud,
finanzas, actividades y lo que escribo.

La construí porque mis datos viven en cuatro apps que no se hablan entre sí y ninguna me
deja ver el conjunto. No es un producto a la venta: es un proyecto de ingeniería con el
código abierto, y sirve como muestra de cómo trabajo.

### Cómo está construido

Siete módulos independientes sobre SwiftUI y Swift 6, uno por dominio: salud, finanzas,
actividades, blog, seguridad y el que conecta con el ecosistema de Apple (Siri, Spotlight,
Handoff, widgets y Live Activity).

La regla que sostiene todo: **ningún módulo de sección conoce a otro**. Lo compartido vive
en un núcleo común. Si un módulo se rompe, los demás siguen compilando, y el día que uno
cambie de enfoque no arrastra al resto.

### Tres decisiones que se sostienen

**Un paquete por dominio.** Se puede probar cada módulo por separado y publicar versiones
sueltas. Otro proyecto puede consumir el núcleo sin copiar código.

**Cero red en la app.** El código abierto no tiene endpoints, ni llaves, ni credenciales:
funciona con datos de ejemplo. Es una decisión de diseño, no una etapa pendiente. Una app
de portafolio que pide llaves es un riesgo; una que no puede pedirlas es una garantía.

**Los límites de Apple, dichos de frente.** La app documenta qué información del iPhone
existe, cuál está bloqueada por permisos que Apple revisa y cuál es imposible sin APIs
privadas. Prefiero decir "esto no se puede" antes que prometerlo en una junta.

### Lo que la app no hace (y por qué)

| Lo que uno esperaría | La realidad |
|---|---|
| Leer SMS o iMessage | No existe API pública. Solo hay APIs privadas, y eso se rechaza. |
| Movimientos de Wallet o Apple Card | Requiere un permiso especial que Apple revisa y una cuenta de empresa. |
| Qué apps usas y por cuánto tiempo | Existe, pero el permiso se solicita a Apple antes de poder distribuir. |
| Ver tus datos en un servidor | No los manda a ningún lado. Todo se queda en el teléfono. |

### Dónde verlo

- Código y capturas: `github.com/Ch4rlos/trackMeAll`
- Descargar y compilar: Xcode 26 o superior, iOS 18 o superior

### Lo que salió de aquí

De este proyecto salió una versión privada, hecha a mi medida, que uso a diario. Esa no se
publica: corre con mis datos reales y no tiene fines de demostración.

---

## Checklist de publicación (para quien publique)

- [ ] Publicar en `/tecnologia/trackmeall` con la plantilla de esta misma estructura.
- [ ] Enlazar desde la línea **Tecnología → Web y sistemas**.
- [ ] Poner la URL en el campo *Website* del repo de GitHub, para que el repo apunte al
      sitio y no al revés.
- [ ] Reusar las capturas de `docs/img/` (mismas que el README, ya generadas).
- [ ] No crear todavía un índice de proyectos: con un solo elemento se ve vacío. Cuando
      haya dos, sí.
- [ ] Revisar que `api.carlosquiroga.com` resuelva a un servicio con certificado válido
      antes de conectar cualquier app a él.

## Plantilla para el próximo proyecto

1. Qué es, en dos líneas.
2. El problema real que resolvía.
3. Cómo está construido (arquitectura, en tres o cuatro frases).
4. Tres decisiones técnicas y por qué.
5. Lo que no hace, en tabla. Honestidad antes que alcance.
6. Dónde verlo (repo + cómo correrlo).
7. Qué salió de aquí, si algo salió.

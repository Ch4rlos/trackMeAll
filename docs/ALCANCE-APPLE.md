# Alcance real de las APIs de Apple

Cada límite está verificado contra la documentación oficial. Se documenta porque un
prototipo que promete lo imposible se cae en la primera demo técnica.

---

## 1. SMS: no existe API pública

**Requisito del producto.** Leer las notificaciones SMS del banco para registrar gastos.

**Realidad.** iOS no expone ninguna API pública para leer SMS o iMessage. La única vía es
usar APIs privadas, lo que implica rechazo en App Store y riesgo de seguridad. No se hace.

**Sustitutos viables, en orden de fricción:**

1. **Correo bancario** vía Gmail API (OAuth ya disponible). Los bancos mandan el mismo
   movimiento por correo; se parsea y se registra.
2. **OCR on-device** con Vision sobre capturas de pantalla del estado de cuenta.
3. **CSV** exportado del banco.
4. **Entrada manual** con captura rápida por Siri/Atajos (ya implementado: `RegistrarGastoIntent`).

---

## 2. Wallet: `FinanceKit` es puerta cerrada para cuenta individual

**Requisito.** Traer los movimientos de Apple Wallet.

**Realidad.** Documentación de `FinanceKit` (iOS 17+), textual:

> To access someone's financial data, you must meet the criteria outlined in Get started
> with FinanceKit, request the FinanceKit managed entitlement, **hold an organization-level
> Apple Developer account, be logged in as Account Holder**, and include the
> `NSFinancialDataUsageDescription` string in your `Info.plist`. Apple reviews each
> application using defined criteria.

Además, cubre **Apple Card, Apple Cash y Apple Card Savings**. No cubre tarjetas de otros
bancos agregadas a Wallet.

**Consecuencia.** Con cuenta individual no se puede acceder a esos datos. El módulo
`TMAFinanzas` trabaja con `Transaction.Source` (`.manual`, `.gmail`, `.ocr`, `.csv`) y deja
la puerta abierta a `.financeKit` si algún día existe cuenta de organización aprobada.

---

## 3. Uso de apps: `DeviceActivity` + `Family Controls` con entitlement

**Requisito.** Medir cuánto tiempo se usa cada app.

**Realidad.** `AuthorizationCenter.requestAuthorization` exige el entitlement
`com.apple.developer.family-controls`. La documentación de Apple indica que hay que
**solicitar permiso de distribución** antes de enviar a App Store; para uso individual con
build propio funciona con el entitlement activo.

**Consecuencia.** La sección Actividades muestra datos mock hasta que exista cuenta de
desarrollador y el entitlement aprobado. `CoreLocation` (visitas) y `EventKit` (agenda) sí
funcionan sin aprobación especial, solo con descripciones de uso.

---

## 4. Salud: viable, con matices

| Dato | Framework | Nota |
|---|---|---|
| Pasos, FC, HRV, VO₂ máx, sueño | `HealthKit` cuantitativo | Requiere permiso por tipo |
| Entrenamientos | `HKWorkout` | El Watch los genera; el simulador no |
| Estado de ánimo | `HKStateOfMind` (iOS 18+) | Valencia −1…1 y etiquetas |
| Alimentación | Tipos dietéticos de HealthKit | HealthKit no trae base de alimentos: entrada manual o API externa |

**Consecuencia.** En simulador no hay datos del Watch: se desarrolla con `MockRepository` y
se valida en iPhone.

---

## 5. Blog: sin bloqueos, es backend

Subida de imágenes con **URLs prefirmadas**: la app pide la firma a un endpoint propio y
hace `PUT` directo al bucket. Compatible con **Cloudflare R2** (API S3) o AWS S3. La app
nunca lleva credenciales.

---

## Resumen para la demo

| Sección | Se puede demostrar hoy (mock) | Se puede con cuenta de desarrollador | Se puede sin importar qué |
|---|---|---|---|
| Salud | ✅ | ✅ HealthKit | — |
| Finanzas | ✅ | parcial (sin Wallet de terceros, sin SMS) | ❌ SMS |
| Actividades | ✅ | ✅ con entitlement | ❌ uso de apps sin permiso |
| Blog | ✅ | ✅ | — |

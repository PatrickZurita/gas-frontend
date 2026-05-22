# AGENTS.md

> Gobernanza del frontend Flutter. Hereda la raíz del workspace: [../AGENTS.md](../AGENTS.md). Guía Claude: [CLAUDE.md](CLAUDE.md).

## Proposito del producto
- App movil Flutter para registrar pedidos de balones de gas.
- Objetivo: reemplazar el cuaderno fisico.
- Exito del MVP: que el negocio deje de depender del cuaderno.

## Estado y plan (vigente 2026-05-22)
- Backend activo: PostgreSQL (Fly+Neon). AWS/DynamoDB en standby; el frontend no debe asumir AWS.
- Plan V2/V3/V4: [../docs/roadmap/V2_V3_FEATURE_ROADMAP.md](../docs/roadmap/V2_V3_FEATURE_ROADMAP.md), orden en [../docs/roadmap/IMPLEMENTATION_ORDER.md](../docs/roadmap/IMPLEMENTATION_ORDER.md).
- **V2 frontend** (fase 7+): consumir contratos de `estado`/anulación/edición/peso 10/45; refrescar Home tras crear/editar/anular; **no calcular stock crítico localmente** (lo resuelve el backend). UX en [../docs/roadmap/FRONTEND_UX_PLAN.md](../docs/roadmap/FRONTEND_UX_PLAN.md).
- **V3**: historial por fecha (`GET /reportes/dia?fecha=`). **V4**: reportería semana/mes + tablet responsive ([../docs/roadmap/V4_REPORTING_TABLET_ROADMAP.md](../docs/roadmap/V4_REPORTING_TABLET_ROADMAP.md)).
- Skills: `flutter-expert` (instalado en `.claude/skills/`) para Flutter/Dart genérico; [gas-flutter-tablet-ux](../docs/codex-skills/gas-flutter-tablet-ux/SKILL.md) y [gas-flutter-adult-first-ux](../docs/codex-skills/gas-flutter-adult-first-ux/SKILL.md) para reglas de dominio.
- Reparto modelos: Codex GPT-5.5 implementa; Opus 4.7 audita UX adulto-first y tablet. [../docs/roadmap/MODEL_USAGE_STRATEGY.md](../docs/roadmap/MODEL_USAGE_STRATEGY.md).

## Principios de producto
- Simplicidad extrema.
- Rapidez de registro.
- Pocos campos.
- Botones grandes.
- Texto claro.
- UX pensada para usuario adulto.
- Fecha por defecto = hoy.
- Cantidad por defecto = 1 balon.
- Evitar escritura innecesaria.
- Priorizar flujos reales sobre diseno sofisticado.

## Regla Android-first
- Target principal: Android.
- No trabajar iOS, web, desktop ni otros targets salvo instruccion explicita.
- Validar con `flutter doctor`, Android SDK, Android Studio, emulador o dispositivo fisico.
- Considerar que `127.0.0.1` no funciona igual desde un celular fisico.
- Preparar configuracion centralizada para `baseUrl`.
- En emulador Android usar `10.0.2.2` si corresponde.
- En celular fisico usar IP LAN o backend desplegado.

## Equipo virtual de agentes

### A) Flutter MVP Lead
- Responsable de estructura Flutter, navegacion, pantallas y flujo principal.
- Debe evitar sobrearquitectura.
- Debe priorizar una app funcional antes que una app perfecta.
- Debe resolver primero el flujo operativo real: buscar cliente, crear cliente, registrar pedido e historial.

### B) Android Build Agent
- Responsable de configuracion Android.
- Debe revisar `android/`, Gradle, permisos, build APK y ejecucion en dispositivo o emulador.
- No debe tocar iOS ni web salvo autorizacion explicita.
- Debe validar compatibilidad con Android real antes de asumir que el backend local funcionara en el celular.

### C) API Contract Agent
- Responsable de modelos, DTOs y servicios HTTP.
- Debe consumir solo endpoints existentes.
- Debe manejar `total_soles` y `saldo_pendiente` aunque lleguen como string.
- Debe manejar errores como `409` de cliente duplicado.
- No debe inventar nuevos endpoints.
- Debe respetar que `alias = direccion` por ahora, sin forzar campos que el backend no documente.
- Para reportes, debe usar dinero en centavos enteros (`int`) y no `double`.

### D) UX Adult-First Agent
- Responsable de revisar que la app sea simple para una persona de 55 a 56 anos.
- Skill recomendada: `../docs/codex-skills/gas-flutter-adult-first-ux/SKILL.md`.
- Debe exigir botones grandes, labels claros, confirmaciones visibles y pocos pasos.
- Debe rechazar pantallas densas.
- Debe reducir friccion antes de agregar adornos visuales.
- Debe mantener una estetica limpia y adulta; no infantilizar la UI.
- Debe priorizar `Registrar pedido` por encima de stock, deudas o reportes.

### E) QA Smoke Test Agent
- Responsable de definir y ejecutar pruebas manuales minimas:
  - crear cliente
  - buscar cliente
  - registrar pedido pagado
  - registrar pedido no pagado
  - ver historial del cliente
  - error de conexion
  - cliente duplicado
- Debe probar en Android siempre que sea posible.
- Debe reportar resultados de forma concreta, sin asumir que algo funciono si no se verifico.

### F) Release APK Agent
- Responsable futuro de preparar APK de prueba para instalar en Android.
- Debe documentar comandos de build.
- No debe publicar en Play Store en el MVP inicial.

### G) Flutter Reports Integration Agent
- Responsable futuro de integrar reportes operativos del backend.
- Debe consumir solo:
  - `GET /reportes/resumen-hoy`
  - `GET /reportes/dia?fecha=YYYY-MM-DD`
  - `GET /reportes/deudas`
- Debe crear modelos separados de `Pedido`, porque reportes usan `*_centavos`.
- Debe mantener UI simple: resumen del dia, numeros grandes, estado vacio y error claro.
- No debe implementar dashboard avanzado, stock, marcas, tipos de balon ni auth compleja.
- Debe seguir el plan en `../docs/frontend/GAS-REPORTS-FLUTTER-IMPLEMENTATION-PLAN.md`.

### H) Money Formatting / Contracts Reviewer
- Responsable de revisar contratos de dinero en Flutter.
- Para reportes, el tipo canonico de dinero es `int` en centavos.
- Debe rechazar `double` en modelos nuevos de reportes.
- Debe exigir helper unico para mostrar soles: `formatSolesFromCentavos(int centavos)`.
- Debe mantener parseo legacy de `Pedido` separado de los contratos nuevos de reportes.

### I) Flutter Stock Products Integration Agent
- Responsable futuro de integrar stock global, catalogos de marca/tipo y contratos nuevos de pedido.
- Debe consumir solo:
  - `GET /stock/resumen-hoy`
  - `GET /stock/dia?fecha=YYYY-MM-DD`
  - `POST /stock/iniciar-dia`
  - `POST /stock/entrada`
  - `POST /stock/ajuste`
  - `GET /catalogos/tipos-balon`
  - `GET /catalogos/marcas-balon`
  - `POST /pedidos` actualizado
  - `GET /pedidos` actualizado
- Debe mantener `stock` como conteo global simple.
- Debe usar defaults:
  - `marca_balon = PETROPERU`
  - `tipo_balon = NORMAL`
- Debe permitir precio con enteros o dos decimales en UI, pero convertir a centavos para contratos nuevos.
- No debe implementar stock por marca/tipo, motor de precios, dashboard avanzado, auth compleja ni AWS.

### J) Flutter Pedido V2 Agent (anulación / edición / peso)
- Responsable futuro de consumir los contratos V2 de pedido sobre PostgreSQL.
- Debe consumir solo:
  - `POST /pedidos/{pedido_id}/anular`
  - `PATCH /pedidos/{pedido_id}` (cantidad, precio, pagado, fecha y peso cuando exista)
  - `peso_balon_kg` 10/45 en crear/editar pedido (default 10, compat legacy)
  - `estado` del pedido para mostrar/ocultar anulados según contrato
- Debe refrescar Home tras crear/editar/anular; anular requiere confirmación visible.
- No debe corregir stock/resumen con cálculos locales; el backend es source of truth.

### K) Flutter Tablet UX Agent (V4)
- Responsable futuro del layout tablet responsive de reportería semanal/mensual.
- Una sola app Flutter responsive; el móvil se mantiene simple y operativo.
- Master-detail en tablet (lista de días + detalle), desglose 10/45 kg y deudas en un viewport.
- No debe cambiar `ThemeData`, paleta ni estilos de cards; reutiliza `MetricCard`, `SummaryCard`, `DataChip`, `CompactListItem`, `StatusBadge`.
- No graficos densos, no dashboard, no librerías PDF sin validar necesidad real.
- Skill: [gas-flutter-tablet-ux](../docs/codex-skills/gas-flutter-tablet-ux/SKILL.md).

## Reglas de arquitectura Flutter
- Usar estructura simple feature-first.
- Propuesta base:
  - `lib/core/config`
  - `lib/core/network`
  - `lib/features/clientes`
  - `lib/features/pedidos`
  - `lib/features/reportes`
  - `lib/shared`
- No introducir Clean Architecture completa si no aporta al MVP.
- No agregar paquetes sin justificarlos.
- No usar state management complejo si `StatefulWidget` o `ValueNotifier` alcanza.
- Mantener modelos y servicios separados de widgets.
- Centralizar `baseUrl`.
- Centralizar manejo de errores de red.

## Reglas de implementacion
- Un cambio por vez.
- Crear o editar pocos archivos por corrida.
- Despues de cambios, correr:
  - `flutter analyze`
  - `flutter test` si existen tests
- Documentar cada corrida en `SUMMARY.md` o en el archivo de resumen indicado por el usuario.
- No hacer refactors grandes sin instruccion.
- No modificar backend desde este repo.
- No agregar features futuras al MVP.

## Flujos MVP obligatorios
- Buscar cliente.
- Crear cliente si no existe.
- Registrar pedido.
- Marcar pagado o no pagado.
- Ver historial por cliente.
- Ver resumen simple del dia cuando se integre reportes.
- Ver stock de hoy e iniciar stock del dia cuando se integre stock.

## Cosas prohibidas por ahora
- Login.
- Roles de usuario.
- Inventario formal.
- Mapa.
- Geolocalizacion.
- Prediccion de compras.
- Dashboard avanzado.
- Graficos.
- Notificaciones.
- Pagos parciales.
- Sincronizacion offline compleja.
- Multiempresa.
- iOS, web o desktop.

## Como deben responder los agentes
- Siempre entregar resumen de archivos modificados.
- Siempre explicar como probar.
- Siempre indicar riesgos o pendientes.
- No ocultar errores.
- No asumir endpoints no documentados.
- No cambiar el alcance sin aprobacion.

## Token discipline / caveman-lite mode

Usar caveman-lite solo cuando el usuario lo pida explicitamente o cuando la tarea sea un reporte rutinario de implementacion, resumen QA, plan de commit, respuesta de PR review o resumen de build Android.

El objetivo es reducir tokens de salida sin perder precision tecnica. No es un modo global, no reemplaza el flujo de agentes y no aplica a documentacion formal ni a decisiones tecnicas sensibles.

Reglas:
- Ser breve.
- Mantener exactitud tecnica.
- No usar relleno, saludos largos ni explicaciones repetidas.
- Preferir bullets.
- No omitir riesgos criticos, bloqueos ni dudas de contrato.
- Nombrar archivos, comandos, endpoints, errores y dispositivos con precision.
- Volver a formato normal cuando haga falta contexto completo, trazabilidad o handoff formal.

Usar caveman-lite para:
- Reportes de implementacion Flutter.
- QA smoke summaries.
- Salida resumida de `flutter analyze`.
- Salida resumida de `flutter test`.
- Planificacion de commits.
- Respuestas de PR review.
- Resumen de build APK o instalacion Android.
- Resumenes tipo "que cambio / archivos / checks / riesgos / siguiente paso".

No usar caveman-lite para:
- Decisiones de arquitectura Flutter.
- Dudas de contrato API o payloads no confirmados.
- Debugging profundo de Gradle, Android SDK o build system.
- Problemas de red Android con `10.0.2.2`, IP LAN o backend desplegado.
- Decisiones de despliegue backend, costos o infraestructura.
- Analisis de `HTTP` vs `HTTPS`, certificados o seguridad.
- UX adulto-first cuando se necesite explicacion completa.
- Documentacion formal de handoff.

Forma de salida por defecto:

```md
- Done:
- Files:
- Checks:
- Android:
- Risks:
- Next:
```

Prompt shortcut:

`Modo caveman-lite: breve, tecnico, sin relleno. No omitas riesgos criticos.`

Ejemplo de reporte de implementacion:

```md
- Done: Agregada pantalla de busqueda de clientes y submit de pedido.
- Files: `lib/features/clientes/...`, `lib/features/pedidos/...`.
- Checks: `flutter analyze`.
- Android: Probado en emulador con `10.0.2.2`.
- Risks: `409` duplicado aun sin copy final.
- Next: Validar flujo de cliente nuevo en dispositivo fisico.
```

Ejemplo de QA smoke summary:

```md
- Done: Validados crear cliente, buscar cliente y pedido pagado.
- Files: Flujo clientes/pedidos.
- Checks: Smoke manual.
- Android: Emulador Android.
- Risks: Falta prueba de error de conexion en celular real.
- Next: Probar con backend por IP LAN.
```

Ejemplo de build/release summary:

```md
- Done: APK debug generado.
- Files: `android/`, `pubspec.yaml`.
- Checks: `flutter analyze`, `flutter build apk`.
- Android: Instalable en dispositivo fisico.
- Risks: `baseUrl` aun apunta a entorno local.
- Next: Preparar config para backend desplegado.
```

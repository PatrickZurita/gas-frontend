# UI_STYLE_AUDIT_SUMMARY

> **Ultima actualizacion:** 2026-05-13 (pase 7 — refinamientos de marca).
> **Estado:** 7 pases de modernizacion completos. `flutter analyze` limpio, `flutter test` 55/55. Validacion en device fisico pendiente.
> **Alcance:** Auditoria visual/estilo. Decisiones funcionales/UX previas (pull-to-refresh, lenguaje stock, compactacion de listas) se resumen en la seccion "Historial UX (pases funcionales anteriores)" al final.

## Diagnostico visual actual

- La app ya usaba Material 3, pero el tema estaba casi en defaults con `ColorScheme.fromSeed`.
- El fondo blanco/claro era correcto, pero faltaba una direccion visual mas confiable y consistente.
- Habia estilos repetidos en varias pantallas:
  - `TextStyle` locales para titulos, numeros y labels.
  - `BoxDecoration` repetidos para frames/cards.
  - `ElevatedButton.styleFrom` y `OutlinedButton.styleFrom` locales.
  - badges de estado duplicados en historial y pedidos del dia.
- La jerarquia operativa ya era buena: `Registrar pedido` sigue arriba y stock/resumen estan visibles.
- Stock y pedidos ya estaban mas orientados a uso real, pero los estados `Pagado/Debe` necesitaban color y forma mas consistente.

## Pantallas auditadas

- Home
- Stock
- Busqueda de cliente
- Creacion de cliente
- Cliente seleccionado
- Registrar pedido
- Historial
- Pedidos del dia
- Reportes/resumen
- Deudas

## Problemas de estilo detectados

- Paleta anterior dependia demasiado del seed y no tenia una decision clara para estados.
- Inputs usaban `OutlineInputBorder` local, sin fill ni foco visual consistente.
- Botones principales y secundarios funcionaban, pero no habia estilo global suficiente.
- AppBar seguia siendo muy generico.
- Los estados de pedido estaban definidos dos veces con logica visual duplicada.
- Persisten estilos hardcodeados en pantallas; no se hizo limpieza completa para evitar refactor grande.

## Decision de paleta / tema

- Se eligio una paleta sobria teal / azul petroleo:
  - Primario: `#006875`
  - Primario claro: `#CDEFF3`
  - Pagado: usa canal tertiary verde sobrio
  - Debe/error: usa canal error rojo suave, claramente distinguible
- Razon UX:
  - buen contraste sobre fondo claro;
  - se siente mas confiable que verde brillante;
  - evita una estetica infantil o demasiado corporativa;
  - diferencia deuda/pagado sin depender solo del texto.

## Material 3 / ThemeData / ColorScheme

- Se mantiene `useMaterial3: true`.
- Se centralizo el tema en `lib/core/theme/app_theme.dart`.
- `MaterialApp` ahora usa `AppTheme.light`.
- Se configuraron:
  - `ColorScheme`
  - `TextTheme`
  - `AppBarTheme`
  - `InputDecorationTheme`
  - `ElevatedButtonThemeData`
  - `OutlinedButtonThemeData`
  - `SegmentedButtonThemeData`
  - `SnackBarThemeData`
  - `DividerThemeData`

## Componentes reutilizables creados o ajustados

- Creado: `lib/shared/status_badge.dart`
  - `StatusBadge`
  - `StatusBadgeType.paid`
  - `StatusBadgeType.debt`
- Creado: `lib/shared/summary_card.dart`
  - `SummaryCard`
  - centraliza frames/cards con borde, radio y fondo del tema.
- Creado: `lib/shared/message_box.dart`
  - `MessageBox`
  - `MessageBoxType.neutral`
  - `MessageBoxType.success`
  - `MessageBoxType.error`
- Creado: `lib/shared/compact_list_item.dart`
  - `CompactListItem`
  - centraliza filas compactas usadas por pedidos del dia e historial.
- Ajustado: `lib/shared/action_button.dart`
  - mantiene altura grande para acciones principales;
  - agrega peso tipografico consistente;
  - conserva API existente.

## Archivos modificados

- `lib/core/theme/app_theme.dart`
- `lib/main.dart`
- `lib/shared/action_button.dart`
- `lib/shared/compact_list_item.dart`
- `lib/shared/message_box.dart`
- `lib/shared/summary_card.dart`
- `lib/shared/status_badge.dart`
- `lib/features/stock/widgets/stock_hoy_section.dart`
- `lib/features/reportes/widgets/resumen_dia_section.dart`
- `lib/features/reportes/widgets/deudas_pendientes_section.dart`
- `lib/features/clientes/screens/buscar_cliente_screen.dart`
- `lib/features/clientes/screens/crear_cliente_screen.dart`
- `lib/features/clientes/screens/cliente_seleccionado_screen.dart`
- `lib/features/pedidos/screens/registrar_pedido_screen.dart`
- `lib/features/reportes/screens/pedidos_dia_screen.dart`
- `lib/features/pedidos/screens/historial_cliente_screen.dart`
- `UI_STYLE_AUDIT_SUMMARY.md`

## Antes / despues

Antes:
- Theme minimo desde seed.
- Colores generados sin decision explicita.
- Inputs y botones dependian de defaults/local styles.
- Badges `Pagado/Debe` duplicados.

Despues:
- Tema claro centralizado y mas profesional.
- Botones, inputs, appbar, segmented buttons y snackbars comparten estilo.
- `Pagado/Debe` usa un componente unico con color consistente.
- Frames principales usan `SummaryCard`.
- Mensajes de error/exito/estado usan `MessageBox`.
- Filas compactas de pedidos usan `CompactListItem`.
- La app conserva fondo claro, texto legible y acciones grandes sin volverse dashboard pesado.

## Pase 7 — Refinamientos de marca

Objetivo: pasar de "Material 3 generico" a "app con identidad" sin sacrificar usabilidad para adulto mayor. Cambios deliberadamente conservadores (sin gradientes, sin fuentes custom, sin iconografia decorativa).

### Cambios aplicados

- `AppBar` ahora usa `primaryContainer` (#CDEFF3) de fondo con titulo en `onPrimaryContainer` (#00363D). Antes era `surface` plano y se fundia con el contenido al scrollear.
- `SummaryCard` ahora rellena con `surfaceContainerLow` (#F2F5F6) en lugar de `surface`. Agrega jerarquia visual sutil entre fondo de pantalla y bloques de contenido.
- Nuevo `surfaceContainerLow` declarado explicitamente en el `ColorScheme` (no estaba antes; se usaba el default derivado).
- Creado `lib/shared/section_title.dart` — `SectionTitle(title, subtitle?, large)` con barra vertical primary 4dp como accent de marca.
- Home migra titulo "Pedidos de gas" + subtitulo a `SectionTitle(large: true)`.
- `buscar_cliente_screen.dart` migra "Busca por direccion o telefono" a `SectionTitle`.
- `RefreshIndicator` del home explicitamente pintado con `primary` sobre `surface` (antes default).

### Decisiones intencionales

- NO se aplico `SectionTitle` a headers internos de `SummaryCard` ("Stock de hoy", "Resumen del dia", "Deudas pendientes", "Clientes recientes"). La barra vertical adentro de un card con borde competiria visualmente. El nuevo fill tintado del card ya cumple la funcion de jerarquia.
- NO se cambio la paleta base (#006875). El teal ya paso audit y cambiarlo es subjetivo/riesgoso.
- NO se agregaron sombras o gradientes. Los bordes + fill tintado dan profundidad suficiente sin verse barato.

### Archivos nuevos en el pase 7

- `lib/shared/section_title.dart` — `SectionTitle` con accent bar vertical.

### Archivos modificados

- `lib/core/theme/app_theme.dart` — AppBar con primaryContainer, ColorScheme con surfaceContainerLow explicito.
- `lib/shared/summary_card.dart` — fill por defecto cambia a surfaceContainerLow.
- `lib/home_screen.dart` — titulo con SectionTitle, RefreshIndicator branded.
- `lib/features/clientes/screens/buscar_cliente_screen.dart` — header migrado a SectionTitle.

### Checks pase 7

- `flutter analyze`: `No issues found!`
- `flutter test`: `All tests passed!` (55 tests)

### Riesgos pendientes del pase 7

- AppBar con primaryContainer no validado en device fisico bajo luz solar directa. El contraste teorico es AA pero la percepcion en exterior puede diferir.
- Cambio de fill en SummaryCard no validado visualmente — diferencia entre `surface` (FBFCFA) y `surfaceContainerLow` (F2F5F6) es ~5% de luminancia, deberia leerse como jerarquia sutil sin "ruido visual" pero requiere validacion.
- Accent bar primary en SectionTitle: validar que no compita con el AppBar tintado en pantallas donde ambos coexisten (home y buscar cliente). Si se siente "demasiado teal", el bar puede pasarse a `secondary` o `tertiary`.

## Riesgos resueltos en la sexta pasada

- `_InfoRow` (`cliente_seleccionado_screen.dart`) promovido a `InfoField` compartido. Tipografia migrada a `Theme.textTheme.headlineSmall / labelLarge`.
- `_TotalLine` / `_TotalsFrame` (`pedidos_dia_screen.dart`) → promovido a `MetricLine` compartido. Variante `strong` mapea a `headlineSmall` (antes 24dp), variante normal mapea a `titleLarge`.
- `_CatalogSegmented` (`registrar_pedido_screen.dart`) → promovido a `CatalogSelector` compartido con `CatalogOption(value, label)` desacoplado del modelo `CatalogoItem` del feature stock; los call sites mapean inline. `minimumSize` unificado a 56dp y textStyle al theme.
- `_DebtRow` (`deudas_pendientes_section.dart`): tipografia migrada a `Theme.textTheme.titleLarge / titleMedium / headlineSmall` (se mantiene como widget privado ya que solo lo usa esa pantalla; promoverlo no aporta).
- `_CompactHomeButton` (`home_screen.dart`): label migrado a `Theme.textTheme.titleMedium`. Se mantuvo `minimumSize: 56` (intentar 60dp empujaba el viewport del test fuera de 600px; pendiente validar en device si conviene subir touch target).
- `_FiltroPedidos` (`pedidos_dia_screen.dart`): textStyle del SegmentedButton migrado a `Theme.textTheme.titleMedium`.
- "Clientes recientes" header y empty text (`buscar_cliente_screen.dart`) migrados a `Theme.textTheme.headlineSmall / titleMedium`.

### Archivos nuevos en la sexta pasada

- `lib/shared/info_field.dart` — `InfoField` (label + value dentro de `SummaryCard` con borde radius 8).
- `lib/shared/metric_line.dart` — `MetricLine` (Row label/value con variante `strong`).
- `lib/shared/catalog_selector.dart` — `CatalogSelector` + `CatalogOption` (SegmentedButton con label de seccion).

### Archivos modificados

- `lib/features/clientes/screens/cliente_seleccionado_screen.dart` — usa `InfoField`; eliminada clase privada; removido import de `SummaryCard`.
- `lib/features/reportes/screens/pedidos_dia_screen.dart` — usa `MetricLine`; `_FiltroPedidos` con `titleMedium`.
- `lib/features/pedidos/screens/registrar_pedido_screen.dart` — usa `CatalogSelector` con mapeo inline de `CatalogoItem` a `CatalogOption`.
- `lib/features/reportes/widgets/deudas_pendientes_section.dart` — `_DebtRow` con tipografia del theme.
- `lib/home_screen.dart` — `_CompactHomeButton` con tipografia del theme.
- `lib/features/clientes/screens/buscar_cliente_screen.dart` — header/empty de "Clientes recientes" con tipografia del theme.

### Checks sexta pasada

- `flutter analyze`: `No issues found!`
- `flutter test`: `All tests passed!` (55 tests).

### Nota de regresion durante la sexta pasada

- Aumentar `minimumSize` de `_CompactHomeButton` de 56 a 60 rompio `tapping reports summary opens day orders list` porque el "Resumen del dia" quedaba 1px fuera del viewport del test (600px). Se revirtio a 56. Es un buen indicador de que cualquier cambio de touch target a futuro debera ajustar tambien los tests si dependen de geometria.

## Riesgos resueltos en la quinta pasada

- `_ClienteBox` (`registrar_pedido_screen.dart`) y `_ClienteHeader` (`historial_cliente_screen.dart`) eran identicos: promovidos a `ClienteInfoCard` compartido. Tipografia migrada de `TextStyle(fontSize: ...)` a `Theme.textTheme.headlineSmall / titleMedium / labelLarge`.
- `_ClienteRecienteItem` y `_ClienteListItem` (`buscar_cliente_screen.dart`) tenian estructura casi identica con dos variantes visuales: promovidos a `ClienteListTile` con prop `recent: bool`. Tipografia migrada al theme.
- Elimina `_ClienteListItem` que dependia del modelo `Cliente`: el shared toma `direccion: String, telefono: String, onTap, recent` para no acoplar el componente al modelo del feature.

### Archivos nuevos en la quinta pasada

- `lib/shared/cliente_info_card.dart` — `ClienteInfoCard` (label "Cliente" + direccion + telefono dentro de `SummaryCard`).
- `lib/shared/cliente_list_tile.dart` — `ClienteListTile` (variantes `recent` y default, sin acoplar al modelo de feature).

### Archivos modificados

- `lib/features/pedidos/screens/registrar_pedido_screen.dart` — usa `ClienteInfoCard`; eliminada clase privada y removido import de `SummaryCard`.
- `lib/features/pedidos/screens/historial_cliente_screen.dart` — usa `ClienteInfoCard`; eliminada clase privada.
- `lib/features/clientes/screens/buscar_cliente_screen.dart` — usa `ClienteListTile` (con `recent: true` para recientes); eliminadas las dos clases privadas.

### Checks quinta pasada

- `flutter analyze`: `No issues found!`
- `flutter test`: `All tests passed!` (55 tests; incluye `client search selects a result` y `client search selects a recent client`, que verifican ambas variantes).

## Riesgos resueltos en la cuarta pasada

- Duplicacion de control numerico (+/- y campo grande) en `registrar_pedido_screen.dart` (`_CantidadBalonesControl` + `_QuantityButton`) y `stock_hoy_section.dart` (`_StockCountControl` + `_StockQuantityButton`):
  - Promovido a `NumberInputControl` compartido (`lib/shared/number_input_control.dart`).
  - Promovido a `QuantityButton` compartido (`lib/shared/quantity_button.dart`).
- Inconsistencias resueltas al unificar: tamaño de boton (64dp en ambos), altura de campo (68dp), tipografia del campo (`Theme.textTheme.displaySmall` con `FontWeight.w900`), color de label/icono via theme (`colors.primary`), border radius del wrapper (12dp) y border color (`outlineVariant`).
- Header del control (icono + label) tambien estandarizado a `Theme.textTheme.titleLarge`.
- API simplificada: `NumberInputControl(controller, label, icon, enabled?, minValue?, maxValue?, onChanged?)`. Los dialogs y formularios pasan los parametros sin duplicar wrappers.

### Archivos nuevos en la cuarta pasada

- `lib/shared/quantity_button.dart` — `QuantityButton` (size configurable, default 64; icon auto-escalado).
- `lib/shared/number_input_control.dart` — `NumberInputControl` (envoltorio completo con header y +/- de cantidad).

### Archivos modificados

- `lib/features/pedidos/screens/registrar_pedido_screen.dart` — usa `NumberInputControl(label: 'Balones', icon: Icons.propane_tank_outlined)`; eliminadas las clases privadas.
- `lib/features/stock/widgets/stock_hoy_section.dart` — usa `NumberInputControl(label: 'Cantidad', minValue: allowZero ? 0 : 1, maxValue: 9999)`; eliminadas las clases privadas.

### Checks cuarta pasada

- `flutter analyze`: `No issues found!`
- `flutter test`: `All tests passed!` (55 tests)

## Riesgos resueltos en la tercera pasada

- Loading states crudos (`CircularProgressIndicator` + `Text` ad-hoc) en 6 pantallas: mitigado con `LoadingCard` compartido.
  - Aplicado en: `stock_hoy_section.dart`, `resumen_dia_section.dart`, `deudas_pendientes_section.dart`, `pedidos_dia_screen.dart`, `buscar_cliente_screen.dart`, `historial_cliente_screen.dart`.
- Error states con `Text` desnudo en stock/resumen/deudas: mitigado con `MessageBox(type: MessageBoxType.error)`.
- `_MetricBlock` privado de `resumen_dia_section.dart`: promovido a `MetricCard` compartido y migrado a `Theme.textTheme` (sin `fontSize` hardcoded).
- `_StockChip` privado de `stock_hoy_section.dart`: promovido a `DataChip` compartido y migrado a `Theme.textTheme`.
- Header `Resumen del dia` y textos finales del resumen: migrados de `TextStyle(fontSize: ...)` a `Theme.textTheme.headlineSmall / titleMedium`.
- Header `Stock de hoy` y `Deudas pendientes` en error state: migrados a `Theme.textTheme.headlineSmall`.

### Archivos nuevos en la tercera pasada

- `lib/shared/loading_card.dart` — `LoadingCard` (mensaje + ícono opcional + spinner pequeño dentro de `SummaryCard`).
- `lib/shared/metric_card.dart` — `MetricCard` (label + valor grande, variantes `primary` y default).
- `lib/shared/data_chip.dart` — `DataChip` (chip horizontal label+value).

### Checks tercera pasada

- `flutter analyze`: `No issues found!`
- `flutter test`: `All tests passed!` (55 tests)

## Riesgos resueltos en la segunda pasada

- Estilos locales repetidos de frames/cards: mitigado con `SummaryCard`.
- Mensajes duplicados en pantallas: mitigado con `MessageBox`.
- Filas compactas duplicadas en pedidos/historial: mitigado con `CompactListItem`.
- Badges duplicados de `Pagado/Debe`: resuelto con `StatusBadge`.
- Checks automatizados despues de la migracion: `flutter analyze` y `flutter test` pasan.

## Resultado flutter analyze

- Comando: `flutter analyze`
- Resultado: `No issues found!`

## Resultado flutter test

- Comando: `flutter test`
- Resultado: `All tests passed!`

## Riesgos pendientes

- No se hizo prueba visual en Android fisico.
- Falta revisar contraste real bajo brillo alto y luz exterior.
- No se implemento selector `Normal / Grande`; se recomienda una pasada dedicada para no romper layouts.
- Widgets privados restantes (intencionalmente locales por tener un solo uso o logica especifica):
  - `_StockNumberDialog` (`stock_hoy_section.dart`) — dialog de captura numerica. Candidato futuro a `NumberInputDialog` si aparece otro caller.
  - `_CompactHomeButton` (`home_screen.dart`) — usado solo en home. Candidato futuro a `CompactActionButton` si se reusa.
  - `_DebtRow` (`deudas_pendientes_section.dart`) — usado solo en su dialog. Mantenido local con tipografia del theme.
  - `_TotalsFrame`, `_FiltroPedidos`, `_PedidosDiaList`, `_PedidoDiaRow`, `_ClientesRecientesSection`, `_ResumenContent`, `_PedidoHistoryList`, `_PedidoHistoryRow`, `_StockContent` — componen pantallas concretas y no son reutilizables.
- `NumberInputControl` no usa `prefixIcon` en el `TextField` interno porque el icono ya aparece en el header del control. Validar visualmente que sea suficiente para el adulto mayor; si no, se puede extender el componente con un `helperText` grande.

## Recomendaciones siguientes

- Probar en Android fisico con texto del sistema en normal y grande.
- Hacer una pasada visual con capturas reales de Home, Stock, Registrar pedido y Pedidos del dia.
- Validar con el usuario final si los colores de `Pagado` y `Debe` se distinguen rapidamente.
- Validar AppBar tintado bajo luz solar directa (pase 7).
- Si el accent primary del `SectionTitle` se siente saturado en device, considerar pasarlo a `secondary` o `tertiary`.
- Implementar selector `Normal / Grande` para escalar texto (riesgo: requiere revisar layouts; ver historial UX).

## Historial UX (pases funcionales anteriores)

Esta seccion preserva las decisiones funcionales tomadas antes de la modernizacion visual. Los archivos originales (`UX_FIXES_SUMMARY.md`, `UX_STOCK_HOME_AUDIT_SUMMARY.md`, `PEDIDOS_LIST_UX_AUDIT_SUMMARY.md`) se consolidaron aqui y se eliminaron para mantener orden.

### Pase A — UX Fixes (pull-to-refresh, anti-doble-submit, busqueda con debounce)

- Home con `RefreshIndicator`: pull-to-refresh recarga resumen, stock y deudas via un callback que recrea las secciones (incrementa `_refreshVersion` para forzar `ValueKey`).
- `Guardar pedido` con guard contra doble submit: retorna temprano si ya esta guardando, deshabilita controles, muestra `Guardando...`. Razon: riesgo operativo de duplicar pedidos.
- `BuscarClienteScreen` con busqueda automatica: debounce 350 ms, arranca desde 2 caracteres. Se mantiene boton `Buscar` para usuarios que prefieren accion explicita.
- Cantidad de balones con botones grandes `+`/`-` (mas tarde promovidos a `NumberInputControl` y `QuantityButton` compartidos).
- Endpoints existentes, sin cambios backend.

### Pase B — Stock y orden de Home (lenguaje operativo)

- Home reordenado: `Stock de hoy` aparece **antes** del resumen de ventas. Razon: la primera pregunta operativa del usuario es "cuantos balones tengo" tanto como "cuanto vendi hoy".
- Stock cambia a lenguaje operativo (antes era administrativo):
  - `Iniciar dia` → `Registrar stock de hoy`
  - `Ajustar` → `Actualizar stock actual`
  - Aparece `Balones disponibles` en grande.
  - `Agregar entrada` como accion secundaria.
- Dialogos de stock usan contador `+/-` con numero grande (mismo patron luego unificado en `NumberInputControl`).
- Confirmaciones explicitas via snackbar: `Stock de hoy registrado`, `Stock actualizado`, `Entrada guardada`.
- Mapeo backend conservado:
  - sin stock del dia → `POST /stock/iniciar-dia`
  - con stock del dia → `POST /stock/ajuste`

### Pase C — Compactacion de listas (estilo "cuaderno de pedidos")

- `PedidosDiaScreen` y `HistorialClienteScreen` migraron de "card por pedido" a "lista compacta con separadores sutiles". Razon: una card por pedido ocupaba demasiada altura; el usuario operativo lee como hoja de cuaderno.
- Pedidos del dia:
  - fecha arriba en formato natural ("Martes 12 de mayo de 2026").
  - cada fila prioriza alias/direccion y monto.
  - segunda linea con cantidad, marca/tipo y estado.
  - estado pendiente se muestra como `Debe` (lenguaje operativo) en vez de `Pendiente`.
- Historial por cliente:
  - mas detalle que pedidos del dia.
  - cada pedido se compacta a fecha + monto + cantidad + estado.
  - saldo solo aparece cuando el pedido realmente debe.
- Estas listas usan `CompactListItem` compartido desde el pase 2 de la modernizacion visual.

### Decisiones que sobreviven en el codigo actual

- `RefreshIndicator` en home con color `primary` (pase 7).
- Guard contra doble submit en `RegistrarPedido` (pase A).
- Debounce de busqueda 350 ms y `_minSearchLength = 2` (pase A).
- Stock primero, despues resumen, despues deudas (pase B).
- Lenguaje "Debe" / "Pagado" via `StatusBadge` (pases B/C → unificado en pase 2 visual).
- Listas compactas via `CompactListItem` (pase C → unificado en pase 2 visual).

### Pendientes documentados desde estos pases

- Smoke manual en Android fisico con backend local (todos los pases).
- Validar contraste real bajo brillo alto y luz exterior (pase C + pase 7).
- Implementar selector `Normal / Grande` para escalar texto del sistema (pase B); requiere revisar layouts de dialogs, botones segmentados y filas compactas.
- Confirmar con usuario final si "Debe" es preferible a "Pendiente" (pase C).

- Date: 2026-05-21 00:00 -05:00

- Causa probable:
  - El frontend no tiene cache HTTP ni persistencia local para `Home`; el problema mas probable era estado en memoria desactualizado.
  - `Home` refrescaba cambiando `keys` y esperando `250ms`, pero no esperaba la respuesta real de `/stock/resumen-hoy`, `/reportes/resumen-hoy` ni `/reportes/deudas`.
  - Al volver desde pantallas hijas, `Home` seguia montado y no siempre reconsultaba backend.
  - Si el pedido duplicado fue eliminado fuera del flujo actual de la app, el frontend solo podia mostrar la realidad despues de una nueva consulta al backend.
  - Si backend sigue contando pedidos eliminados dentro del resumen diario, Flutter no puede corregir ese numero por si solo.

- Archivos revisados:
  - [lib/home_screen.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/home_screen.dart)
  - [lib/features/stock/widgets/stock_hoy_section.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/stock/widgets/stock_hoy_section.dart)
  - [lib/features/stock/services/stock_service.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/stock/services/stock_service.dart)
  - [lib/features/stock/models/stock_resumen.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/stock/models/stock_resumen.dart)
  - [lib/features/reportes/widgets/resumen_dia_section.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/reportes/widgets/resumen_dia_section.dart)
  - [lib/features/reportes/widgets/deudas_pendientes_section.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/reportes/widgets/deudas_pendientes_section.dart)
  - [lib/features/reportes/screens/pedidos_dia_screen.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/reportes/screens/pedidos_dia_screen.dart)
  - [lib/features/pedidos/screens/registrar_pedido_screen.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/pedidos/screens/registrar_pedido_screen.dart)
  - [lib/features/clientes/screens/buscar_cliente_screen.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/clientes/screens/buscar_cliente_screen.dart)
  - [lib/features/clientes/screens/cliente_seleccionado_screen.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/clientes/screens/cliente_seleccionado_screen.dart)
  - [lib/core/network/api_client.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/core/network/api_client.dart)
  - [test/widget_test.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/test/widget_test.dart)

- Mejoras implementadas:
  - `Home` ahora refresca las tres secciones visibles con `Future.wait(...)` y espera respuestas reales del backend.
  - `Home` ahora vuelve a consultar backend al regresar desde `Buscar cliente` y `Pedidos`.
  - `Home` ahora vuelve a consultar backend cuando la app regresa a primer plano.
  - Pull-to-refresh ahora dispara recarga real de stock, resumen y deudas, sin delay fijo artificial.
  - Se eliminaron las `ValueKey` usadas como mecanismo de invalidacion visual.
  - `StockHoySection`, `ResumenDiaSection` y `DeudasPendientesSection` exponen `refresh()` para invalidar su `Future` activo sin recrear toda la pantalla.
  - La etiqueta ambigua `Ajustes 1` se cambio por `Ajuste manual +1` o `Ajuste manual -1`, mas clara para usuario adulto.
  - El chip de ajuste ahora tambien aparece cuando el delta es negativo; antes solo aparecia para `> 0`.

- Requiere backend o no:
  - Para refresco de `Home`: no. Quedo resuelto desde Flutter.
  - Para que `vendidos hoy` sea siempre consistente despues de eliminar/anular pedidos: si, probablemente backend.
  - Necesidad backend 1: que `/stock/resumen-hoy` y `/stock/dia?fecha=...` recalculen `salidas` desde pedidos vigentes del dia o desde movimientos validos no anulados.
  - Necesidad backend 2: que los pedidos eliminados/anulados no sigan afectando stock ni vendidos.
  - Necesidad backend 3: un flujo oficial para anular/eliminar pedido con impacto consistente en stock y resumen; Flutter no debe inventarlo.
  - Necesidad backend 4: mantener consistencia entre `/stock/resumen-hoy` y `/reportes/resumen-hoy` para que balones vendidos y pedidos reales del dia coincidan.

- Pruebas realizadas:
  - Auditado flujo guardar pedido -> callback -> regreso a `Home`.
  - Auditado flujo `Home` -> `Pedidos` -> volver.
  - Auditado `RefreshIndicator` del `Home`.
  - Auditado ausencia de cache HTTP en [lib/core/network/api_client.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/core/network/api_client.dart).
  - Agregados tests widget para recarga al volver a `Home`.
  - Agregados tests widget para pull-to-refresh.
  - Agregado test widget para copy claro de ajuste manual.

- Resultado analyze/test:
  - `flutter analyze` -> `No issues found!`
  - `flutter test` -> `64` tests passed.

- Siguiente recomendacion:
  - Validar en Android real este caso: iniciar stock `40`, crear `2` pedidos, eliminar/anular `1` pedido desde el flujo real disponible, volver a `Home`, hacer pull-to-refresh y confirmar que `vendidos hoy` y `stock disponible` coinciden con backend.
  - Si tras recargar sigue apareciendo vendido de mas, el bug queda confirmado en backend y no en cache Flutter.
  - Pedir a backend un contrato explicito para anulacion/eliminacion de pedido con reversa de stock y recalculo de resumen diario.

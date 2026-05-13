# GAS Android QA Findings Fix Report

## Observaciones del usuario

- En Android, `Resumen del dia` mostraba montos que parecian no cuadrar con un precio esperado de S/ 55 por balon.
- La card `Resumen del dia` no tenia accion al tocarla.
- Se necesitaba una lista simple de pedidos del dia con filtros `Todos`, `Pagados` y `Pendientes`.
- El boton `Historial` en Home confundia porque llevaba a busqueda/clientes recientes.
- El usuario espera ver pedidos cuando toca `Pedidos`, no clientes.

## Diagnostico

Endpoint revisado:

```text
GET http://127.0.0.1:8001/reportes/resumen-hoy
```

Response observado el 2026-05-10:

```json
{
  "fecha": "2026-05-10",
  "pedidos_count": 6,
  "balones_vendidos": 8,
  "monto_total_centavos": 64000,
  "monto_pagado_centavos": 55000,
  "monto_pendiente_centavos": 9000
}
```

El frontend consume `monto_total_centavos`, `monto_pagado_centavos` y `monto_pendiente_centavos` como `int`, y solo los formatea a soles en UI. No se encontro mezcla con `total_soles` legacy en reportes, ni doble multiplicacion/division por 100.

La suma de reportes venia consistente:

```text
55000 + 9000 = 64000
S/ 550.00 + S/ 90.00 = S/ 640.00
```

El dato sospechoso estaba en pedidos de 2 balones donde el backend ya devolvia:

```json
{
  "cantidad_balones": 2,
  "precio_unitario_centavos": 11000,
  "monto_total_centavos": 22000
}
```

Eso es consistente matematicamente si el precio unitario fue S/ 110, pero no coincide con la expectativa operativa de S/ 55 por balon. La causa mas probable en frontend era UX: el campo decia `Precio`, y con cantidad 2 el usuario podia ingresar `110` pensando en total, mientras la app lo enviaba como precio unitario.

## Causa encontrada

Bug principal: ambiguedad de UI en registro de pedido.

- Antes: campo `Precio`.
- Ahora: campo `Precio por balon` con ayuda `No escribas el total`.

No se encontro bug de conversion de centavos en los modelos de reportes.

## Cambios realizados

- `Resumen del dia` ahora es accionable y abre `Pedidos de hoy`.
- Se agrego pantalla simple `Pedidos de hoy`.
- La pantalla muestra fecha, totales, pedidos, balones y lista de pedidos.
- Cada pedido muestra direccion/cliente, balones, marca, tipo, monto y estado.
- Se agregaron filtros visibles:
  - `Todos`
  - `Pagados`
  - `Pendientes`
- Home cambio `Historial` por `Pedidos`.
- `Pedidos` abre pedidos del dia, no clientes recientes.
- `Buscar` sigue abriendo busqueda de clientes.

## Tests agregados o actualizados

- Formato de dinero en centavos.
- Resumen con 6 pedidos de S/ 55 = S/ 330.
- Validacion de `total = pagado + pendiente`.
- Tap en resumen abre lista de pedidos.
- Filtros `Todos`, `Pagados`, `Pendientes`.
- Boton Home muestra `Pedidos` y ya no `Historial`.
- `Pedidos` muestra pedidos y no clientes recientes.
- Registro de pedido muestra `Precio por balon`.

## Checks ejecutados

```powershell
flutter analyze
flutter test test\api_models_test.dart
flutter test test\api_services_test.dart
flutter test test\widget_test.dart
```

Resultado:

- `flutter analyze`: sin issues.
- Tests de modelos: pasan.
- Tests de servicios: pasan.
- Widget tests: pasan.

Nota: una corrida paralela de tests agoto tiempo/memoria del runner local; al ejecutar en serie, las suites pasaron.

## Riesgos pendientes

- Los pedidos ya creados con `precio_unitario_centavos = 11000` permanecen en backend y seguiran inflando el resumen historico de ese dia.
- Si el negocio necesita corregir esos pedidos, debe hacerse desde backend/base de datos o una futura herramienta de edicion; no se modifico backend.
- La pantalla `Pedidos de hoy` usa los datos disponibles en `/reportes/resumen-hoy`; si el backend devuelve datos historicos inconsistentes, la UI los mostrara tal como llegan.
- No se probo manualmente de nuevo en Android despues del cambio.

## Prueba manual recomendada

1. Abrir Home en Android.
2. Confirmar que el boton dice `Pedidos`, no `Historial`.
3. Tocar `Resumen del dia` y verificar que abre `Pedidos de hoy`.
4. Probar filtros `Todos`, `Pagados`, `Pendientes`.
5. Tocar `Pedidos` desde Home y confirmar que no aparecen clientes recientes.
6. Registrar pedido con `Balones = 2` y `Precio por balon = 55`.
7. Verificar que el nuevo pedido impacta el resumen como S/ 110, no S/ 220.

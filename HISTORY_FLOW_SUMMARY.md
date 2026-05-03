# History Flow Summary

## Fase
Fase 6: historial simple de pedidos por cliente.

## Archivos creados
- `lib/features/pedidos/screens/historial_cliente_screen.dart`
- `HISTORY_FLOW_SUMMARY.md`

## Archivos modificados
- `lib/home_screen.dart`
- `lib/features/clientes/screens/cliente_seleccionado_screen.dart`
- `test/widget_test.dart`

## Flujo implementado
- Desde `ClienteSeleccionadoScreen` se agrego boton grande `Ver historial`.
- `Ver historial` abre `HistorialClienteScreen`.
- `HistorialClienteScreen` recibe el `Cliente` seleccionado.
- Usa `PedidoService.listarPedidosPorCliente(cliente.id)`.
- Consume solo `GET /pedidos?cliente_id=...`.
- Home ahora deja `Historial` habilitado y lo lleva a `Buscar Cliente` para seleccionar primero un cliente.

## Datos mostrados
Por cada pedido:
- `fecha_entrega`
- `cantidad_balones`
- `total_soles`
- `pagado` como `Si/No`
- `saldo_pendiente`

## Estados de pantalla
- Loading con `Cargando pedidos...`.
- Mensaje si no hay pedidos: `Este cliente aun no tiene pedidos.`
- Mensaje claro si ocurre error.
- Lista en cards simples.

## Decisiones UX
- Cards simples en vez de tablas.
- Texto grande para fecha y montos.
- Cliente visible arriba para confirmar contexto.
- Sin filtros, reportes, edicion ni eliminacion.
- Flujo corto: buscar cliente, seleccionar, ver historial.
- `Historial` desde Home no abre una lista global; primero pide buscar cliente para evitar ambiguedad.

## Como probar manualmente con backend local
Backend local en PC:

```txt
http://127.0.0.1:8000
```

En emulador Android:

```powershell
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

En celular fisico:

```powershell
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://<IP_LAN_PC>:8000
```

Smoke manual:
- Abrir app.
- Tocar `Historial`.
- Buscar cliente existente.
- Seleccionar cliente.
- Tocar `Ver historial`.
- Confirmar que carga pedidos si existen.
- Confirmar mensaje de vacio si el cliente no tiene pedidos.
- Apagar backend y confirmar mensaje de error.

## Resultado de flutter analyze

```txt
No issues found!
```

## Resultado de flutter test

```txt
All tests passed!
```

Total observado: `17` tests aprobados.

## Riesgos o pendientes
- No se probo contra backend real desde Android en esta corrida.
- En celular fisico no usar `127.0.0.1` ni `10.0.2.2`; usar IP LAN o backend desplegado.
- No hay filtros de historial.
- No hay edicion ni eliminacion de pedidos.
- No hay pagos parciales.
- No hay reportes ni graficos.

## Siguiente paso recomendado
Hacer smoke test manual completo en Android con backend local: crear cliente, buscar cliente, registrar pedido pagado, registrar pedido no pagado y ver historial.

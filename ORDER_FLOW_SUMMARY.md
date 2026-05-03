# Order Flow Summary

## Fase
Fase 5: registrar pedido desde cliente seleccionado.

## Archivos creados
- `lib/features/pedidos/screens/registrar_pedido_screen.dart`
- `ORDER_FLOW_SUMMARY.md`

## Archivos modificados
- `lib/main.dart`
- `lib/home_screen.dart`
- `lib/features/clientes/screens/buscar_cliente_screen.dart`
- `lib/features/clientes/screens/cliente_seleccionado_screen.dart`
- `lib/features/pedidos/pedido_service.dart`
- `test/api_services_test.dart`
- `test/widget_test.dart`

## Flujo implementado
- Desde `ClienteSeleccionadoScreen` se agrego boton grande `Registrar pedido`.
- El boton abre `RegistrarPedidoScreen`.
- `RegistrarPedidoScreen` recibe el `Cliente` seleccionado.
- Formulario:
  - Cliente visible con direccion y telefono.
  - Cantidad de balones con default `1`.
  - Total soles.
  - Pagado `Si/No`.
  - Boton grande `Guardar pedido`.
- Al guardar:
  - Usa `PedidoService.crearPedido`.
  - Envia solo el endpoint existente `POST /pedidos`.
  - Muestra loading con texto `Guardando...`.
  - Muestra confirmacion simple de exito.
  - Muestra error claro si falla.

## Decisiones UX
- Cantidad inicia en `1` para reducir escritura.
- `Pagado` inicia en `Si` porque es el caso operativo mas simple.
- Se uso `SegmentedButton` para elegir `Si/No` de forma visible.
- Campos grandes y textos claros.
- Cliente queda visible durante el registro para evitar errores.
- No se agregaron pasos intermedios ni dialogs.
- No se implemento historial ni pagos parciales.

## Decisiones tecnicas
- `PedidoService` quedo como interfaz para permitir tests con fake service.
- `ApiPedidoService` mantiene la implementacion real contra backend.
- `ApiClient` y `AppConfig.baseUrl` se mantienen como fuente de red centralizada.
- No se agregaron dependencias.
- No se tocaron endpoints ni backend.
- Navegacion con `Navigator` y `MaterialPageRoute`.

## Como probar manualmente con backend local
Backend local en PC:

```txt
http://127.0.0.1:8000
```

En emulador Android, correr:

```powershell
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

En celular fisico conectado a la misma red LAN:

```powershell
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://<IP_LAN_PC>:8000
```

Smoke manual:
- Abrir app.
- Tocar `Nuevo pedido`.
- Buscar cliente existente.
- Seleccionar cliente.
- Tocar `Registrar pedido`.
- Confirmar que cantidad empieza en `1`.
- Escribir total, por ejemplo `55`.
- Elegir `Si` y guardar.
- Ver mensaje `Pedido guardado como pagado.`
- Repetir con `No` para validar pedido no pagado.
- Probar cantidad `0` y confirmar validacion.
- Probar total `0` y confirmar validacion.

## Resultado de flutter analyze

```txt
No issues found!
```

## Resultado de flutter test

```txt
All tests passed!
```

Total observado: `15` tests aprobados.

## Riesgos o pendientes
- No se probo contra backend real desde Android en esta corrida.
- En celular fisico no usar `127.0.0.1` ni `10.0.2.2`; usar IP LAN o backend desplegado.
- No existe historial de pedidos en UI todavia.
- No hay pantalla post-guardado con detalle del pedido; solo confirmacion simple.
- El total se ingresa manualmente.

## Siguiente paso recomendado
Implementar Fase 6: historial simple por cliente usando `GET /pedidos?cliente_id=...`.

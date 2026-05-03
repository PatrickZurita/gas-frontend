# API Layer Summary

## Plan aplicado
- Se creo `docs/API_IMPLEMENTATION_PLAN.md`.
- Se implemento una capa API minima sin UI nueva.
- Se mantuvo `AppConfig.baseUrl` como fuente central de URL.
- Se consumen solo endpoints documentados.
- Se mantuvo la estructura feature-first del repo.

## Archivos creados
- `docs/API_IMPLEMENTATION_PLAN.md`
- `lib/core/network/api_client.dart`
- `lib/core/network/api_exception.dart`
- `lib/features/clientes/models/cliente.dart`
- `lib/features/clientes/models/cliente_create_request.dart`
- `lib/features/clientes/cliente_service.dart`
- `lib/features/pedidos/models/pedido.dart`
- `lib/features/pedidos/models/pedido_create_request.dart`
- `lib/features/pedidos/pedido_service.dart`
- `test/api_models_test.dart`
- `test/api_services_test.dart`

## Archivos modificados
- `pubspec.yaml`
- `pubspec.lock`
- `android/app/src/main/AndroidManifest.xml`

## Dependencias agregadas
- `http: ^1.2.2`

Justificacion:
- Es una dependencia ligera y estandar para HTTP en Flutter.
- Permite usar `http.Client` inyectable.
- Permite tests simples con `package:http/testing.dart`.
- No agrega state management ni arquitectura pesada.

## Capa de red
- `ApiClient` usa `AppConfig.baseUrl` por defecto.
- Soporta `GET` y `POST` JSON.
- Envia headers:
  - `Accept: application/json`
  - `Content-Type: application/json`
- Timeout: `10 seconds`.
- Errores HTTP centralizados en `ApiException`.
- Errores de conexion/timeout centralizados en `NetworkException`.
- Lee `detail` del backend cuando existe.

## Services
- `ClienteService`
  - `crearCliente`: `POST /clientes/`
  - `buscarClientes`: `GET /clientes/search?q=...&limit=...`
  - `obtenerCliente`: `GET /clientes/{id}`
  - Mapea `409` a `ClienteDuplicadoException`.
- `PedidoService`
  - `crearPedido`: `POST /pedidos`
  - `listarPedidosPorCliente`: `GET /pedidos?cliente_id=...`

## Modelos y DTOs
- `Cliente`
  - `direccion` opcional.
- `ClienteCreateRequest`
  - `alias`
  - `telefono`
- `Pedido`
  - `total_soles` y `saldo_pendiente` aceptan string o numero.
  - `created_at` y `fecha_entrega` se parsean como `DateTime`.
- `PedidoCreateRequest`
  - `cliente_id`
  - `cantidad_balones`
  - `total_soles`
  - `pagado`

## Android
- Se agrego permiso:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Tests creados
- `test/api_models_test.dart`
  - Parsing de `Cliente` con `direccion`.
  - Parsing de `Cliente` sin `direccion`.
  - JSON de `ClienteCreateRequest`.
  - Parsing de `Pedido` con montos string.
  - Parsing de `Pedido` con montos numericos.
  - JSON de `PedidoCreateRequest`.
- `test/api_services_test.dart`
  - `POST /clientes/` conserva slash final.
  - `409` cliente duplicado se mapea a `ClienteDuplicadoException`.
  - `POST /pedidos` va sin slash final.
  - `GET /pedidos?cliente_id=...` usa query correcto.

## Comandos ejecutados
- `flutter pub get`
- `dart format lib test`
- `flutter analyze`
- `flutter test`

## Resultado de flutter pub get
- Dependencia `http` resuelta.
- Version bloqueada en `pubspec.lock`: `http 1.6.0`.
- Pub mostro un problema no bloqueante al decodificar advisories de `pub.dev`:

```txt
Failed to decode advisories for http from https://pub.dev.
FormatException: advisoriesUpdated must be a String
```

La resolucion de dependencias termino y `pubspec.lock` fue actualizado.

## Resultado de flutter analyze

```txt
No issues found!
```

## Resultado de flutter test

```txt
All tests passed!
```

Total observado: `11` tests aprobados.

## Riesgos y pendientes
- No se probo contra backend real en Android todavia.
- En emulador Android el default `http://10.0.2.2:8000` es correcto si el backend corre en la PC.
- En celular fisico se debe usar IP LAN o backend desplegado con `--dart-define=API_BASE_URL=...`.
- El cliente HTTP aun no se usa desde UI porque esta fase no conecta botones.
- No hay retries ni refresh porque no hay auth ni flujos complejos en el MVP.

## Siguiente paso recomendado
Implementar UI minima para:
- buscar cliente
- crear cliente si no existe
- registrar pedido
- ver historial del cliente

Antes de probar en celular fisico, correr la app con:

```powershell
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://<IP_LAN_PC>:8000
```

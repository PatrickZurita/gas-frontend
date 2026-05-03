# API Implementation Plan

## Alcance
- Implementar capa API minima para clientes y pedidos.
- No crear pantallas nuevas.
- No conectar botones.
- No tocar backend.
- No inventar endpoints.

## Endpoints soportados
- `POST /clientes/`
- `GET /clientes/search?q=...&limit=10`
- `GET /clientes/{id}`
- `POST /pedidos`
- `GET /pedidos?cliente_id=...`

## Estructura
- `lib/core/network`: cliente HTTP, errores y configuracion de red.
- `lib/features/clientes`: modelos y service de clientes.
- `lib/features/pedidos`: modelos y service de pedidos.

## Decisiones
- Usar `package:http` porque es la dependencia minima y suficiente para REST.
- Mantener modelos y services separados de widgets.
- Inyectar `http.Client` en `ApiClient` para tests simples.
- Centralizar `baseUrl` desde `AppConfig.baseUrl`.
- Manejar timeouts y errores HTTP en una sola capa.

## Riesgos
- `total_soles` y `saldo_pendiente` pueden llegar como string o numero; se parsean como `double`.
- `direccion` en cliente puede venir ausente; se maneja como opcional.
- `409` en cliente duplicado se expone como error claro de dominio.
- En Android fisico, `10.0.2.2` no apunta al host; se debe usar IP LAN o backend desplegado.

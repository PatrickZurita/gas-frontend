# gas-frontend

App Flutter Android para registrar pedidos de gas (balones) del MVP.

> **Última actualización:** 2026-05-13

## Estado actual

- Flutter 3.x, Material 3, target principal Android.
- Backend FastAPI consumido por `lib/core/network/api_client.dart`.
- 7 pases de modernización visual completos. Ver [UI_STYLE_AUDIT_SUMMARY.md](UI_STYLE_AUDIT_SUMMARY.md).
- Migración de IDs `int → String` Fase A completa (compat PostgreSQL + DynamoDB). Ver [../docs/flutter/GAS-FLUTTER-ID-MIGRATION-GUIDANCE.md](../docs/flutter/GAS-FLUTTER-ID-MIGRATION-GUIDANCE.md).
- `flutter analyze` limpio, `flutter test` 61/61 (al 2026-05-13).
- Pendiente: validación visual en device físico, selector Normal/Grande de texto, coordinar Fase B (backend Pydantic `Union[int, str]`).

## Estructura

```
lib/
  core/
    config/app_config.dart        — baseUrl via --dart-define=API_BASE_URL
    network/                       — ApiClient, ApiException
    theme/app_theme.dart           — Material 3 light, paleta teal #006875
  features/
    clientes/                      — buscar, crear, seleccionar cliente
    pedidos/                       — registrar pedido, historial por cliente
    reportes/                      — resumen del día, deudas, pedidos del día
    stock/                         — registrar y ajustar stock diario
  shared/                          — componentes reutilizables (16 widgets)
  home_screen.dart
  main.dart
test/                              — 55 tests (api_models, api_services, widget)
```

## Documentación viva

- [UI_STYLE_AUDIT_SUMMARY.md](UI_STYLE_AUDIT_SUMMARY.md) — auditoría visual completa con 7 pases + historial UX consolidado (pull-to-refresh, lenguaje stock, compactación de listas).
- [AGENTS.md](AGENTS.md) — guía para agentes (Codex/Claude).
- [inicio.md](inicio.md) — contexto de producto del MVP.

## Cómo correr

```bash
flutter pub get
flutter analyze
flutter test
```

Para correr en device, con backend local en la PC:

```bash
# Emulador Android
flutter run -d <DEVICE_ID> --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Celular físico en la misma LAN
flutter run -d <DEVICE_ID> --dart-define=API_BASE_URL=http://<IP_LAN_PC>:8000
```

## Endpoints consumidos

- `GET/POST /clientes/`, `GET /clientes/search`, `GET /clientes/recientes`
- `POST /pedidos`, `GET /pedidos?cliente_id=...`
- `GET /reportes/resumen-hoy`, `GET /reportes/deudas`, día por `fecha=`
- `GET /stock/resumen-hoy`, `POST /stock/iniciar-dia`, `POST /stock/entrada`, `POST /stock/ajuste`
- `GET /stock/catalogos`

No hay auth en el MVP. `ApiClient` centraliza URL y headers (`Accept`, `Content-Type` JSON, timeout 10s).

## Componentes compartidos (16)

Bajo `lib/shared/`: `action_button`, `catalog_selector`, `cliente_info_card`, `cliente_list_tile`, `compact_list_item`, `data_chip`, `info_field`, `loading_card`, `message_box`, `metric_card`, `metric_line`, `number_input_control`, `quantity_button`, `section_title`, `status_badge`, `summary_card`.

Detalles y razones de cada extracción en [UI_STYLE_AUDIT_SUMMARY.md](UI_STYLE_AUDIT_SUMMARY.md).

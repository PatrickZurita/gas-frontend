# CLAUDE.md — Guía para Claude en `gas-frontend`

> Complementa [AGENTS.md](AGENTS.md) (gobernanza local, muy detallado) y [../AGENTS.md](../AGENTS.md) (raíz). Si hay conflicto, gana `AGENTS.md`.

## Contexto en una línea
App Flutter Android-first del MVP GAS para registrar pedidos de gas. Usuario adulto (50+) registra en la calle. Backend activo: PostgreSQL (Fly+Neon); AWS en standby.

## Misión actual
Preparar el frontend para **V2** (consumir contratos de anulación/edición/peso 10/45), luego **V3** (historial por fecha) y **V4** (tablet responsive). El móvil se mantiene simple; no se cambia el diseño aprobado. Plan: [../docs/roadmap/FRONTEND_UX_PLAN.md](../docs/roadmap/FRONTEND_UX_PLAN.md).

## Lo más importante que Claude debe respetar
- **No calcular stock/resumen crítico en Flutter**: el backend es source of truth. Refrescar tras crear/editar/anular, al volver a Home y al reanudar la app; no usar delays ni `ValueKey` como mecanismo principal.
- Anular pedido requiere confirmación visible; anulados no cuentan como vendidos/deuda.
- `peso_balon_kg` 10/45 (default 10, compat legacy); dinero de reportes en centavos (`int`), helper `formatSolesFromCentavos`.
- **No cambiar** `ThemeData`, `ColorScheme`, paleta, AppBar ni labels aprobados; `Registrar pedido` se queda primero en Home.
- Android-first: no iOS/web/desktop. Centralizar `baseUrl` (`10.0.2.2` emulador / IP LAN o backend desplegado en físico).
- No tocar `lib/**` (lógica) sin autorización; proponer diff revisable. No `git push`/`commit` sin pedirlo.

## Modelo recomendado
- Codex GPT-5.5: implementación, edición, integración, tests.
- Opus 4.7: auditoría UX adulto-first, revisión tablet/responsive y simplificación. [../docs/roadmap/MODEL_USAGE_STRATEGY.md](../docs/roadmap/MODEL_USAGE_STRATEGY.md).

## Skills relevantes
- `flutter-expert` (instalado en `.claude/skills/flutter-expert/`) — Flutter/Dart genérico.
- [gas-flutter-tablet-ux](../docs/codex-skills/gas-flutter-tablet-ux/SKILL.md) — V4 tablet.
- [gas-flutter-adult-first-ux](../docs/codex-skills/gas-flutter-adult-first-ux/SKILL.md), [gas-flutter-stock](../docs/codex-skills/gas-flutter-stock/SKILL.md), [gas-flutter-qa](../docs/codex-skills/gas-flutter-qa/SKILL.md).

## Cómo responder
Formato `Done / Files / Checks / Android / Risks / Next`. Modo caveman-lite para reportes rutinarios (ver [AGENTS.md](AGENTS.md)). Decisiones de UX/arquitectura: respuesta extendida.

## Checks
```powershell
flutter analyze
flutter test
```

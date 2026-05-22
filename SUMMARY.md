- Date: 2026-05-20 23:26:20 -05:00
- Commit analyzed: `f70d905` - `docs: guia build APK release contra backend Fly + bump pubspec.lock`
- Guide used: [docs/APK-BUILD-FLY.md](/C:/Users/PC/Documents/GitHub/gas-frontend/docs/APK-BUILD-FLY.md)

- Done:
  - Verificado backend publico `https://gas-backend-mvp.fly.dev` con `GET /health` -> `200 OK`.
  - Ejecutado `flutter pub get`.
  - Ejecutado `flutter analyze`.
  - Ejecutado `flutter test`.
  - Generado APK release con `flutter build apk --release --dart-define=API_BASE_URL=https://gas-backend-mvp.fly.dev`.
  - Copiado artefacto como `gas-app-fly-20260520-2326.apk`.

- Files:
  - [SUMMARY.md](/C:/Users/PC/Documents/GitHub/gas-frontend/SUMMARY.md)
  - [docs/APK-BUILD-FLY.md](/C:/Users/PC/Documents/GitHub/gas-frontend/docs/APK-BUILD-FLY.md)
  - [gas-app-fly-20260520-2326.apk](/C:/Users/PC/Documents/GitHub/gas-frontend/gas-app-fly-20260520-2326.apk)

- Checks:
  - `flutter doctor` -> Android toolchain OK, connected devices OK.
  - `flutter analyze` -> `No issues found!`
  - `flutter test` -> `61` tests passed.
  - `flutter build apk --release --dart-define=API_BASE_URL=https://gas-backend-mvp.fly.dev` -> OK.

- Android:
  - APK base: `build/app/outputs/flutter-apk/app-release.apk`
  - APK entrega: `gas-app-fly-20260520-2326.apk`
  - Size: `21,329,523` bytes (`20.3 MB`)
  - SHA256: `EEE52978BFD6D11A834ADE8F74CED327FB525A90D5ECFFAF713A87FA7947EC6F`

- Risks:
  - La guia declara Flutter `>= 3.41`, pero esta PC tiene `3.29.3`. No bloqueo build ni tests, pero la discrepancia debe corregirse si se estandariza la maquina de release.
  - `flutter pub get` con Flutter `3.29.3` intento reescribir `pubspec.lock` a versiones mas viejas compatibles; se restauro el lockfile a `HEAD` para no introducir ruido en el repo.
  - Release firmado con debug key segun [android/app/build.gradle.kts](/C:/Users/PC/Documents/GitHub/gas-frontend/android/app/build.gradle.kts).

- Next:
  - Instalar [gas-app-fly-20260520-2326.apk](/C:/Users/PC/Documents/GitHub/gas-frontend/gas-app-fly-20260520-2326.apk) en el Android final y ejecutar smoke manual corto.
  - Si esta PC sera la maquina oficial de release, alinear Flutter con la version minima documentada en la guia.
- Date: 2026-05-21 00:00 -05:00
- Task: Auditoria y ajuste de consistencia de stock/resumen diario en Home

- Done:
  - Auditado `Home`, stock, reportes y flujo de pedido para detectar si habia cache o refresh incompleto.
  - `Home` ahora reconsulta backend al volver desde pantallas hijas, al hacer pull-to-refresh y al reanudar la app.
  - Cambiado mecanismo de refresh para esperar respuestas reales del backend en stock, resumen y deudas.
  - Mejorado copy de ajuste de stock: `Ajuste manual +N/-N`.
  - Agregados tests widget para refresh al volver, pull-to-refresh y copy de ajuste.
  - Creado [STOCK_CONSISTENCY_AUDIT_SUMMARY.md](/C:/Users/PC/Documents/GitHub/gas-frontend/STOCK_CONSISTENCY_AUDIT_SUMMARY.md).

- Files:
  - [lib/home_screen.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/home_screen.dart)
  - [lib/features/stock/widgets/stock_hoy_section.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/stock/widgets/stock_hoy_section.dart)
  - [lib/features/reportes/widgets/resumen_dia_section.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/reportes/widgets/resumen_dia_section.dart)
  - [lib/features/reportes/widgets/deudas_pendientes_section.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/lib/features/reportes/widgets/deudas_pendientes_section.dart)
  - [test/widget_test.dart](/C:/Users/PC/Documents/GitHub/gas-frontend/test/widget_test.dart)
  - [STOCK_CONSISTENCY_AUDIT_SUMMARY.md](/C:/Users/PC/Documents/GitHub/gas-frontend/STOCK_CONSISTENCY_AUDIT_SUMMARY.md)

- Checks:
  - `flutter analyze` -> `No issues found!`
  - `flutter test` -> `64` tests passed.

- Android:
  - Sin smoke en dispositivo real en esta corrida.
  - El refresh de `Home` quedo preparado para reflejar mejor correcciones hechas fuera del flujo inmediato, pero hace falta validar el caso real en Android.

- Risks:
  - Si backend sigue contando pedidos eliminados/anulados en `/stock/resumen-hoy`, Flutter seguira mostrando el dato incorrecto despues de refrescar.
  - No existe en este repo un endpoint oficial de anulacion/eliminacion para revertir stock de pedido.

- Next:
  - Ejecutar smoke Android con caso de duplicado/anulacion real.
  - Si el dato sigue mal tras refresh, elevar ajuste de backend para recalculo consistente de stock/resumen.

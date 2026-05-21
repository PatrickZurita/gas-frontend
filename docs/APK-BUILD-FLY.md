# Build APK release apuntando al backend Fly.io (operativo)

> Esta guia es para tus agentes Flutter en la PC con Android SDK
> instalado. El backend ya esta desplegado en Fly + Neon y operativo.
> Aqui solo se genera el APK release apuntando a ese backend y se
> entrega para instalar en el dispositivo del usuario final.

## Estado verificado (2026-05-21)

- **Backend URL:** `https://gas-backend-mvp.fly.dev`
- **Backend live:** si — `/health` 200 OK, `POST /clientes/` 201, `/catalogos/tipos-balon` 200, `/reportes/deudas` 200.
- **DB:** Neon Postgres 17 (region `us-east-1`), 8 tablas creadas via Alembic.
- **Cliente de prueba en Neon:** `TestCliente` con `id=1` (no es bloqueante; puedes borrarlo manualmente despues si quieres).
- **Frontend ya soporta apuntar al backend remoto** via `--dart-define=API_BASE_URL=...` sin cambios de codigo. Ver [../lib/core/config/app_config.dart](../lib/core/config/app_config.dart).

## Pre-requisitos en la maquina del build

Validar antes de buildear:

```powershell
flutter doctor
```

Debe mostrar:

- `[√] Flutter (Channel stable, >= 3.41)`
- `[√] Android toolchain - develop for Android devices` (Android SDK + cmdline-tools + platform-tools)
- `[√] Connected device` (si quieres correr antes de buildear)

Si `flutter doctor` marca rojo en Android toolchain, instalar Android Studio o standalone Android command-line tools y aceptar licencias con `flutter doctor --android-licenses`.

## Build APK release apuntando a Fly

Desde la raiz del repo `gas-frontend`:

```powershell
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://gas-backend-mvp.fly.dev
```

**APK queda en:**

```
build/app/outputs/flutter-apk/app-release.apk
```

Renombrar con fecha para distribuir:

```powershell
$stamp = Get-Date -Format "yyyyMMdd-HHmm"
Copy-Item build\app\outputs\flutter-apk\app-release.apk "gas-app-fly-$stamp.apk"
```

## Probar antes de buildear (opcional, recomendado)

Con un dispositivo Android fisico conectado por USB (o emulador corriendo):

```powershell
flutter devices
flutter run --release --dart-define=API_BASE_URL=https://gas-backend-mvp.fly.dev -d <DEVICE_ID>
```

Smoke test manual en la app:

1. Abrir app — debe cargar sin errores de red.
2. Crear un cliente nuevo (boton "Nuevo cliente").
3. Buscar el cliente recien creado en la lista.
4. Registrar un pedido a ese cliente (cantidad 1, hoy).
5. Revisar historial del cliente — el pedido debe aparecer.
6. Ir a "Reportes / Deudas" — el pedido debe aparecer si lo marcaste como no pagado.

Si todos los pasos pasan, el APK release con el mismo flag esta listo para distribuir.

## Limitaciones a tener en cuenta

- **APK firmado con la debug key.** Ver [../android/app/build.gradle.kts](../android/app/build.gradle.kts) lineas 33-39. Suficiente para instalacion manual fuera de Play Store en MVP. Si quieres firmar con una key propia: ver [docs/flutter/build.html#sign-the-app](https://docs.flutter.dev/deployment/android#sign-the-app) y agregar `key.properties` (ya esta en `.gitignore`).
- **Cold start en Fly.** La primera request despues de varios minutos idle tarda 3 a 5 s (Fly arranca la VM bajo demanda). Despues responde en ~200 ms. La app debe mostrar un loader durante el primer hit.
- **Latencia.** Fly esta en Sao Paulo (`gru`) y Neon en `us-east-1` (Virginia). Latencia tipica ~200 ms desde Peru. Aceptable para MVP.
- **NO usar URL viejo de AWS Lambda.** El blocker `Function URL 403` sigue activo en AWS y la URL Lambda esta caida. Usar SOLO `https://gas-backend-mvp.fly.dev`.

## Aviso para el usuario final (cuando le entregas el APK)

```
Esta version de la app es de prueba. Tus pedidos se guardan bien
pero estamos migrando a la plataforma definitiva en las proximas
semanas. Te avisare cuando este lista. Registra tus pedidos
normalmente, los migrare yo manualmente sin que pierdas nada.
```

## Cuando AWS este listo (futuro)

Cuando se resuelvan los blockers AWS (ver `../../docs/aws/GAS-AWS-DEPLOY-STATUS.md` en el repo `gas-project`), la URL de produccion cambiara. El proceso sera:

1. Migrar datos Neon -> DynamoDB con `gas-backend/scripts/migrate-neon-to-ddb.py`.
2. Generar nuevo APK con la URL nueva:
   ```powershell
   flutter build apk --release --dart-define=API_BASE_URL=https://<nueva-url-aws>
   ```
3. Distribuir el APK nuevo al usuario final.
4. Apagar Fly app: `flyctl apps destroy gas-backend-mvp`.
5. Apagar Neon: Console -> Settings -> Delete project.

## Troubleshooting

| Sintoma | Causa probable | Fix |
|---------|----------------|-----|
| `flutter doctor` rojo en Android toolchain | Android SDK faltante | Instalar Android Studio o standalone cmdline-tools; correr `flutter doctor --android-licenses` |
| Build falla con `Gradle build failed` y SDK no detectado | `ANDROID_HOME` no seteado | `flutter config --android-sdk "C:\Users\<tu>\AppData\Local\Android\Sdk"` |
| App se abre pero no carga datos | `--dart-define` no aplicado al build | Re-buildear pasando `--dart-define=API_BASE_URL=https://gas-backend-mvp.fly.dev` |
| Timeout en primer request | Cold start Fly normal | Esperar 5 s, reintentar. Si persiste, `curl.exe https://gas-backend-mvp.fly.dev/health` desde la PC |
| Error 502/503 desde la app | Fly app caida | Avisar al equipo backend; `flyctl status --app gas-backend-mvp` o ver `https://fly.io/apps/gas-backend-mvp/monitoring` |

## Contacto

Cualquier inconsistencia en este documento, el estado del backend o el procedimiento: actualizar este mismo archivo y commitear a `main` en `gas-frontend`.

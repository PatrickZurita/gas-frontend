# Bootstrap Flutter Summary

## Fase
Fase 2: Bootstrap Flutter Android.

## Comandos ejecutados
- `Get-Content .\AGENTS.md`
- `flutter --version`
- `flutter doctor`
- `flutter devices`
- `flutter create --platforms=android --project-name gas_frontend .`
- `flutter pub get`
- `dart format lib test`
- `flutter analyze`
- `flutter test`
- `flutter emulators`

## Resultado de Flutter
- Flutter disponible: si.
- Version: `Flutter 3.29.3`, canal `stable`.
- Dart: `3.7.2`.
- DevTools: `2.42.3`.

## Resultado de flutter doctor
- `[OK] Flutter`: correcto.
- `[OK] Windows Version`: correcto.
- `[X] Android toolchain`: bloqueado, no encuentra Android SDK.
- `[!] Android Studio`: no instalado.
- `[OK] Chrome`: disponible, pero no es target del MVP.
- `[X] Visual Studio`: no instalado, irrelevante para Android-first.
- `[OK] Connected device`: hay dispositivos no Android.
- `[OK] Network resources`: correcto.

## Dispositivos detectados
- `Windows (desktop)`.
- `Chrome (web)`.
- `Edge (web)`.
- No se detecto emulador Android ni dispositivo Android fisico.

## Emuladores
- `flutter emulators` fallo porque no hay fuentes de emulador Android disponibles.
- Mensaje: `Unable to find any emulator sources. Please ensure you have some Android AVD images available.`

## Archivos creados o modificados
- `.gitignore`
- `.metadata`
- `analysis_options.yaml`
- `android/`
- `lib/main.dart`
- `lib/core/config/app_config.dart`
- `lib/core/network/.gitkeep`
- `lib/features/clientes/.gitkeep`
- `lib/features/pedidos/.gitkeep`
- `lib/shared/.gitkeep`
- `pubspec.yaml`
- `pubspec.lock`
- `test/widget_test.dart`
- `gas_frontend.iml`
- `.idea/`
- `BOOTSTRAP_FLUTTER_SUMMARY.md`

## Estructura final relevante
```txt
android/
lib/
  core/
    config/
      app_config.dart
    network/
      .gitkeep
  features/
    clientes/
      .gitkeep
    pedidos/
      .gitkeep
  shared/
    .gitkeep
  main.dart
test/
  widget_test.dart
pubspec.yaml
analysis_options.yaml
```

## Pantalla inicial creada
- Titulo claro: `Registrar pedidos`.
- Boton grande principal: `Nuevo pedido`.
- Boton secundario: `Buscar cliente`.
- Boton secundario: `Historial`.
- No tiene conexion real al backend.
- No implementa login, inventario, mapas, reportes ni pagos parciales.

## Configuracion central
- Archivo: `lib/core/config/app_config.dart`.
- Variable: `AppConfig.baseUrl`.
- Valor por defecto: `http://10.0.2.2:8000`.
- Puede cambiarse en build/run con:
  - `--dart-define=API_BASE_URL=http://IP_LAN:8000`

## Checks
- `flutter analyze`: correcto, sin issues.
- `flutter test`: correcto, 1 test aprobado.

## Como correr la app
Cuando exista Android SDK y un emulador o celular Android conectado:

```powershell
flutter devices
flutter run -d <ANDROID_DEVICE_ID>
```

Para backend local desde emulador Android, mantener:

```powershell
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Para celular fisico en la misma red LAN:

```powershell
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://<IP_DE_TU_PC>:8000
```

## Errores encontrados
- Android SDK no encontrado.
- Android Studio no instalado.
- No hay emulador Android disponible.
- No hay dispositivo Android fisico conectado.

## Siguiente paso recomendado
Instalar Android Studio con Android SDK, crear un AVD Android o conectar un celular fisico con depuracion USB, y luego ejecutar:

```powershell
flutter doctor
flutter devices
flutter run -d <ANDROID_DEVICE_ID>
```

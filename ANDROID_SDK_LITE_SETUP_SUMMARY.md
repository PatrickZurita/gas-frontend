# Android SDK Lite Setup Summary

## Diagnostico inicial
- Sistema operativo: Windows 10 Pro 64-bit, version `10.0.19045`.
- PowerShell: `5.1.19041.6456`.
- Flutter disponible: `Flutter 3.29.3`, Dart `3.7.2`.
- `flutter analyze`: ya estaba OK en fase previa.
- `flutter test`: ya estaba OK en fase previa.
- Android Studio: no instalado.
- Android SDK inicial: no existia en las rutas revisadas.

## Rutas revisadas
- `%LOCALAPPDATA%\Android\Sdk`: no existia al inicio.
- `C:\Android\Sdk`: no existia.
- `C:\Users\PC\AppData\Local\Android\Sdk`: no existia al inicio.

## Variables revisadas
- `ANDROID_HOME`: vacia al inicio.
- `ANDROID_SDK_ROOT`: vacia al inicio.
- `PATH`: no tenia entradas Android relevantes al inicio.
- `JAVA_HOME`: apuntaba a `C:\Program Files\Java\jdk-17.0.5`, pero esa ruta no existe.
- `java` en PATH: `C:\Program Files (x86)\Common Files\Oracle\Java\javapath\java.exe`.
- Version Java disponible por PATH: Java `1.8.0_361` 32-bit.

## Ruta SDK elegida
- `C:\Users\PC\AppData\Local\Android\Sdk`

## Comandos ejecutados
- `Get-Content .\AGENTS.md`
- `flutter config --list`
- `flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"`
- `java -version`
- `where.exe java`
- `Invoke-WebRequest -Uri https://developer.android.com/studio`
- `Start-BitsTransfer -Source https://dl.google.com/android/repository/commandlinetools-win-14742923_latest.zip`
- `Get-FileHash -Algorithm SHA1 commandlinetools-win-14742923_latest.zip`
- `Get-FileHash -Algorithm SHA256 commandlinetools-win-14742923_latest.zip`
- `Expand-Archive commandlinetools-win-14742923_latest.zip`
- `sdkmanager.bat --version`
- `flutter doctor`
- `flutter doctor --android-licenses`
- `flutter devices`

## Descarga oficial usada
- Pagina oficial: `https://developer.android.com/studio`
- Archivo: `commandlinetools-win-14742923_latest.zip`
- URL directa: `https://dl.google.com/android/repository/commandlinetools-win-14742923_latest.zip`
- Tamano descargado: `150532528` bytes.
- SHA-1 local: `16B3F45DDB3D85EA6BBE6A1C0B47146DAF0DB450`
- SHA-1 publicado en la pagina oficial: `16b3f45ddb3d85ea6bbe6a1c0b47146daf0db450`
- Nota: la pagina oficial muestra ese valor bajo una columna llamada SHA-256, pero el valor tiene longitud de SHA-1 y coincide con el SHA-1 local.

## Paquetes instalados
- Instalado/extractado:
  - `cmdline-tools;latest`
- No instalados todavia:
  - `platform-tools`
  - `build-tools`
  - `platforms;android-35`

## Motivo del bloqueo
`sdkmanager` no puede ejecutarse con el Java actual.

Salida:

```txt
Java version 17 or higher is required.
To override this check set SKIP_JDK_VERSION_CHECK
```

Tambien existe un `JAVA_HOME` roto:

```txt
JAVA_HOME=C:\Program Files\Java\jdk-17.0.5
```

Esa carpeta no existe.

## Variables configuradas
- `ANDROID_HOME` de usuario:
  - `C:\Users\PC\AppData\Local\Android\Sdk`
- `ANDROID_SDK_ROOT` de usuario:
  - `C:\Users\PC\AppData\Local\Android\Sdk`
- `PATH` de usuario, entradas agregadas sin borrar contenido previo:
  - `C:\Users\PC\AppData\Local\Android\Sdk\cmdline-tools\latest\bin`
  - `C:\Users\PC\AppData\Local\Android\Sdk\platform-tools`
- Flutter config:
  - `android-sdk = C:\Users\PC\AppData\Local\Android\Sdk`

## Resultado de flutter doctor
- Flutter: OK.
- Windows: OK.
- Android toolchain: bloqueado.
- Error principal:

```txt
ANDROID_HOME = C:\Users\PC\AppData\Local\Android\Sdk
but Android SDK not found at this location.
```

Esto pasa porque solo estan las command-line tools; faltan paquetes base que deben instalarse con `sdkmanager`.

## Resultado de flutter doctor --android-licenses
Salida:

```txt
Unable to locate Android SDK.
```

No llego a mostrar prompts de licencia porque el SDK aun no tiene paquetes base.

## Resultado de flutter devices
- `Windows (desktop)`
- `Chrome (web)`
- `Edge (web)`
- No se detecto celular Android.
- No se detecto emulador Android.

## Pendientes manuales
1. Instalar JDK 17 o superior sin Android Studio.
2. Corregir `JAVA_HOME` para que apunte al JDK real.
3. Instalar paquetes Android minimos con `sdkmanager`.
4. Aceptar licencias Android cuando `sdkmanager` o `flutter doctor --android-licenses` lo solicite.
5. Conectar celular Android con depuracion USB o configurar emulador despues.

## Comandos recomendados despues de instalar JDK 17
Abrir una nueva terminal y ejecutar:

```powershell
java -version
echo $env:JAVA_HOME
sdkmanager --install "platform-tools" "platforms;android-35" "build-tools;35.0.0"
flutter doctor --android-licenses
flutter doctor
flutter devices
```

Cuando aparezcan licencias, aceptar solo si estas de acuerdo con los terminos del Android SDK de Google.

## Siguiente paso recomendado
Instalar JDK 17 LTS en ZIP o MSI, corregir `JAVA_HOME`, y luego continuar con la instalacion de:

```txt
platform-tools
platforms;android-35
build-tools;35.0.0
```

No se instalo Android Studio completo, no se cambio codigo Flutter y no se agregaron dependencias.

---

## Continuacion: intento con JDK 17 Temurin

## Comandos ejecutados
- `Get-Content .\AGENTS.md`
- `java -version`
- `Write-Output "JAVA_HOME=$env:JAVA_HOME"`
- `sdkmanager --version`
- `Get-ChildItem 'C:\Program Files\Eclipse Adoptium'`
- `C:\Users\PC\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat --version`
- `sdkmanager --sdk_root=C:\Users\PC\AppData\Local\Android\Sdk --install "platform-tools" "platforms;android-35" "build-tools;35.0.0"`
- `flutter doctor --android-licenses`
- `flutter doctor`
- `flutter devices`
- `sdkmanager --sdk_root=C:\Users\PC\AppData\Local\Android\Sdk --list_installed`

## Verificacion Java
La terminal inicial todavia tenia Java antiguo en PATH:

```txt
java version "1.8.0_361"
Java(TM) SE Runtime Environment (build 1.8.0_361-b09)
```

Se encontro JDK 17 instalado en:

```txt
C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot
```

Usando esa ruta en la sesion, Java correcto:

```txt
openjdk version "17.0.18" 2026-01-20
OpenJDK Runtime Environment Temurin-17.0.18+8
OpenJDK 64-Bit Server VM Temurin-17.0.18+8
```

## JAVA_HOME
Antes de corregir variables:

```txt
Machine JAVA_HOME=C:\Program Files\Java\jdk-17.0.5
```

Esa ruta no existe.

Se configuro `JAVA_HOME` de usuario a:

```txt
C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot
```

Tambien se agrego al PATH de usuario, sin borrar entradas previas:

```txt
C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin
```

Nota: queda una entrada rota antigua en PATH de usuario:

```txt
C:\Program Files\Java\jdk-17.0.5\bin
```

No se elimino para evitar cambios destructivos en PATH.

## Resultado de sdkmanager
Con `JAVA_HOME` apuntando temporalmente a Temurin 17, `sdkmanager` funciona:

```txt
sdkmanager --version
20.0
```

## Intento de instalacion de paquetes
Comando ejecutado:

```powershell
sdkmanager --sdk_root=C:\Users\PC\AppData\Local\Android\Sdk --install "platform-tools" "platforms;android-35" "build-tools;35.0.0"
```

Resultado: `sdkmanager` mostro la licencia `android-sdk-license` y pidio aceptar:

```txt
Accept? (y/N):
```

No se acepto automaticamente.

Como la licencia no fue aceptada, se omitieron estos paquetes:

```txt
Android SDK Build-Tools 35
Android SDK Platform-Tools
Android SDK Platform 35
```

Paquetes que siguen sin instalarse:

```txt
build-tools;35.0.0
platforms;android-35
platform-tools
```

## Resultado de flutter doctor --android-licenses
Salida:

```txt
Unable to locate Android SDK.
```

Motivo: todavia faltan los paquetes base del SDK porque la licencia no fue aceptada.

## Resultado de flutter doctor
Android sigue bloqueado:

```txt
ANDROID_HOME = C:\Users\PC\AppData\Local\Android\Sdk
but Android SDK not found at this location.
```

Flutter, Windows, Chrome, VS Code, dispositivos conectados y red aparecen como detectados. Visual Studio sigue fallando, pero no importa para Android-first.

## Resultado de flutter devices
Solo hay dispositivos no Android:

```txt
Windows (desktop)
Chrome (web)
Edge (web)
```

No hay celular Android conectado ni emulador Android configurado.

## Estado actual de paquetes instalados
Solo existe:

```txt
cmdline-tools
```

`sdkmanager --list_installed` no mostro paquetes base instalados.

## Pendientes manuales
1. Abrir una terminal nueva para que tome `JAVA_HOME` de usuario.
2. Verificar:

```powershell
java -version
echo $env:JAVA_HOME
sdkmanager --version
```

3. Ejecutar:

```powershell
sdkmanager --sdk_root=C:\Users\PC\AppData\Local\Android\Sdk --install "platform-tools" "platforms;android-35" "build-tools;35.0.0"
```

4. Cuando aparezca la licencia `Android Software Development Kit License Agreement`, aceptar manualmente escribiendo:

```txt
y
```

Solo aceptarla si estas de acuerdo con los terminos de Google.

5. Luego ejecutar:

```powershell
flutter doctor --android-licenses
flutter doctor
flutter devices
```

## Siguiente paso recomendado
Aceptar manualmente la licencia Android SDK desde una terminal nueva y repetir la instalacion de paquetes minimos. Despues conectar un celular Android con depuracion USB para validar `flutter devices` y `flutter run`.

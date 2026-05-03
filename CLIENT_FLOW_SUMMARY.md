# Client Flow Summary

## Fase
Fase 4: flujo cliente.

## Archivos creados
- `lib/home_screen.dart`
- `lib/shared/action_button.dart`
- `lib/features/clientes/screens/buscar_cliente_screen.dart`
- `lib/features/clientes/screens/crear_cliente_screen.dart`
- `lib/features/clientes/screens/cliente_seleccionado_screen.dart`
- `CLIENT_FLOW_SUMMARY.md`

## Archivos modificados
- `lib/main.dart`
- `lib/features/clientes/cliente_service.dart`
- `test/api_services_test.dart`
- `test/widget_test.dart`

## Flujo implementado
- Home:
  - `Buscar cliente` abre la pantalla de busqueda.
  - `Nuevo pedido` tambien abre busqueda de cliente por ahora.
  - `Historial` queda deshabilitado porque no corresponde a esta fase.
- Buscar cliente:
  - Campo grande para direccion, alias o telefono.
  - Boton grande `Buscar`.
  - Lista tipo contacto con direccion/alias y telefono.
  - Mensaje si no hay resultados.
  - Boton grande `Crear nuevo cliente`.
- Crear cliente:
  - Campo `Direccion / Alias`.
  - Campo `Telefono`.
  - Boton grande `Guardar cliente`.
  - Validacion minima de direccion.
  - Validacion minima de telefono.
  - Manejo de `ClienteDuplicadoException` para `409`.
  - Mensajes claros de exito o error.
- Cliente seleccionado:
  - Muestra direccion y telefono.
  - No registra pedido todavia.

## Decisiones UX
- Botones de 64 a 72 px de alto para toque facil en Android.
- Texto grande en campos, resultados y acciones.
- Una accion principal por pantalla.
- Lista de resultados tipo contacto.
- Mensajes visibles dentro de la pantalla, sin dialogs innecesarios.
- Navegacion simple con `Navigator` y `MaterialPageRoute`.
- No se agrego routing package ni state management externo.

## Decisiones tecnicas
- `main.dart` ahora solo arma `ApiClienteService(ApiClient())` y carga `HomeScreen`.
- `ClienteService` quedo como interfaz para permitir tests con fake service.
- `ApiClienteService` mantiene la implementacion real contra backend.
- Se reutilizo `ActionButton` para mantener botones grandes consistentes.
- No se tocaron endpoints ni backend.

## Como probar manualmente
Con backend corriendo y Android listo:

```powershell
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://<IP_LAN_PC>:8000
```

En emulador Android:

```powershell
flutter run -d <ANDROID_DEVICE_ID> --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Smoke manual:
- Abrir app.
- Tocar `Buscar cliente`.
- Escribir una direccion existente.
- Tocar `Buscar`.
- Seleccionar un resultado.
- Ver pantalla `Cliente seleccionado`.
- Volver.
- Tocar `Crear nuevo cliente`.
- Probar guardar vacio y confirmar validacion.
- Crear cliente con direccion y telefono validos.
- Probar cliente duplicado y confirmar mensaje del backend.

## Resultado de flutter analyze

```txt
No issues found!
```

## Resultado de flutter test

```txt
All tests passed!
```

Total observado: `14` tests aprobados.

## Riesgos o pendientes
- No se probo contra backend real en esta corrida.
- En celular fisico, `10.0.2.2` no sirve; usar IP LAN o backend desplegado.
- `Nuevo pedido` aun solo lleva a buscar cliente.
- `Historial` sigue deshabilitado.
- No hay pantalla de pedido todavia.

## Siguiente paso recomendado
Implementar Fase 5: registrar pedido para un cliente seleccionado, con cantidad por defecto `1`, pagado/no pagado y total en soles.

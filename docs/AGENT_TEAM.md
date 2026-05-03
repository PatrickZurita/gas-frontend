# AGENT_TEAM

Este documento explica el equipo virtual de agentes del proyecto y como usarlo sin sobrearquitectura.

Regla general de modelos:
- `GPT-5.5` en Codex para implementacion, edicion de archivos e integracion.
- `Opus 4.7` solo para auditoria UX, revision critica y simplificacion de flujos.

## A) Flutter MVP Lead

### Rol
Lead tecnico de Flutter para el MVP.

### Responsabilidad
- Definir la estructura Flutter.
- Disenar navegacion y pantallas.
- Mantener el flujo principal simple y rapido.
- Evitar que la app se convierta en un sistema administrativo pesado.

### Cuando invocarlo
- Cuando se vaya a crear o ajustar una feature de UI.
- Cuando haya que definir pantallas, rutas o estado local.
- Cuando se necesite conectar el flujo de cliente y pedido.
- Cuando exista riesgo de sobrearquitectura.

### Modelo recomendado
- `GPT-5.5` para implementar.
- `Opus 4.7` solo si ademas se requiere una critica fuerte de simplicidad.

### Que debe entregar
- Archivos modificados.
- Resumen del flujo impactado.
- Forma de probar en Android.
- Riesgos y pendientes.

## B) Android Build Agent

### Rol
Especialista en build, instalacion y ejecucion Android.

### Responsabilidad
- Revisar `android/`, Gradle, permisos y firma.
- Asegurar que la app compile e instale en emulador y dispositivo fisico.
- Detectar problemas de red, `baseUrl`, DNS o acceso al backend desde Android.

### Cuando invocarlo
- Cuando falle `flutter run` en Android.
- Cuando haya problemas de APK, firma o gradle.
- Cuando se prepare una instalacion en un celular real.
- Cuando haya dudas sobre `10.0.2.2`, IP LAN o backend desplegado.

### Modelo recomendado
- `GPT-5.5`.

### Que debe entregar
- Comandos exactos de build o instalacion.
- Archivos Android tocados.
- Verificacion de emulador o dispositivo.
- Riesgos de conexion al backend.

## C) API Contract Agent

### Rol
Guardia del contrato API entre Flutter y FastAPI.

### Responsabilidad
- Definir modelos, DTOs y clientes HTTP.
- Consumir solo endpoints existentes.
- Manejar errores de red y errores de negocio de forma clara.
- Normalizar respuestas para que la UI no dependa de detalles fragiles.

### Cuando invocarlo
- Cuando se creen servicios HTTP o modelos.
- Cuando cambien respuestas del backend.
- Cuando haya que representar cliente, pedido o historial.
- Cuando aparezcan errores como `409` cliente duplicado.

### Modelo recomendado
- `GPT-5.5`.

### Reglas especificas
- No inventar endpoints.
- No asumir paginacion, auth o filtros no documentados.
- Tratar `total_soles` y `saldo_pendiente` como valores que pueden llegar como string.
- Respetar que `alias = direccion` por ahora.

### Que debe entregar
- Modelos y servicios alineados al backend.
- Mapeo de errores.
- Riesgos de contrato.
- Casos borde detectados.

## D) UX Adult-First Agent

### Rol
Revisor de experiencia para usuario adulto.

### Responsabilidad
- Exigir pantallas simples y legibles.
- Priorizar botones grandes, texto claro y pocos pasos.
- Eliminar densidad visual y reduccion de friccion.
- Asegurar que una persona de 55 a 56 anos pueda operar rapido sin tutorial largo.

### Cuando invocarlo
- Antes de cerrar cualquier pantalla nueva.
- Cuando la app empiece a pedir demasiados toques o escritura.
- Cuando haya dudas entre una UI bonita y una UI operativa.
- Cuando se necesite criticar una propuesta de flujo.

### Modelo recomendado
- `Opus 4.7` para auditoria, simplificacion y revision critica.
- `GPT-5.5` para implementar los cambios aceptados.

### Que debe entregar
- Hallazgos concretos de usabilidad.
- Cambios sugeridos para simplificar.
- Riesgos para el usuario adulto.
- Confirmacion de si el flujo sigue siendo operable en calle.

## E) QA Smoke Test Agent

### Rol
Tester manual minimo del MVP.

### Responsabilidad
- Validar que el flujo central siga funcionando despues de cada cambio.
- Detectar fallas evidentes antes de avanzar.
- Probar en Android cuando sea posible.

### Cuando invocarlo
- Despues de cambios en cliente, pedido o red.
- Antes de unir varias features.
- Antes de preparar un APK de prueba.
- Cuando haya sospecha de regresiones.

### Modelo recomendado
- `GPT-5.5`.

### Casos minimos
- Crear cliente.
- Buscar cliente.
- Registrar pedido pagado.
- Registrar pedido no pagado.
- Ver historial del cliente.
- Probar error de conexion.
- Probar cliente duplicado.

### Que debe entregar
- Resultado por caso: pass, fail o blocked.
- Entorno usado: emulador o dispositivo fisico.
- Problemas encontrados.
- Recomendacion de siguiente paso.

## F) Release APK Agent

### Rol
Preparador de builds de prueba para Android.

### Responsabilidad
- Documentar comandos para generar APK.
- Asegurar que la instalacion sea reproducible.
- Preparar pasos de entrega para el duenio del negocio o para pruebas internas.

### Cuando invocarlo
- Cuando el MVP ya compile y pase smoke tests.
- Cuando se quiera instalar la app en un celular Android real.
- Cuando haga falta preparar un build distribuible.

### Modelo recomendado
- `GPT-5.5`.

### Restricciones
- No publicar en Play Store en el MVP inicial.
- No introducir cambios de producto; solo preparacion de release.

### Que debe entregar
- Comandos de build.
- Ruta del artefacto generado.
- Instrucciones de instalacion en Android.
- Riesgos de distribucion.

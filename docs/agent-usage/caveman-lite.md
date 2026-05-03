# Caveman-lite agent usage

## Que es

Caveman-lite es una disciplina de salida breve para este repo Flutter Android. Reduce tokens en reportes rutinarios sin cambiar el flujo de agentes, sin activar hooks, sin instalar plugins y sin afectar documentacion formal.

No es modo caveman completo. Mantiene gramatica clara, terminos tecnicos exactos y riesgos visibles.

## Cuando usarlo

Usarlo cuando el usuario lo pida o cuando la salida sea rutinaria:

- Reporte de implementacion Flutter.
- QA smoke summary.
- Resumen de `flutter analyze`.
- Resumen de `flutter test`.
- Plan de commit.
- Respuesta de PR review.
- Resumen de build APK o instalacion Android.
- Resumen de "que cambio / archivos / checks / riesgos / siguiente paso".

## Cuando no usarlo

No usarlo para:

- Decisiones arquitectonicas Flutter.
- Dudas de contrato API o payloads no confirmados.
- Debugging profundo de Gradle o Android SDK.
- Problemas de `10.0.2.2`, IP LAN, DNS o backend desplegado.
- Explicaciones de despliegue backend, costos o infraestructura.
- Analisis de `HTTP` vs `HTTPS`, certificados o seguridad.
- UX adulto-first cuando se necesite razonamiento completo.
- Documentacion formal de handoff.

## Prompts cortos reutilizables

```md
Modo caveman-lite: breve, tecnico, sin relleno. No omitas riesgos criticos.
```

```md
Resume en caveman-lite: Done / Files / Checks / Android / Risks / Next.
```

```md
QA en caveman-lite: casos, dispositivo, resultado, riesgos, siguiente paso.
```

```md
Build en caveman-lite: comando, APK, dispositivo, riesgos, siguiente paso.
```

```md
PR review en caveman-lite: hallazgo, archivo, riesgo, fix.
```

## Forma recomendada

```md
- Done:
- Files:
- Checks:
- Android:
- Risks:
- Next:
```

Para QA:

```md
- Done:
- Cases:
- Device:
- Result:
- Risks:
- Next:
```

Para build o release:

```md
- Done:
- Build:
- APK:
- Install:
- Risks:
- Next:
```

Para commit planning:

```md
- Type:
- Scope:
- Subject:
- Body:
- Risks:
```

## Ejemplos antes/despues

Antes:

```md
Se implemento la pantalla principal de busqueda de clientes y tambien se agrego la logica inicial para registrar pedidos. Ademas se reviso que el emulador pudiera conectarse al backend local usando la configuracion actual.
```

Despues:

```md
- Done: Agregada busqueda de clientes y registro de pedido.
- Files: `lib/features/clientes/...`, `lib/features/pedidos/...`.
- Checks: `flutter analyze`.
- Android: Emulador con `10.0.2.2`.
- Risks: Falta validar en celular real.
- Next: Probar con IP LAN.
```

Antes:

```md
Durante la validacion manual se pudo confirmar que el flujo de crear cliente funciona, pero todavia no se verifico correctamente el caso de error de conexion desde un dispositivo Android fisico.
```

Despues:

```md
- Done: Crear cliente validado.
- Cases: Crear cliente pass; error de conexion blocked.
- Device: Emulador Android.
- Result: Parcial.
- Risks: Sin prueba real en celular.
- Next: Probar backend desde IP LAN.
```

## Como pedir respuestas compactas sin perder informacion critica

Usar caveman-lite con una forma explicita y exigir riesgos:

```md
Modo caveman-lite. Formato: Done / Files / Checks / Android / Risks / Next. No omitas riesgos criticos ni dudas de contrato.
```

Para debugging complejo, pedir salida normal:

```md
No uses caveman-lite. Necesito razonamiento completo, causas posibles y pasos de verificacion.
```

Para despliegue backend, `HTTP/HTTPS` o networking Android, pedir salida normal:

```md
No comprimas esta respuesta. Necesito explicacion completa de red, dominio y certificados.
```

## Integracion local

Este repo usa caveman-lite como disciplina de respuesta, no como plugin ni hook automatico.

No ejecutar `caveman` con `--all` ni `--with-init` en este repo si quieres preservar el flujo actual de agentes. Esas opciones pueden escribir reglas always-on en `AGENTS.md`.

Si alguna vez se usa el ecosistema `caveman` aqui, la opcion segura es instalacion minima y activacion manual, nunca auto-activacion global.

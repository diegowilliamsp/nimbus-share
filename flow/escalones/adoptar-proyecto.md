# Escalón: adoptar-proyecto — registrar un proyecto existente en NIMBUS

> **Escalón del flujo NIMBUS.** Adopta un proyecto que YA existe (con código, sin docs NIMBUS) para que de aquí en adelante siga el flujo. Asume el **piso** cargado. No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- "tengo este proyecto y quiero adoptarlo con NIMBUS" / "adopta este proyecto con NIMBUS" / "registra este proyecto en NIMBUS" / "usa NIMBUS en este proyecto" / "quiero usar NIMBUS aquí".
- Es el puente entre los otros dos: distinto de `proyecto-nuevo` (desde cero, sin código) y de `proyecto-continuar` (que asume que el proyecto YA tiene sus docs NIMBUS). Este aplica cuando hay **código existente pero todavía no hay docs NIMBUS**.

## Dependencias declaradas

- Usa las skills `/init` (genera `CLAUDE.md` desde el código) y `/grill-with-docs` (captura visión/dominio → `CONTEXT.md`).
- Setup de pre-commit → escalón `mecanica-git`.
- Tras adoptar, el proyecto sigue por el escalón `proyecto-continuar`.

---

Un proyecto "vive" en NIMBUS cuando tiene sus cuatro documentos: `CLAUDE.md`, `CONTEXT.md`, `ESTADO.md` y la carpeta `decisions/`. **Adoptar = crearle esa estructura a un proyecto que ya existe, sin reescribir su código.**

1. **Verificar el punto de partida.** Confirmar que hay código y que NO existen ya los docs NIMBUS. Si el proyecto ya los tiene → esto es `proyecto-continuar`, no adopción.
2. **`CLAUDE.md` desde el código** → correr `/init` para que lea el codebase y autogenere las convenciones detectadas (stack, comandos de test/lint, estructura, gotchas). Revisar y ajustar con el usuario.
3. **`CONTEXT.md` con la visión** → correr `/grill-with-docs`: grillar el para-qué, para quién, el lenguaje del dominio y las restricciones del proyecto existente, contra el código real. Escribir el resultado en `CONTEXT.md`. Voice-friendly.
4. **`ESTADO.md` con el ahora** → crear el diario vivo: en qué está el proyecto hoy, qué se hizo, qué sigue (la próxima rebanada), blockers. No inventar — sacarlo de lo que el usuario diga + lo que muestre el código.
5. **`decisions/`** → crear la carpeta (con un `.gitkeep`) para los ADRs futuros. Si ya hay decisiones grandes tomadas que el usuario quiera dejar registradas, documentarlas como ADRs iniciales.
6. **Pre-commit** → si el proyecto no tiene, proponer setup según el stack (escalón `mecanica-git`).
7. **Cierre** → confirmar en una línea: *"Proyecto adoptado en NIMBUS: ya tiene `CLAUDE.md`, `CONTEXT.md`, `ESTADO.md` y `decisions/`. De aquí en adelante seguimos el flujo normal — dime qué rebanada sigue."*

A partir de la adopción, el proyecto sigue por `proyecto-continuar` (retomar) con el candado y los escalones aplicando normal.

## Regla

- **NO reescribir ni refactorizar el código existente durante la adopción.** La adopción crea documentación y estructura, no toca la lógica. Si el usuario quiere refactors o mejoras, eso es trabajo de rebanada aparte, con su propio Definition of Ready.

# Escalón: proyecto-continuar — retomar existente

> **Escalón del flujo NIMBUS (v3 — carga por escalones, ver [`decisions/004`](../../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- "sigamos con [proyecto]" / "continuemos con [X]" / "retomemos [X]" / cualquier inicio de trabajo no-trivial sobre un proyecto que ya existe.

## Dependencias declaradas

- **Paso 1** lee los documentos del proyecto en orden `CLAUDE.md` → `CONTEXT.md` → `ESTADO.md` + `decisions/`. Qué responde cada uno: `CLAUDE.md` = reglas operativas del proyecto; `CONTEXT.md` = visión, dominio y restricciones; `ESTADO.md` = dónde quedó la última sesión y qué sigue; `decisions/NNN-*.md` = por qué se eligió o descartó algo.
- **Paso 4** (rebanada ambigua) usa las skills `/grill-me` o `/grill-with-docs`.
- **Paso 5** (antes de ejecutar la rebanada) encadena con el escalón `rebanada-ready` (DoR + recomendación de effort).
- **Al cerrar una rebanada** encadena con el escalón `rebanada-done` (Definition of Done).
- **Paso 6** (cerrar sesión) encadena con el escalón `cierre-sesion`.

---

1. **Leer los documentos del proyecto en este orden:** `CLAUDE.md` → `CONTEXT.md` → `ESTADO.md` + vistazo a `decisions/` si tiene entradas. Si alguno no existe, decírselo al usuario y proponer crearlo.

2. **Resumir al usuario en 3-5 líneas** dónde quedó: qué se hizo última sesión, qué quedó pendiente, qué blockers hay. Sacado de `ESTADO.md`, no de la memoria.

3. **Preguntar qué rebanada sigue.** Confirmar con el usuario antes de moverte — la memoria envejece, el código es la verdad, pero el usuario tiene la última palabra sobre prioridades.

4. Si la rebanada es ambigua o trae decisiones nuevas → grill corto (`/grill-me` o `/grill-with-docs`) antes de codear. Aplicar las reglas de comunicación (preguntar todo, no asumir).

5. **Ejecutar la rebanada.** Verificar. Commit.

6. **Cerrar sesión** → ejecutar el escalón `cierre-sesion`. Obligatorio, no opcional.

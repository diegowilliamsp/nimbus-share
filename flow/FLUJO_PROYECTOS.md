# Flujo de trabajo en proyectos — NIMBUS v3

Este documento define cómo empezar o continuar un proyecto de software con Claude Code. Aplica a trabajo no-trivial sobre proyectos, no a fixes chiquitos ni a preguntas sueltas.

## Cómo funciona NIMBUS v3 (carga por escalones)

NIMBUS ya no es un solo documento que se carga entero. Son tres piezas:

- **Piso:** lo que se carga SIEMPRE en cada sesión — el `CLAUDE.md` global (principios rectores, roles del meta-sistema, reglas de comunicación, + el bloque `claude-flow-proyectos` con el resumen de triggers y el candado) MÁS el `CLAUDE.md` del proyecto activo. **Este overview NO es piso** — se lee bajo demanda, no en cada sesión (piso delgado).
- **Escalones:** cada sub-protocolo es un archivo autónomo en `flow/escalones/<nombre>.md`. Solo se carga el que la tarea pide, no todo el flujo.
- **Router + candado:** `flow/ROUTER.md` (entregado por un hook en cada turno) mapea la tarea a sus escalones. Antes de trabajo de proyecto, el candado obliga al Constructor a declarar al Director qué escalón(es) y qué effort usa, para que apruebe o ajuste. La declaración va en el **bloque ESTATUS enmarcado al final** de cada respuesta (nunca omite áreas: veredicto + 💾 guardado + effort con medidor y `/effort` (+ sub-línea 🎭 roles del pipeline siempre debajo — 👷 directo por default) + escalones + medidor de contexto/sesión con `/compact`·`/clear` según banda; el hook calcula 💾 y el medidor; formato en `flow/ROUTER.md` §Candado).

Este archivo es el **overview**: el preámbulo de referencia (universal) + el índice de escalones. Se lee bajo demanda, no es piso. El detalle de cada sub-protocolo vive en su escalón.

## Cuándo aplica

- "Vamos a trabajar en un proyecto nuevo"
- "Empecemos [feature/proyecto]"
- "Sigamos con [proyecto]"
- Cualquier inicio de trabajo no-trivial sobre un proyecto

## Cuándo NO aplica

Lista canónica en `flow/ROUTER.md` §"Cuándo NO aplica NIMBUS (escalón 0)": bugs chiquitos, ajustes de una línea, dudas, exploración rápida, preguntas sobre cómo funciona algo, y los overrides ("skip grill", "directo al código", "solo arregla X", "modo rápido"). En esos casos la declaración del candado es "escalón 0 — nada que cargar".

## Principio rector

**Visión completa arriba (escrita una sola vez). Ejecución por rebanadas verticales pequeñas (una a la vez).**

Lo que NO se hace:
- NO planear 5 etapas × 30 pasos al inicio. La rebanada 8 solo se diseña cuando la 7 ya funciona.
- NO dar el 100% del proyecto al modelo de un jalón — el modelo asume cosas que no autorizaste y rompe en cascada.
- NO ir paso-a-paso sin tener la visión escrita arriba — cada paso te obliga a re-explicar el "para qué".

Lo que SÍ se hace:
- Visión + restricciones documentadas en `CONTEXT.md` del proyecto.
- Rebanadas verticales: cada una funciona end-to-end, lo más chiquita posible pero útil.
- Una rebanada a la vez. Verificar que jala. Commit. Siguiente.
- Estado vivo del proyecto en `ESTADO.md` — siempre actualizado al cerrar sesión.
- **Bias a continuidad:** no introducir nuevas tools, convenciones, patrones ni dependencias sin razón fuerte. Cada cosa nueva añade superficie de mantenimiento (aplicado a tooling en el escalón `evaluacion-herramientas`).

## Principio de paridad voz ↔ texto

NIMBUS se puede invocar de dos formas:

1. **Directo a Claude Code** (texto en terminal o IDE).
2. **Vía una capa de voz** (un asistente de voz que escucha, decide que la tarea requiere Claude Code, y lo invoca como herramienta).

**El resultado tiene que ser el mismo en ambos caminos.** El medio (voz vs texto) no debe cambiar lo que se logra ni la calidad del trabajo.

**Implicaciones al redactar este flujo:**

- **Voice-friendly por default.** Cualquier sección nueva se escribe pensando que la cadena puede ser voz → asistente → Claude Code → resultado → el asistente verbaliza → tú escuchas.
- **Evitar `AskUserQuestion` en puntos críticos del puente voz.** Las preguntas que Claude Code abre con `AskUserQuestion` viven en su chat; una capa de voz no las ve ni las puede verbalizar. Cuando una sección requiera input del usuario en pleno trabajo vía voz, redactar para que la pregunta salga como **texto en la respuesta** — el asistente la verbaliza, tú respondes por voz, y te la reenvía en otro turno. `AskUserQuestion` sigue siendo válido para invocaciones directas con texto.
- **Handoffs en prosa simple.** Resultados, resúmenes y preguntas se redactan en prosa, sin markdown obligatorio que se pierda al verbalizarse. Markdown opcional cuando ayuda en lectura directa pero no rompe al ser leído por TTS.

**Limitaciones conocidas (son del medio, no del flujo):**

- Mostrar diffs visuales, gráficas o tablas largas — solo aplica a invocación directa.
- Cargar archivos grandes como contexto.
- Operaciones que requieren ver pantalla del usuario.

Si no usas una capa de voz, ignora esta sección: el flujo funciona igual en texto directo.

## Los documentos del proyecto

Cada proyecto tiene cuatro piezas de documentación vivas en su raíz. Cada una responde una pregunta distinta:

| Doc | Pregunta que responde | Frecuencia de cambio |
|---|---|---|
| `CLAUDE.md` | ¿Qué reglas debo seguir cuando trabaje en este proyecto? | Casi nunca — solo cuando cambian las reglas |
| `CONTEXT.md` | ¿De qué se trata, para qué, para quién, en qué lenguaje del dominio? | Bajo — se actualiza cuando hay decisiones grandes |
| `ESTADO.md` | ¿Dónde quedó la última sesión y qué sigue? | Alto — se actualiza al cerrar cada sesión |
| `decisions/NNN-<nombre>.md` | ¿Por qué llegamos a esta forma del proyecto? | Append-only — una entrada nueva por decisión técnica grande |

**`CLAUDE.md`** — instrucciones operativas para Claude. Stack, convenciones de código, comandos de test/lint, gotchas del proyecto, "no toques X", "siempre usa Y". Lo carga Claude automáticamente al abrir el proyecto.

**`CONTEXT.md`** — visión + dominio. Para qué sirve el proyecto, quién es el usuario, restricciones duras, must-haves / must-NOTs, glosario de términos del dominio. Lectura obligatoria al retomar.

**`ESTADO.md`** — diario vivo. Rebanada actual, hechas, próxima, notas de la sesión, blockers, notas para retomar. Lectura obligatoria al retomar.

**`decisions/`** — carpeta con un archivo por decisión técnica significativa (ADRs estilo Michael Nygard). Numerados secuencial: `001-<nombre>.md`, `002-<nombre>.md`, etc. NO se borran — se marcan como "Reemplazado por NNN" cuando aplica. Es el historial de cómo el proyecto llegó a su forma actual. Plantilla en el escalón `evaluacion-herramientas`.

**Regla de oro — dónde va cada cosa:**
- ¿Es regla operativa que aplica siempre? → `CLAUDE.md`
- ¿Es información del proyecto que sigue siendo cierta dentro de 3 meses? → `CONTEXT.md`
- ¿Cambiará la próxima sesión? → `ESTADO.md`
- ¿Es una decisión técnica con alternativas evaluadas y descartadas? → `decisions/NNN-<nombre>.md`

**Sub-regla — `ESTADO.md` "Notas de la sesión" vs `decisions/`:**

- `decisions/NNN-<nombre>.md` = decisión que cambia el rumbo del proyecto, con alternativas evaluadas formalmente. Append-only. Usa la plantilla ADR (escalón `evaluacion-herramientas`).
- "Notas de la sesión" en `ESTADO.md` = bitácora corta de decisiones de implementación tomadas en la sesión, sin formato ADR.

Test rápido: si vale la pena que el "yo del futuro" entienda **por qué no se eligió otra opción** → `decisions/`. Si es "elegí lib X porque ya estaba en el proyecto" o "renombré la función Y" → `ESTADO.md`.

## Reglas de comunicación

**Preguntar TODO lo necesario antes de codear. NUNCA asumir.**

- Hacer todas las preguntas que hagan falta para no construir lo que no era. Es preferible 10 preguntas al inicio que 2 horas tirando código equivocado.
- Una pregunta a la vez (a menos que sean independientes y rápidas).
- Si una pregunta se puede responder leyendo el código o un doc del proyecto → leerlo en vez de preguntar.
- Para cada pregunta, ofrecer la respuesta recomendada con su tradeoff. El usuario aprueba o redirige — no lo dejes elegir a ciegas.
- No avanzar a "construir" mientras haya ambigüedad sobre qué se va a construir.

Esto NO significa interrogatorio infinito: cuando ya hay claridad suficiente para la rebanada actual, parar de preguntar y ejecutar. La meta es certeza para el siguiente paso, no certeza para los siguientes 10.

**Criterio para decidir si preguntar o no:**

- ¿La respuesta cambia lo que vas a construir HOY (esta rebanada)? → preguntar.
- ¿Solo afecta rebanadas futuras? → no preguntar todavía. Anotar la duda en `ESTADO.md` ("pendiente: X") y atacarla cuando llegue su turno.
- ¿Se puede responder leyendo código o doc del proyecto? → leer, no preguntar.
- ¿Es preferencia de estilo o naming sin impacto técnico? → proponer una opción y seguir, salvo que el usuario haya marcado preferencias antes.
- ¿Es decisión arquitectónica que afecta varias rebanadas futuras? → preguntar AHORA aunque no sea para hoy. Las decisiones arquitectónicas baratas se vuelven caras después.

## Índice de escalones

Cada escalón es un archivo autónomo en `flow/escalones/`. Aquí está el mapa humano (escalón → para qué). **El mapeo operativo trigger→escalón vive en `flow/ROUTER.md` (fuente de verdad, entregada por hook).** El detalle de cada sub-protocolo vive en su archivo.

| Escalón | Para qué |
|---|---|
| [`ideas-crudas`](./escalones/ideas-crudas.md) | capturar / descartar ideas crudas |
| [`proyecto-nuevo`](./escalones/proyecto-nuevo.md) | arrancar un proyecto desde cero |
| [`proyecto-continuar`](./escalones/proyecto-continuar.md) | retomar un proyecto existente |
| [`adoptar-proyecto`](./escalones/adoptar-proyecto.md) | registrar un proyecto existente en NIMBUS |
| [`proyecto-borrar-archivar`](./escalones/proyecto-borrar-archivar.md) | archivar o borrar un proyecto |
| [`rebanada-ready`](./escalones/rebanada-ready.md) | Definition of Ready + recomendación de effort |
| [`rebanada-done`](./escalones/rebanada-done.md) | Definition of Done |
| [`claude-trabado`](./escalones/claude-trabado.md) | protocolo cuando Claude se traba |
| [`evaluacion-herramientas`](./escalones/evaluacion-herramientas.md) | build vs reuse + plantilla ADR |
| [`seguridad-externos`](./escalones/seguridad-externos.md) | análisis de seguridad de repos externos |
| [`filtro-plataforma`](./escalones/filtro-plataforma.md) | irrelevancia y riesgo de plataforma |
| [`cierre-sesion`](./escalones/cierre-sesion.md) | fin de sesión + ESTADO.md + persistencia + retros |
| [`mecanica-git`](./escalones/mecanica-git.md) | pre-commit + branches + backup destructivo |

## Modelo de trabajo: Director + Constructor

Dos participantes: **tú** (el **Director** — diriges, validas resultados, das Luz Verde en las decisiones grandes) y **Claude Code** (el **Constructor** — hace el trabajo, pregunta antes de asumir, no inventa lógica nueva por su cuenta).

Cuando una tarea es grande, Claude Code puede spawnear sub-agentes internos (p.ej. un planeador y un revisor) vía la Workflow Tool y entregarte el resultado ya sintetizado. Esa capa de sub-agentes es **opcional/avanzada**; por default basta con Claude directo.

Resultados directos a ti, voice-friendly (`AC7`): qué se hizo, qué decidir, qué sigue.

## Skills disponibles

Mezcla de skills built-in de Claude Code (`/init`, `/review`, `/security-review`, `simplify`) y skills curadas en `~/.claude/skills/` (`/grill-me`, `/grill-with-docs`, `/tdd`, `/diagnose`). Esta tabla es el menú de decisión rápida — cuando estés ejecutando el flujo y dudes qué herramienta usar, mira aquí.

| Skill | Cuándo usarla | Dónde encaja en el flujo |
|---|---|---|
| `/init` | Generar `CLAUDE.md` cuando ya hay código en el directorio | Paso 0 del escalón `proyecto-nuevo` (si el dir no está vacío) |
| `/grill-me` | Alinear visión sin código existente | Paso 1 del escalón `proyecto-nuevo`; grills cortos antes de rebanadas con decisiones nuevas |
| `/grill-with-docs` | Alinear con codebase existente — actualiza `CONTEXT.md` y ADRs | Proyecto EXISTENTE cuando hay decisiones arquitectónicas a la vista |
| `/tdd` | Red-green-refactor para lógica crítica o no-trivial | Paso "Ejecutar rebanada" cuando la lógica lo merece |
| `/diagnose` | Bugs duros, regresiones de performance | Después de los 2 intentos del escalón `claude-trabado` |
| `simplify` | Detectar duplicación, abstracciones prematuras, lógica colapsable | Antes de cerrar rebanada — review del código recién escrito |
| `/review` | Code review formal | Antes de mergear o cerrar rebanada grande |
| `/security-review` | Review de cambios sensibles (auth, secretos, input externo) | Cerrar rebanadas que tocan superficie de ataque |

## Overrides del usuario

El usuario puede saltarse cualquier paso diciendo "skip grill" / "directo al código" / "solo arregla X" / "modo rápido". Respetar sin discusión, sin re-proponer el flujo. (Lista canónica de overrides y de "cuándo NO aplica" en `flow/ROUTER.md`, escalón 0.)

## Lo que este flujo NO es

- No es un proceso burocrático. Si una rebanada se construye en 5 minutos, está bien.
- No reemplaza el juicio. Si un proyecto es trivial (script de 50 líneas), saltarse el grill es lo correcto.
- No es exclusivo: puede combinarse con estructuras existentes del usuario (frameworks de agencia, repos de cliente, monorepos, etc.).

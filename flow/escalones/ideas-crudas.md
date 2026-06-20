# Escalón: ideas-crudas — `~/.claude/IDEAS.md`

> **Escalón del flujo NIMBUS (v3 — carga por escalones, ver [`decisions/004`](../../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- **Capturar:** "guarda esta idea" / "guarda esto en ideas" / "anota esta idea" / "anota esto en ideas" / "esto es una idea, guárdala" / "no lo pierdas, es una idea".
- **Descartar:** "descarta la idea de [X]" / "ya no me convence [X] de las ideas".
- **Revisar ideas al arrancar proyecto:** entra por el escalón `proyecto-nuevo` (ver Dependencias declaradas).

## Dependencias declaradas

- **Revisar ideas al empezar un proyecto nuevo** encadena con el escalón `proyecto-nuevo` (extiende su paso 0) y con el escalón `filtro-plataforma` (corre antes de marcar una idea como aterrizada). Cargar esos escalones solo si la tarea entra por ese camino; la captura y el descarte de ideas NO los necesitan.

---

Archivo vivo donde {{USER_NAME}} guarda ideas conforme van saliendo, sin estructurarlas todavía como proyecto. La meta es no perderlas; el filtrado y la decisión de cuáles aterrizar pasa después, cuando se arranca un proyecto nuevo y se revisa el archivo.

## Capturar una idea cruda

Triggers: ver "Cuándo carga este escalón".

Cuando {{USER_NAME}} diga eso (o equivalente):

1. Sintetizar la conversación reciente en una entrada nueva usando la plantilla del propio `IDEAS.md`.
2. **NO grillear la idea ni proponer escalado** — {{USER_NAME}} pidió capturarla CRUDA. Si hay preguntas obvias, anotarlas en la sección "Retos / preguntas abiertas" de la entrada, no preguntárselas ahora.
3. Append al final del archivo (las más recientes abajo, orden cronológico).
4. Confirmar en una línea dónde quedó.

## Revisar las ideas al empezar un proyecto nuevo

Esto extiende el paso 0 del escalón `proyecto-nuevo`.

- Si {{USER_NAME}} nombró el proyecto en la frase ("hagamos el proyecto X", "empecemos con Y", "voy a empezar Z") → seguir el flujo normal, ya hay claridad.
- Si {{USER_NAME}} dijo algo genérico SIN nombrar ("hagamos un proyecto nuevo", "empecemos algo", "vamos a abrir un proyecto") → ANTES de cualquier scaffolding, ofrecer dos opciones:
  - **Yo te digo qué proyecto** — {{USER_NAME}} ya lo tiene en mente, se nombra y se procede al scaffolding. Antes del scaffolding, ejecutar el escalón `filtro-plataforma` con la idea del proyecto como input. Solo veredicto ESCALAR habilita continuar con scaffolding.
  - **Vemos las ideas guardadas** — abrir `~/.claude/IDEAS.md`, revisar las que estén en `Estado: cruda`, ayudar a {{USER_NAME}} a escoger una. Para marcar la idea seleccionada como `Estado: aterrizada → ver proyecto X (YYYY-MM-DD)`, ejecutar primero el escalón `filtro-plataforma` con la idea como input. Solo veredicto ESCALAR habilita marcar `Estado: aterrizada`. Veredicto DESCARTAR marca la idea como `Estado: descartada (YYYY-MM-DD) — razón: filtro irrelevancia [sección que falló]`. Veredicto REESTRUCTURAR pide a {{USER_NAME}} re-empacar la idea con los cambios propuestos antes de re-evaluar.

**Cómo formular las dos opciones según el medio** (principio de paridad voz ↔ texto, que vive en el piso):

- **Vía Claude Code directo (texto):** usar `AskUserQuestion` con las dos opciones literal.
- **Vía una capa de voz:** devolver la pregunta como prosa simple en la respuesta de texto, ej: "¿Quieres abrir un proyecto que tienes en mente, o prefieres que revisemos las ideas guardadas en IDEAS.md?". El asistente la verbaliza, tú respondes por voz, y te la reenvía en otro turno.

Solo después de cerrar este paso, proceder al scaffolding del flujo normal.

## Descartar una idea

Triggers: ver "Cuándo carga este escalón".

Marcar la entrada con `Estado: descartada (YYYY-MM-DD) — razón en una línea`. **No borrarla** — se mantiene como referencia histórica.

# Router de NIMBUS — tabla trigger → escalón

> **Pieza del piso (NIMBUS v3 — ver [`decisions/004`](../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Este router lo entrega un **hook** en cada turno (no se hornea en el `CLAUDE.md`). Es la tabla que decide qué escalón cargar sin leer el flujo entero. Análogo a `flow/ROUTING_MANUALES.md`, pero para el flujo en vez de los manuales de agentes.

## Candado — declaración obligatoria de escalones (de ley, siempre)

Antes de responder a una tarea de proyecto, el Constructor declara en una línea:

> *"Esta tarea usa el/los escalón(es) **X** (y **Y**), effort recomendado **&lt;tier&gt;** para la rebanada que sigue. ¿De acuerdo?"*

El Director aprueba o ajusta la profundidad (más/menos escalones) y el effort. El Constructor recomienda; el switch de effort lo mueve el Director. Para tareas triviales, dudas sueltas o acknowledgments ("dale", "ok"), la declaración es **"escalón 0 — nada que cargar"**.

## Cómo se usa el router

1. Match del trigger de la tarea contra la tabla de abajo.
2. Declarar escalón(es) + effort (candado de arriba).
3. Cargar SOLO el/los archivo(s) `flow/escalones/<nombre>.md` que correspondan. No cargar el resto.
4. Si el escalón cargado declara una dependencia, encadenar solo ese escalón adicional.

## Tabla trigger → escalón

| Disparador (frase del usuario o situación) | Escalón a cargar (`flow/escalones/<nombre>.md`) |
|---|---|
| "empecemos proyecto nuevo", "voy a empezar X", "hagamos un proyecto", "abramos X" | `proyecto-nuevo` |
| "sigamos con X", "continuemos con X", "retomemos X" | `proyecto-continuar` |
| "tengo este proyecto y quiero adoptarlo con NIMBUS", "registra/adopta este proyecto en NIMBUS", "usa NIMBUS aquí" | `adoptar-proyecto` |
| "archiva X", "pausa X indefinido" / "borra el proyecto X", "elimina X", "tíralo" | `proyecto-borrar-archivar` |
| Claude se traba: muro, dependencia rota, bug duro, regresión de performance | `claude-trabado` |
| "evalúa X", "qué uso para X", "dame opciones para X", "compara X vs Y", "build vs reuse" | `evaluacion-herramientas` |
| "instala X", "integra X", "clona este repo", "usa este repo", "agreguemos dep", "copia esto a mi proyecto" | `seguridad-externos` |
| "evalúa esta idea contra riesgo de plataforma", "vale la pena empezar X", "riesgo de que [Anthropic/OpenAI/Google] saque esto nativo" | `filtro-plataforma` |
| "guarda esta idea", "anota esto en ideas", "descarta la idea de X" | `ideas-crudas` |
| "nos vemos", "ahí la dejamos", "ya cerramos", "pausa", "córtale" | `cierre-sesion` |
| Setup de pre-commit/branches, o ANTES de una operación git destructiva | `mecanica-git` |
| "configura/personaliza NIMBUS", "onboarding", "setup NIMBUS", `/nimbus-setup` | `nimbus-onboarding` |

## Escalones encadenados (NO se disparan por frase del usuario)

Estos dos no tienen disparador propio: se alcanzan ENCADENADOS desde `proyecto-nuevo` y `proyecto-continuar`, que los declaran en su sección "Dependencias declaradas".

| Escalón | Se encadena cuando |
|---|---|
| `rebanada-ready` | antes de codear cualquier rebanada (DoR + recomendación de effort) |
| `rebanada-done` | al cerrar una rebanada (¿cumple el Definition of Done?) |

## Default cuando es trabajo de proyecto y NO hay match

Si la tarea es trabajo de proyecto no-trivial pero ningún disparador de la tabla matchea (ej. "refactoriza este módulo", "agrega tests a X", "renombra esta función en todo el repo", "sube la cobertura", "limpia este archivo"): NO la trates como escalón 0. Carga `rebanada-ready` (DoR + tiers de effort) como base y declara el candado con ese escalón para que el Director ajuste. Si no hay sesión de proyecto activa, encadena primero `proyecto-continuar` (o confirma con el Director cuál proyecto) antes de `rebanada-ready`, para no cargar el escalón de rebanada asumiendo contexto de proyecto no cargado. (Mismo patrón "default cuando no hay match" de `flow/ROUTING_MANUALES.md`.)

## Cuándo NO aplica NIMBUS (escalón 0)

- Bugs chiquitos, ajustes de una línea, dudas, exploración rápida.
- Preguntas sobre cómo funciona algo.
- Cuando el usuario diga "skip grill", "directo al código", "solo arregla X" o "modo rápido" → respetar sin discusión, sin re-proponer el flujo.

En estos casos la declaración del candado es "escalón 0 — nada que cargar" y se procede directo.

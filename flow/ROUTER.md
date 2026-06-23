# Router de NIMBUS — tabla trigger → escalón

> **Pieza del piso (NIMBUS v3 — carga dinámica por escalones).** Este router lo entrega un **hook** en cada turno (no se hornea en el `CLAUDE.md`). Es la tabla que decide qué escalón cargar sin leer el flujo entero.

## Candado — bloque ESTATUS al final (de ley, siempre)

En **cada turno, sin excepción**, el Constructor **cierra** su respuesta con el **bloque ESTATUS enmarcado** de NIMBUS — **siempre al final, nunca arriba**, para que el Director lo lea sin tener que subir a buscarlo: es el veredicto que orienta qué sigue. El marco es **abierto a la derecha**: regla larga arriba y abajo, contenido con barra izquierda `│`, **sin borde derecho**. Así no se rompe nunca aunque el contenido sea largo o los emojis sean doble-ancho — el borde derecho cerrado (`║ … ║`) era frágil justo por eso. Cada línea **arranca con ícono** para distinguirse de la prosa. Va en bloque de código para que el marco no se deforme.

**Regla de ley — el ESTATUS nunca omite áreas.** En el bloque de trabajo de proyecto salen SIEMPRE las cinco áreas, en orden, sin colapsar ni saltarse ninguna: **veredicto** (dos líneas), **💾 guardado**, **🎚️ effort**, **🧩 escalón** (mapa del 100% de NIMBUS), **📊 contexto**. La única excepción es la **variante de escalón 0** (NIMBUS inactivo este turno), que es señal mínima.

Cada línea lleva su ícono:
- **veredicto** — siempre **dos líneas** (estado + qué sigue):
  - Primera: **✅ se hizo** al cerrar una rebanada · **📍 aquí vamos** al retomar.
  - Segunda: **▶️ sigue** (del roadmap, leído de `ESTADO.md`) — **obligatoria, nunca se omite**: es "con qué seguimos". Si lo hecho quedó **fuera del roadmap**, va **⏳ sigue · — dime qué sigue** (no se puede recomendar siguiente).
- **💾 guardado** — estado de guardado del repo en el cwd: `sin guardar` (hay cambios sin commitear) · `limpio · N sin pushear` · `limpio · pusheado` · `limpio · sin upstream`. Lo **calcula el hook** (`git status --porcelain` + `git rev-list --count @{u}..HEAD` en el cwd, con guard "¿es repo?") y lo entrega como línea `ESTADO DE GUARDADO`; el Constructor lo copia TAL CUAL. Fuera de un repo git el hook lo omite y el área no aplica.
- **🎚️ effort** — tier + medidor + su comando **`/effort`**. Tiers en `rebanada-ready` (high es el piso del trabajo de proyecto, por eso el medidor arranca en 3/5): `high ●●●○○` · `xhigh ●●●●○` · `max ●●●●●`. El Constructor recomienda; el switch lo mueve el Director con `/effort`. El Constructor NO auto-cambia su effort a media sesión.
- **🧩 escalón** — primero los cargados este turno (`cargado(s): <lista> (<n>)`), luego el **timeline de NIMBUS**: un riel horizontal de las estaciones con su número de escalones entre paréntesis, con `◆` en la estación actual (`▾ estás aquí`). La **estación actual se abre** y lista sus escalones **numerados (1..N)** con el activo marcado `▸ N. … ← aquí` y una glosa corta; las demás quedan como `○` (cerradas). Inventario de estaciones y sus escalones:
  - **arranque (4)** — `nuevo` empezar de cero · `continuar` retomar existente · `adoptar` meter a NIMBUS un proyecto ya hecho · `borrar` archivar/eliminar.
  - **rebanada (4)** — `ready` alistar la tajada (DoR+effort) · `done` cerrarla (DoD) · `trabado` destrabarte (muro/bug/perf) · `git` commits/branches/backup.
  - **decisión (3)** — `eval` herramientas (build vs reuse) · `seguridad` repos/deps externos · `plataforma` riesgo de que lo saquen nativo.
  - **cierre (2)** — `ideas` guardar/descartar ideas crudas · `cierre` cerrar sesión (commit+push).
  - **setup (1)** — `onboarding` personalizar NIMBUS a tu gusto (una vez).
  (Las estaciones = el 100% de NIMBUS = 14 escalones (4+4+3+2+1). Estilo "hitos" + estación expandible.)
- **📊 contexto** — el MEDIDOR que inyecta el hook cada turno (barra de contexto `~%` + sesión `tiempo/turnos`) **con su comando recomendado según la banda**: verde (sano) → nada · ámbar → `→ /compact` · rojo → `→ /clear` · crítico → `→ cerrar sesión`. Es una **estimación** por tamaño de la conversación; el hook ya añade el comando al final del medidor, así que se copia TAL CUAL. Cortes de banda calibrables en el hook (`CTX_AMBER_PCT`/`CTX_RED_PCT`/`CTX_CRIT_PCT`).
  - **Regla de seguridad (de ley):** ANTES de que el ESTATUS muestre `→ /compact` o `→ /clear`, el Constructor **commitea el trabajo SIN pedir permiso** ("solo es guardar", autorizado por el Director). Recomendar limpiar contexto implica que TODO está guardado: nunca sugerir `/compact` o `/clear` con trabajo sin commitear.

Caso típico (cerrando una rebanada con roadmap):

```
┌─ 🧭 NIMBUS · ESTATUS ───────────────────────────
│ ✅ se hizo  · <rebanada cerrada>
│ ▶️ sigue    · <siguiente del roadmap>
│ 💾 guardado · <sin guardar | limpio · N sin pushear | limpio · pusheado>
│ 🎚️ effort   · <tier> <medidor> · /effort
│ 🧩 escalón  · cargado(s): <lista> (<n>) · ▾ estás aquí
│   ○─arranque(4)─◆─REBANADA(4)─○─decisión(3)─○─cierre(2)─▶
│   REBANADA(4) · estás en "ready":
│    ▸ 1. ready · alistar la tajada     ← aquí
│      2. done · cerrarla
│      3. trabado · destrabarte
│      4. git · commits / branches
│ 📊 contexto · <medidor del hook · trae → /compact|/clear|cerrar si aplica>
└─ ¿de acuerdo? ──────────────────────────────────
```

Al **retomar**, la primera línea es `📍 aquí vamos · <dónde estamos>` en vez de `✅ se hizo`; la línea `▶️ sigue` queda igual, nunca se omite. En el timeline, mover el `◆` a la estación actual y nombrar en `cargado(s):` el/los escalón(es) de este turno.

Trivial / ack ("dale", "ok", duda suelta) — variante escalón 0 (NIMBUS inactivo), señal mínima, mismo marco abierto:

```
┌─ 🧭 NIMBUS · ESTATUS ───────────────────────────
│ 💾 guardado · <estado git>
│ 🧩 escalón  · 0 — nada que cargar · sigo directo
│ 📊 contexto · <medidor del hook>
└─────────────────────────────────────────────────
```

El Director aprueba o ajusta la profundidad (más/menos escalones) y el effort. El Constructor recomienda; el switch de effort lo mueve el Director.

## Cómo se usa el router

1. Match del trigger de la tarea contra la tabla de abajo.
2. Declarar escalón(es) + effort (en el bloque ESTATUS del candado, al final de la respuesta).
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

Si la tarea es trabajo de proyecto no-trivial pero ningún disparador de la tabla matchea (ej. "refactoriza este módulo", "agrega tests a X", "renombra esta función en todo el repo", "sube la cobertura", "limpia este archivo"): NO la trates como escalón 0. Carga `rebanada-ready` (DoR + tiers de effort) como base y declara el candado con ese escalón para que el Director ajuste. Si no hay sesión de proyecto activa, encadena primero `proyecto-continuar` (o confirma con el Director cuál proyecto) antes de `rebanada-ready`, para no cargar el escalón de rebanada asumiendo contexto de proyecto no cargado.

## Cuándo NO aplica NIMBUS (escalón 0)

- Bugs chiquitos, ajustes de una línea, dudas, exploración rápida.
- Preguntas sobre cómo funciona algo.
- Cuando el usuario diga "skip grill", "directo al código", "solo arregla X" o "modo rápido" → respetar sin discusión, sin re-proponer el flujo.

En estos casos no se carga ningún escalón, pero **el ESTATUS igual sale** (al final) en su variante de escalón 0 (el marco de "nada que cargar") y se procede directo. El ESTATUS **nunca se omite**: es la señal de que NIMBUS no se está usando este turno.

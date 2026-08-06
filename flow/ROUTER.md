# Router de NIMBUS — tabla trigger → escalón

> **Pieza del piso (NIMBUS v3 — carga dinámica por escalones).** Este router lo entrega un **hook** en cada turno (no se hornea en el `CLAUDE.md`). Es la tabla que decide qué escalón cargar sin leer el flujo entero.
>
> **Estructura (v1.5.0):** el hook inyecta **solo** lo que va entre los marcadores `NIMBUS:INYECTAR`. Todo lo de abajo del marcador de cierre es el porqué del diseño: se lee bajo demanda, no cada turno. Si agregas algo dentro del bloque, paga renta en **cada turno de cada sesión** — ver §"Por qué el bloque va primero y es chico".

<!-- NIMBUS:INYECTAR:INICIO — el hook entrega SOLO lo que va entre estos marcadores. Mantenerlo corto: cuesta en cada turno. -->

## Candado — ESTATUS, plantilla canónica (de ley: cierra CADA respuesta, AL FINAL, nunca arriba)

```
┌─ 🧭 NIMBUS · ESTATUS ───────────────────────────────
│ ✅ se hizo  · <lo cerrado>          · al retomar: 📍 aquí vamos
│ ▶️ sigue    · <siguiente del roadmap>  · fuera de roadmap: ⏳ dime qué sigue
│ ╶────────────────────────────────────────────────
│ 💾 GUARDADO  <TAL CUAL del hook>
│ 🤖 MODELO    <recomendado> · escalón <n> — <razón>    /model
│ 🎚️ EFFORT    <tacómetro> <tier>                       /effort
│   🎭 ROLES   <íconos> · <razón corta>
│ 🧩 ESCALÓN   <riel de estaciones, ◆ en la actual>
│    <estación> › <escalones numerados, ▸ en el activo>
│ 📊 CONTEXTO  <TAL CUAL del hook>
└─ ¿de acuerdo? ──────────────────────────────────────
```

**Nunca omite áreas.** Única excepción: **escalón 0** (NIMBUS inactivo este turno) = solo `💾` + `🧩 0 — nada que cargar` + `📊`.
`💾` y `📊` se copian **TAL CUAL** del hook. `🤖`, `🎚️`, `🎭`, `🧩` los pinta el Constructor por juicio.
**`🤖` cita el escalón de la escalera del que sale** (`escalón 4 — cruza varios módulos`). Si ninguno aplica, escribir `sin escalón — juicio` y la razón: inventar un escalón para justificar una corazonada previa es el fallo que esto existe para atrapar.
🎭 Roles: 🔄 Transformador · 🧠 Analista · 👷 Constructor · 🔍 Auditor (el Director eres tú, 🧭). Default `👷 directo`. `👷→🔍` cierre con código nuevo · `🧠→👷→🔍` decisión arquitectónica o dep nueva · `🔄→🧠→👷→🔍` idea cruda ambigua.

## 🤖 MODELO — escalera de decisión (la primera que matchea gana)

| # | Si el turno… | Modelo | Por qué |
|---|---|---|---|
| 1 | lanza **flota** (Workflow / subagentes ≥5) | **Opus 5** | la flota HEREDA el modelo de sesión → el costo se multiplica por N. **Nunca Fable aquí.** |
| 2 | es **irreversible**, de seguridad o de arquitectura | **Opus 5** | equivocarse no se deshace |
| 3 | es **un solo nudo espinoso**, un hilo, sin flota | **Fable 5** | el razonamiento más profundo; caro, por eso solo sin fan-out |
| 4 | cruza **>3 archivos** o varios módulos | **Opus 5** | hay que sostener muchos hilos a la vez |
| 5 | **construye** algo acotado y claro | **Sonnet 5** | piso de construcción: rápido y capaz |
| 6 | es **conversar**, explicar, revisar chico | **Sonnet 5** | la calidad de plática no sube con más modelo |
| 7 | es **mecánico puro** (renombrar, formatear, mover) | **Haiku 4.5** | no hay decisión que tomar |

## 🎚️ EFFORT — escalera (misma decisión que el modelo, otra perilla)

| Tier | Tacómetro | Cuándo |
|---|---|---|
| low | `⚪ ▰▱▱▱▱` | ack, leer, buscar, correr un comando |
| medium | `🔵 ▰▰▱▱▱` | conversar, explicar, edit chico de un archivo |
| high | `🟢 ▰▰▰▱▱` | **piso del trabajo de proyecto**: rebanada normal, lógica clara |
| xhigh | `🟡 ▰▰▰▰▱` | varias incertidumbres vivas, refactor multi-módulo, diseño no trivial |
| max | `🔴 ▰▰▰▰▰` | decisión arquitectónica, bug duro, reversibilidad incierta |

**Regla del empate:** si dudas y la acción es **irreversible** → sube. Si es reversible → baja y reintenta si falla.
**En Workflow:** el effort se pone **por rol** (mecánicos/refutadores `low`–`high`; auditores/jueces `xhigh`). Una flota entera en `xhigh` es donde se quema la cuota.

## Tabla trigger → escalón

| Disparador | Escalón |
|---|---|
| "empecemos proyecto nuevo", "voy a empezar X", "abramos X" | `proyecto-nuevo` |
| "sigamos con X", "continuemos con X", "retomemos X" | `proyecto-continuar` |
| "adopta/registra este proyecto en NIMBUS", "usa NIMBUS aquí" | `adoptar-proyecto` |
| "archiva X", "pausa X" / "borra X", "elimina X", "tíralo" | `proyecto-borrar-archivar` |
| Muro, dependencia rota, bug duro, regresión de performance | `claude-trabado` |
| "evalúa X", "qué uso para X", "compara X vs Y", "build vs reuse" | `evaluacion-herramientas` |
| "instala/integra/clona/usa este repo", "agreguemos dep" | `seguridad-externos` |
| "vale la pena empezar X", "riesgo de que lo saquen nativo" | `filtro-plataforma` |
| "guarda esta idea", "anota esto", "descarta la idea de X" | `ideas-crudas` |
| "nos vemos", "ahí la dejamos", "ya cerramos", "pausa", "córtale" | `cierre-sesion` |
| Setup de pre-commit/branches, o ANTES de un git destructivo | `mecanica-git` |
| "configura/personaliza NIMBUS", "onboarding", `/nimbus-setup` | `nimbus-onboarding` |

**Encadenados** (sin disparador propio, los declaran `proyecto-nuevo`/`proyecto-continuar`): `rebanada-ready` antes de codear · `rebanada-done` al cerrar.
**Sin match pero ES trabajo de proyecto** (refactor, tests, limpieza) → carga `rebanada-ready`, NO lo trates como escalón 0. Si no hay sesión de proyecto activa, encadena antes `proyecto-continuar`.
**Escalón 0** (no carga nada, pero el ESTATUS igual sale): bug chico, duda suelta, pregunta de cómo funciona algo, o "modo rápido"/"directo al código"/"skip grill" → respetar sin re-proponer el flujo.

## Estaciones (el 100% de NIMBUS = 14 escalones)

`arranque(4)` nuevo · continuar · adoptar · borrar — `rebanada(4)` ready · done · trabado · git — `decisión(3)` eval · seguridad · plataforma — `cierre(2)` ideas · cierre — `setup(1)` onboarding

## Cómo se usa

1. Match del disparador contra la tabla. 2. Declarar escalón + modelo + effort en el ESTATUS. 3. Cargar SOLO ese(esos) archivo(s) de `~/.claude/escalones/`. 4. Si el escalón declara dependencia, encadenar solo esa.

**Seguridad (de ley):** si el medidor de contexto trae `→ /compact` o `→ /clear`, **commitear el trabajo SIN pedir permiso** antes de recomendarlo (solo es guardar, autorizado por el Director). Recomendar limpiar contexto implica que todo está guardado.

<!-- NIMBUS:INYECTAR:FIN -->

---

# El porqué (NO se inyecta — se lee bajo demanda)

## Por qué el bloque va primero y es chico

**Hallazgo del 2026-08-06 que motivó la reestructura.** El `ROUTER.md` había crecido y el hook lo entregaba entero cada turno. El harness **corta la salida de un hook** que excede su tope (~13.9 KB observado): inyecta solo un preview de los primeros ~2 KB y persiste el resto en un archivo aparte. Consecuencia medida en el repo hermano, no supuesta: la **tabla trigger → escalón** empezaba miles de bytes más allá del corte y **nunca llegaba** — el ruteo corría de memoria del Constructor, que es exactamente el fallo que el hook existía para evitar. Los **medidores calculados** (`💾`, `📊`) iban al final del todo, así que eran lo primero que se perdía: justo el dato más caro de reconstruir a mano.

De ahí las dos reglas de diseño de la salida del hook, en este orden:

1. **Lo calculado primero, la prosa nunca.** El hook emite los medidores antes que nada; si algo se corta, que sea lo reconstruible.
2. **Un solo bloque, marcado dentro de este archivo.** No se creó un archivo nuevo a propósito: la misma regla ya vive escrita en varios lugares (`ROUTER.md`, `CLAUDE.md.snippet`, `FLUJO_PROYECTOS.md`, `rebanada-ready`) y un archivo más sería una copia más que se desincroniza. Los marcadores `NIMBUS:INYECTAR` mantienen **una sola fuente de verdad** y no obligan a tocar `install.sh`.

**Regla que se hereda:** cualquier cosa que se agregue al bloque inyectable paga renta en cada turno de cada sesión. Antes de meter algo ahí, preguntar si de verdad se necesita en TODOS los turnos o si es contenido de escalón.

## Por qué el ESTATUS es como es

**Marco abierto a la derecha.** Regla larga arriba y abajo, contenido con barra izquierda `│`, sin borde derecho. El borde cerrado (`║ … ║`) se rompía con emojis de doble ancho y con anchos de terminal distintos. Cada línea arranca con ícono para distinguirse de la prosa, y va en bloque de código para que el marco no se deforme.

**Va al final, nunca arriba.** Es el veredicto que orienta qué sigue; el Director lo lee sin tener que subir a buscarlo.

**Nunca omite áreas.** La sub-línea `🎭 ROLES` sale en cada turno de proyecto aunque la cadena sea `👷 directo` — así su **ausencia señala un fallo** (la feature no corrió) y no se confunde con "fue directo a propósito". Mismo principio para las demás áreas.

**Escalón 0 se queda mínimo** (`💾` + `🧩` + `📊`): es la señal de "NIMBUS inactivo este turno"; forzar las áreas completas sin trabajo de proyecto sería ruido. Es la única excepción a "nunca omite áreas".

**Al retomar**, la primera línea es `📍 aquí vamos` en vez de `✅ se hizo`; la línea `▶️ sigue` queda igual y nunca se omite. Si lo hecho quedó fuera del roadmap, va `⏳ dime qué sigue` — no se puede recomendar siguiente.

## Por qué `💾` y `📊` los calcula el hook, y `🤖`/`🎚️`/`🎭` no

`💾` sale de `git status --porcelain` + `git rev-list --count @{u}..HEAD` y `📊` del tamaño del transcript: son **medidas**, tienen una sola respuesta correcta, y dejárselas al Constructor sería pedirle que recuerde un número. Fuera de un repo git el hook omite `💾` y el área no aplica. Cortes de banda del contexto calibrables en el hook (`CTX_AMBER_PCT` / `CTX_RED_PCT` / `CTX_CRIT_PCT`).

**`📊` se mide desde el último `/compact`, no desde el inicio del archivo.** El transcript **nunca se recorta**: al compactar, el harness escribe una línea `"type":"system","subtype":"compact_boundary"` y sigue anexando al mismo archivo. Medirlo entero dejaba el medidor pegado en 100% **justo después de compactar** — o sea, justo después de que el propio medidor lo pidió; el consejo se autoinvalidaba y el área quedaba muerta el resto de la sesión. Medido en vivo: 1.628.187 B de archivo contra 132.508 B reales (100% contra 8,8%). Lección que se hereda: *un medidor cuyo valor no cambia cuando actúas sobre él no está midiendo lo que dice medir.*

`🤖`, `🎚️` y `🎭` son **juicio sobre el trabajo del turno**, que el hook no ve. Pero **cuál modelo y cuál effort corrieron sí son medibles**, y el hook los reporta para que el Constructor contraste "en qué estás" contra "qué te recomiendo" en vez de adivinar ambos.

**No vienen en el stdin** del hook `UserPromptSubmit` (trae `session_id`, `prompt_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name` y `prompt_text`), así que se leen de **dos fuentes contrastadas**:

- **REAL** — la cola del transcript: cada registro de assistant trae el modelo que corrió y el `effort` con el que corrió (se filtra `isSidechain:false` para que un sub-agente con otro modelo no falsee la lectura). Va **un turno atrasado** y el formato no está documentado — puede cambiar sin aviso —, por eso va envuelto en fail-open: si no se puede leer, `s/d`.
- **DEFAULT** — `~/.claude/settings.json`, donde escriben `/model` y `/effort`. Es el default de sesiones **nuevas**, así que un override solo-para-esta-sesión no aparece ahí. Era la fuente única antes, y por eso podía mentir sin que se notara.

Se muestra el REAL; si discrepa del DEFAULT se agrega una línea `⚠️`, porque esa discrepancia **es la señal** de que hay un override vivo, no un error. La comparación va por **familia normalizada** (`claude-opus-5` ≡ `opus[1m]`): comparar los strings crudos marcaría discrepancia en toda sesión y el aviso se volvería ruido que se ignora.

**El Constructor NO auto-cambia modelo ni effort a media sesión.** Recomienda; los switches los mueve el Director con `/model` y `/effort`.

**Por qué `🤖` cita el escalón en vez de calcularse.** El riesgo de que la recomendación de modelo sea capricho es real. Se evaluaron tres salidas y se eligió la primera:

- **Citar el escalón de la escalera** (elegida). No vuelve al Constructor más acertado eligiendo — lo vuelve **revisable**. El fallo que atrapa es la racionalización *post hoc*: justificar después una corazonada de antes. De ahí el candado de escribir `sin escalón — juicio` cuando ninguno aplica, en lugar de inventar uno que encaje.
- **Que el hook sugiera el modelo por palabras**, como ya sugiere el escalón. Descartada: mismo acierto bajo que el pre-match, pero con un defecto que el pre-match no tiene — **ancla**. Un escalón mal sugerido se cacha al leer la petición; un modelo sugerido antes de pensar sesga sin que se note.
- **Bitácora de gasto por modelo/effort** (aplazada, no descartada). El hook ya sabe qué corrió cada turno, así que es barata. Pero sin señal de calidad al lado del costo, los datos solo empujan hacia el modelo más barato siempre, que es la lección equivocada. Reconsiderar cuando el dolor sea la **cuota** (turnos por modelo contra qué tan rápido se quema la ventana): esa pregunta sí se responde solo con costo.

## Por qué el pre-match del escalón es una sugerencia y no una decisión

El hook recibe `prompt_text`, así que puede buscar palabras de la tabla y proponer un escalón. Se emite como **sugerencia sin autoridad**: el match por palabras se rompe con paráfrasis, y quien entiende una frase dicha de otro modo es el Constructor. Sirve como red — si el hook propone un escalón y el Constructor no carga ninguno, eso es señal de que algo se saltó. Si no matchea nada, el hook calla.

## Detalle de effort y roles

El escalón `rebanada-ready` tiene el Definition of Ready completo y el vocabulario de cadenas de roles con su mapeo caso → cadena. Las escaleras del bloque inyectable son el resumen operativo; `rebanada-ready` es el detalle.

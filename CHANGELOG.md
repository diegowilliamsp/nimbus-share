# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) · Versionado: [SemVer](https://semver.org/lang/es/).

## [1.5.0] — 2026-08-06

### El router llegaba cortado — medidores primero, bloque inyectable, y modelo en el candado

**Hallazgo medido en el motor y portado aquí.** El harness **corta la salida de un hook** que excede su tope (~13,9 KB observado): inyecta solo un preview de ~2 KB y persiste el resto a un archivo aparte. El `ROUTER.md` entregado entero llegaba a rozar ese tope con la **tabla trigger → escalón** y los **medidores calculados** al final — o sea, lo primero que se pierde es lo más caro de reconstruir a mano, y el ruteo pasa a correr de memoria del modelo: exactamente el fallo que el hook existía para evitar.

#### Añadido

- **Marcadores `NIMBUS:INYECTAR` en `flow/ROUTER.md`.** El hook entrega **solo** el bloque marcado (plantilla del ESTATUS + escaleras de modelo/effort + tabla trigger→escalón). Todo el porqué del diseño baja a una sección "El porqué" que se lee bajo demanda. Una sola fuente de verdad, sin archivo nuevo que desincronizar y sin tocar `install.sh`.
- **Área `🤖 MODELO` en el ESTATUS**, con escalera de decisión de 7 escalones (la primera que matchea gana). La regla que más cuesta recordar: **una flota de sub-agentes HEREDA el modelo de sesión**, así que su costo se multiplica por N — nunca lanzar fan-out con el modelo más caro.
- **Escalera de effort completa (5 tiers)** con tacómetros, **regla del empate** (irreversible → sube; reversible → baja y reintenta) y **effort por rol** dentro de un Workflow, que es donde se quema la cuota.
- **Pre-match del escalón** contra `prompt_text`: sugerencia por palabra, sin autoridad, que el Constructor confirma o corrige. Requiere `jq`; sin él no se intenta (buscar sobre el JSON crudo daría falsos positivos con el `cwd`).
- **Modelo y effort del turno**, de dos fuentes contrastadas: el **REAL** de la cola del transcript (lo que de verdad corrió) y el **DEFAULT** de `~/.claude/settings.json` (donde escriben `/model` y `/effort`, pero que solo guarda el default de sesiones nuevas). Si discrepan sale una línea `⚠️`: esa discrepancia **es la señal** de un override vivo. La comparación va por familia normalizada (`claude-opus-5` ≡ `opus[1m]`), si no toda sesión marcaría discrepancia falsa.

#### Cambiado

- **Orden de la salida del hook: lo calculado primero, la prosa nunca.** Si algo se corta, que sea lo reconstruible.
- **`📊` se mide desde el último `/compact`**, no desde el inicio del archivo. El transcript nunca se recorta: medirlo entero dejaba el medidor pegado en 100% justo después de compactar — justo después de que él mismo lo pidió. Medido en el motor: 1.628.187 B de archivo contra 132.508 B reales (100% contra 8,8%).
- Dos guards nuevos en el hook: si `ROUTER.md` no existe avisa visible; si faltan los marcadores avisa **y entrega el archivo entero** — nunca se queda callado.

#### Verificado

- Batería de 17 casos, **20/20 verde** contra este repo: stdin vacío/basura, sin transcript, fuera de repo git, `settings.json` ausente/malformado, router sin marcadores, `prompt_text` con comillas y emoji, sin `jq` en el PATH, transcript con y sin `compact_boundary`, mención escapada del marcador, discrepancia real vs default y familias equivalentes.
- Salida del hook: **6.480 bytes** (antes: el router entero). Costo por turno ~130 ms sobre un transcript de 1,7 MB.
- **Sincronizado sin drift:** `flow/ROUTER.md`, `flow/hooks/nimbus-router.sh`, `flow/CLAUDE.md.snippet`, `flow/FLUJO_PROYECTOS.md`, `flow/escalones/rebanada-ready.md`. Inventario propio respetado: `nimbus-onboarding` sí, `pipeline-reportes` no (14 escalones = 4+4+3+2+1). 0 PII en lo migrado.
- Bump MINOR 1.4.0 → 1.5.0.

## [1.4.0] — 2026-06-23

### ESTATUS v3.5 + v3.6 — roles del pipeline + panel de instrumentos

Paridad con el motor: el candado gana la sub-línea de roles y el panel visual.

- **🎭 ROLES (sub-línea siempre debajo de effort):** muestra la cadena del pipeline de mando con íconos (🔄 Transformador · 🧠 Analista · 👷 Constructor · 🔍 Auditor; 🧭 Director = tú). `👷 directo` por default; cadenas como `🧠→👷→🔍` para decisiones con plan + revisión. Siempre presente: su ausencia señala que la feature no corrió. Los roles se definen **autocontenidos** en `rebanada-ready` (no dependen de config externa al flujo).
- **Panel de instrumentos (Tablero):** 💾 medidor de respaldo (semáforo + barra: sin guardar 🔴 → local 🟡 → pusheado 🟢), 🎚️ tacómetro de color (high 🟢 / xhigh 🟡 / max 🔴), 📊 contexto con semáforo de banda (🟢/🟡/🔴/🆘/⚪). El hook dibuja 💾 y 📊; el Constructor pinta 🎚️/🎭/🧩.
- **Hook (`flow/hooks/nimbus-router.sh`):** reescritos los segmentos de 💾 y 📊 con semáforos + barras. Fail-open intacto, `bash -n` OK.
- **Sincronizado:** `flow/ROUTER.md` §Candado (descripciones + plantillas), `flow/escalones/rebanada-ready.md`, `flow/CLAUDE.md.snippet`, `flow/FLUJO_PROYECTOS.md`.
- Sanitización: los roles se documentan **inline** (sin referencias al sistema personal del autor); limpiada una ref colgante en `rebanada-ready`. 0 PII en lo migrado.
- Bump MINOR 1.3.0 → 1.4.0.

## [1.3.0] — 2026-06-22

### ESTATUS v3.4 — el candado pasa de badge a bloque ESTATUS al final, con medidor de contexto/sesión y 💾 guardado

Salto del candado al modelo v3.4 (paridad con el motor de NIMBUS): de "badge enmarcado que abre la respuesta" a **bloque ESTATUS enmarcado al final** de cada turno, calculado en parte por el hook.

- **Bloque ESTATUS al final, marco abierto:** el candado deja de abrir la respuesta y pasa a **cerrarla** — marco **abierto a la derecha** (regla larga arriba/abajo, contenido con `│`, sin borde derecho `║`), robusto a emojis doble-ancho y ancho de terminal. Cada línea arranca con ícono. **Nunca omite áreas:** veredicto (✅/📍 + ▶️/⏳) + 💾 guardado + 🎚️ effort + 🧩 escalón + 📊 contexto.
- **Hook con medidor + 💾 (nuevo):** el hook `flow/hooks/nimbus-router.sh` (antes embebido en `install.sh`, ahora **versionado** y copiado/symlinkeado por el instalador) calcula cada turno el **medidor de contexto** (barra `~%` por bytes del transcript) + **sesión** (tiempo/turnos) y la línea **`💾 guardado`** (`git status` + `rev-list` en el cwd, con guard de repo). **Fail-open:** si la medición falla, queda en `s/d` y el turno no se rompe.
- **Comandos accionables por línea:** `🎚️ effort` lleva `/effort`; `📊 contexto` recomienda comando por banda — verde nada · ámbar `/compact` · rojo `/clear` · crítico cerrar sesión. **Regla de seguridad:** antes de recomendar `/compact` o `/clear`, el Constructor commitea sin pedir permiso (limpiar contexto implica que todo está guardado).
- **🧩 escalón = timeline de hitos:** riel de las estaciones de NIMBUS (`arranque(4) → rebanada(4) → decisión(3) → cierre(2)` + `setup(1)` onboarding = 14 escalones), `◆` en la actual, que se abre y lista sus escalones numerados.
- **Cierre de sesión = commit + push:** `cierre-sesion` (paso 6) pasa a **commit + push** (el push lo autoriza el cierre, con guards: solo la rama actual a su upstream, nunca `--force`).
- **Limpieza para compartir:** removidas las referencias colgantes a `decisions/004` y al repo personal `nimbus-flow` en el ROUTER, el snippet, el overview y los escalones (el repo compartido no tiene esa carpeta).
- Sincronizado: ROUTER §Candado (fuente), snippet del piso, overview, `rebanada-ready`, `cierre-sesion`, `install.sh`, hook versionado. Bump MINOR 1.2.1 → 1.3.0.

## [1.2.1] — 2026-06-22

### El badge del candado sale en cada turno, sin excepción

- Refuerzo sobre el badge de 1.2.0: el flujo deja **explícito y obligatorio** que el badge enmarcado sale en **cada turno** — completo cuando hay trabajo de proyecto, en variante de escalón 0 cuando no — para que siempre se vea de un vistazo si NIMBUS se está usando o no. Sincronizado en `flow/ROUTER.md` (§Candado + §"Cuándo NO aplica"), el snippet del piso y el recordatorio del hook (en `install.sh`). Bump PATCH 1.2.0 → 1.2.1.

## [1.2.0] — 2026-06-22

### El candado y la recomendación de effort ahora son un badge enmarcado

- El candado (declaración obligatoria de escalón + effort) y la recomendación de effort de `rebanada-ready` pasan de prosa suelta a un **badge enmarcado**: marco box-drawing + `effort: <tier>` con medidor de puntos + escalones cargados, para distinguirse de un vistazo del texto normal.
- Fuente: `flow/ROUTER.md` §Candado. Medidor: `high ●●●○○ · xhigh ●●●●○ · max ●●●●●` (high es el piso del trabajo de proyecto, por eso arranca en 3/5). Sincronizado en el snippet del piso, el overview, `rebanada-ready` y el recordatorio del hook (en `install.sh`). Bump MINOR 1.1.0 → 1.2.0.

## [1.1.0] — 2026-06-21

### Escalón nuevo — `adoptar-proyecto`

- Adopta un proyecto que YA existe en NIMBUS: corre `/init` + `/grill-with-docs` y crea `CONTEXT.md`/`ESTADO.md`/`decisions/` sin tocar el código. Es el puente entre `proyecto-nuevo` (desde cero) y `proyecto-continuar` (asume docs existentes). Trigger: "tengo este proyecto y quiero adoptarlo con NIMBUS". Router + índice del overview actualizados. Bump 1.0.0 → 1.1.0.

## [1.0.0] — 2026-06-20

### Primera versión distribuible de NIMBUS

Versión genérica e instalable del flujo de trabajo NIMBUS para Claude Code, sin datos personales de nadie.

- **Motor por escalones:** 12 escalones autónomos en `flow/escalones/`, un `flow/ROUTER.md` (tabla trigger→escalón + candado), y el overview `flow/FLUJO_PROYECTOS.md`.
- **Candado por hook:** `install.sh` registra un hook `UserPromptSubmit` que entrega el router y obliga a declarar escalón + effort en cada turno de trabajo de proyecto.
- **Instalador portable:** detecta paths dinámicamente (cero rutas absolutas), idempotente, no-destructivo (backup de `~/.claude/`, nunca pisa el `CLAUDE.md` global), registro de hook con jq-o-fallback seguro bajo `set -e`. Modo `--dev` symlinkea para editar en vivo.
- **Capa persona:** los datos del usuario (ideas, retros, criterios de Director) viven en `~/.claude/persona/`, generada desde templates vacíos; nunca se versiona.
- **Onboarding:** escalón `nimbus-onboarding` + skill `/nimbus-setup` corren un grill corto de personalización (nombre, voz/texto, proyectos, idioma) al primer arranque. El hook lo anuncia hasta completarlo.
- **Doctor + uninstall simétrico:** `nimbus-doctor.sh` verifica la salud; `uninstall.sh` quita todo lo instalado sin dejar un hook roto, preservando la capa persona.

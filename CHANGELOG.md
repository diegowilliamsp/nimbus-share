# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) · Versionado: [SemVer](https://semver.org/lang/es/).

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

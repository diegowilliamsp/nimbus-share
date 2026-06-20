# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) · Versionado: [SemVer](https://semver.org/lang/es/).

## [1.0.0] — 2026-06-20

### Primera versión distribuible de NIMBUS

Versión genérica e instalable del flujo de trabajo NIMBUS para Claude Code, sin datos personales de nadie.

- **Motor por escalones:** 12 escalones autónomos en `flow/escalones/`, un `flow/ROUTER.md` (tabla trigger→escalón + candado), y el overview `flow/FLUJO_PROYECTOS.md`.
- **Candado por hook:** `install.sh` registra un hook `UserPromptSubmit` que entrega el router y obliga a declarar escalón + effort en cada turno de trabajo de proyecto.
- **Instalador portable:** detecta paths dinámicamente (cero rutas absolutas), idempotente, no-destructivo (backup de `~/.claude/`, nunca pisa el `CLAUDE.md` global), registro de hook con jq-o-fallback seguro bajo `set -e`. Modo `--dev` symlinkea para editar en vivo.
- **Capa persona:** los datos del usuario (ideas, retros, criterios de Director) viven en `~/.claude/persona/`, generada desde templates vacíos; nunca se versiona.
- **Onboarding:** escalón `nimbus-onboarding` + skill `/nimbus-setup` corren un grill corto de personalización (nombre, voz/texto, proyectos, idioma) al primer arranque. El hook lo anuncia hasta completarlo.
- **Doctor + uninstall simétrico:** `nimbus-doctor.sh` verifica la salud; `uninstall.sh` quita todo lo instalado sin dejar un hook roto, preservando la capa persona.

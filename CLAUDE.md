# NIMBUS (distribuible) — reglas para Claude

## Qué es
Versión genérica e instalable del flujo NIMBUS para Claude Code. Sin datos personales. Pensado para que cualquiera lo clone, lo instale (`bash install.sh`) y lo use en su propio entorno.

## Reglas técnicas duras
- **Bash puro** en los scripts (`install.sh`, `uninstall.sh`, `nimbus-doctor.sh`). Sin Python ni Node como dependencia (`jq` es opcional).
- **Idempotencia:** los scripts se corren N veces sin romper.
- **No destructivo:** backup de `~/.claude/` antes de tocar nada; NUNCA pisar el `CLAUDE.md` global del usuario (solo anexar el bloque entre marcadores `BEGIN/END claude-flow-proyectos`).
- **Cero PII:** este repo es genérico. Antes de commitear, `grep -rn 'Diego\|/Users/'` debe dar cero. Los datos del usuario viven en `~/.claude/persona/` (gitignoreado), nunca aquí.
- **Portabilidad:** cero rutas absolutas hardcodeadas. Paths detectados dinámicamente (`REPO_DIR`, `$HOME`).

## Estructura
- `flow/` — el motor: `FLUJO_PROYECTOS.md` (overview), `ROUTER.md` (router + candado), `escalones/` (los sub-protocolos), `CLAUDE.md.snippet` (el bloque que se anexa al CLAUDE.md global).
- `templates/persona/` — moldes vacíos para la capa persona del usuario.
- `skills/` — skills curadas.
- `install.sh` / `uninstall.sh` / `nimbus-doctor.sh` — el ciclo de vida.

## Al cambiar algo
Probar el instalador en sandbox aislado antes de commitear:
```bash
CLAUDE_DIR=/tmp/nimbus-test bash install.sh && CLAUDE_DIR=/tmp/nimbus-test bash nimbus-doctor.sh
```

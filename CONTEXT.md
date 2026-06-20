# NIMBUS (distribuible) — contexto

## Qué es
La versión **genérica e instalable** de NIMBUS: un flujo de trabajo para Claude Code que lo hace trabajar mejor en proyectos (preguntar antes de asumir, rebanadas pequeñas y verificables, carga por escalones, candado de ley). Derivado y des-personalizado de un repo personal; este repo no contiene datos de ninguna persona.

## Para quién
Cualquiera que use Claude Code y quiera un flujo disciplinado. Se instala con un comando y se personaliza con un grill de onboarding.

## Principios
- Pragmatismo > sobre-ingeniería.
- Bash puro, idempotente, no-destructivo.
- Cero PII en el repo; los datos del usuario viven solo en su `~/.claude/persona/` local.
- El medio (voz o texto) no cambia lo que se logra (paridad voz ↔ texto).

## Lenguaje del dominio
- **Escalón:** sub-protocolo del flujo que se carga solo, sin arrastrar el resto.
- **Piso:** lo que se carga siempre (el bloque NIMBUS del `CLAUDE.md` global).
- **Router:** la tabla trigger→escalón que el hook entrega cada turno.
- **Candado:** la declaración obligatoria de escalón + effort antes de trabajo de proyecto.
- **Capa persona:** los datos del usuario (`~/.claude/persona/`), privados, fuera del repo.

# Escalón: nimbus-onboarding — personalización al primer arranque

> **Escalón del flujo NIMBUS.** Lo dispara un usuario nuevo para personalizar NIMBUS a su gusto y entorno. Asume el **piso** cargado. No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- "configura NIMBUS" / "personaliza NIMBUS" / "reconfigura NIMBUS" / "onboarding" / "setup NIMBUS" / la skill `/nimbus-setup`.
- El hook lo **anuncia en cada turno** mientras exista `~/.claude/.nimbus-onboarding-pending` (recordatorio "NIMBUS sin configurar").
- "skip onboarding" → borrar el marcador `.pending`, dejar los defaults, no grillear.

## Qué hace

Corre un grill **corto**, una pregunta a la vez (estilo `/grill-me`, con respuesta recomendada por default), para personalizar NIMBUS, y escribe las respuestas en la **capa persona** del usuario (`~/.claude/persona/`). Voice-friendly: si es por voz, las preguntas salen como texto en la respuesta.

## El grill (UNA pregunta a la vez — esperar respuesta antes de la siguiente)

1. **¿Cómo te llamas?** (para que NIMBUS te hable por tu nombre)
2. **¿Trabajas por texto, por voz, o ambos?**
3. **¿En qué idioma quieres que trabajemos?** (default: el de esta conversación)
4. **¿Qué tipo de proyectos vas a hacer?** (una línea — para entender tu dominio)
5. **¿Hay algo que SIEMPRE deba consultarte antes de hacer?** (default recomendado: acciones irreversibles, instalar/ejecutar código externo, decisiones de arquitectura)

No inventes respuestas. Si el usuario no sabe o dice "lo que recomiendes", usa el default y sigue.

## Qué escribe (con backup + confirmación)

1. **Rellena `~/.claude/persona/DIRECTOR.md`** con las respuestas (nombre, idioma, medio, criterios de Luz Verde, dominio).
2. **Sustituye el nombre real** donde haya quedado el genérico: si los archivos instalados en `~/.claude/` (escalones, `ROUTER.md`, `FLUJO_PROYECTOS.md`, y el bloque del `CLAUDE.md` global) todavía dicen "el Director" o `{{USER_NAME}}`, reemplazar por el nombre real. **Antes de tocar el `CLAUDE.md` global: backup + confirmación explícita**, y editar SOLO entre los marcadores `BEGIN/END claude-flow-proyectos`.
3. **Marca el onboarding completo:** borrar `~/.claude/.nimbus-onboarding-pending` y crear `~/.claude/.nimbus-onboarding-done` (así el hook deja de anunciarlo).

## Reglas

- NUNCA pisar el `CLAUDE.md` global sin backup + confirmación explícita.
- Reúsa `/grill-me` (una pregunta a la vez); NO `/grill-with-docs` (en el primer arranque no hay domain model que grillear).
- Respeta voice-friendly (AC7): prosa, una pregunta a la vez, default recomendado.
- Al terminar, confirma en una línea: *"NIMBUS personalizado a tu gusto. Ya puedes empezar — dime 'empecemos un proyecto nuevo' o 'sigamos con [tu proyecto]'."*

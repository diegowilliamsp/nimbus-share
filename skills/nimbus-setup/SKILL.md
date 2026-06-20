---
name: nimbus-setup
description: Personaliza NIMBUS a tu gusto y entorno (nombre, voz/texto, idioma, proyectos, criterios). Corre el grill de onboarding del primer arranque. Úsala al instalar NIMBUS o cuando quieras reconfigurarlo.
---

# /nimbus-setup — personalizar NIMBUS

Carga y ejecuta el escalón de onboarding: lee `~/.claude/escalones/nimbus-onboarding.md` y sigue su grill paso a paso.

- Una pregunta a la vez, con respuesta recomendada por default (estilo `/grill-me`).
- Escribe las respuestas en la capa persona del usuario (`~/.claude/persona/`).
- Antes de tocar el `CLAUDE.md` global: backup + confirmación explícita.
- Al terminar, marca el onboarding como completo (borra `~/.claude/.nimbus-onboarding-pending`, crea `~/.claude/.nimbus-onboarding-done`).

Si el usuario dice "skip onboarding", borra el marcador `.pending` y deja los defaults.

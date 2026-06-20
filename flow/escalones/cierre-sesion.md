# Escalón: cierre-sesion — fin de sesión, ESTADO.md, persistencia, retros

> **Escalón del flujo NIMBUS (v3 — carga por escalones, ver [`decisions/004`](../../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- Frases de cierre del usuario (o equivalentes): "nos vemos", "ahí la dejamos", "pausa", "guarda dónde vamos", "ya cerramos", "hasta luego", "me voy", "ya acabamos por hoy", "ya estuvo", "ya estuvo por hoy", "lo dejamos así", "córtale", "ciérrale". Si la frase suena a cierre aunque no esté literal → tratarla como trigger.
- Claude proactivamente cuando: (a) acabamos de cerrar una rebanada, (b) llevamos >2h sin commit, (c) apareció un blocker que requiere acción del usuario fuera del código.

## Dependencias declaradas

- Decisión arquitectónica de la sesión → plantilla ADR en el escalón `evaluacion-herramientas`.
- Setup y reglas de pre-commit, branches y backup → escalón `mecanica-git`.
- `simplify` / `/review` / `/security-review` son skills built-in.

---

## Protocolo de fin de sesión

Cerrar una sesión sin actualizar `ESTADO.md` es como cerrar el restaurante sin guardar la caja. La próxima sesión paga el costo.

**Checklist de cierre — Claude lo corre en este orden:**

1. **Si la rebanada está lista** → invocar `simplify` sobre el código nuevo para detectar duplicación o abstracciones prematuras. Si toca superficie sensible (auth, secretos, input externo) → `/security-review`. Si es rebanada grande con varios commits → `/review`.
2. **Rebanada actual en `ESTADO.md`.**
   - ¿Está lista (las 3 condiciones de DoD)? → mover de "Próximo" a "Hecho" con fecha.
   - ¿No está lista? → anotar en "Rebanada actual" exactamente en qué punto se quedó. Detalle suficiente para retomar sin re-aprender.
3. **Decisiones técnicas de la sesión** → routing según peso:
   - Decisión chica de implementación (sin alternativas formales evaluadas) → "Notas de la sesión" en `ESTADO.md`. Una línea con qué y por qué.
   - Decisión arquitectónica o con alternativas descartadas → crear `decisions/NNN-<nombre>.md` con la plantilla ADR (escalón `evaluacion-herramientas`).
4. **Blockers nuevos** → sección "Blockers / pendientes externos".
5. **Próxima rebanada** → confirmar con el usuario y dejarla en "Próximo".
6. **Commit:** `git add . && git commit -m "estado: <resumen en 1 línea>"`. Si hay código de la rebanada que no debería commitearse junto con el estado (ej. WIP que rompe el build), hacer commits separados: uno del código y otro del `ESTADO.md`.
7. **Resumen al usuario en 3-4 líneas:** dónde cerramos, qué quedó en `ESTADO.md`, próxima rebanada. Esto es lo último que ve el usuario.

**Si el commit falla por pre-commit hook** → no hacer `--no-verify`. Arreglar lo que el hook reclame y crear un commit nuevo. Si el código no pasa los checks pero igual hay que cerrar, commitear solo el `ESTADO.md` con un mensaje explícito ("estado: cierre con código WIP no commiteado").

## ESTADO.md — diario vivo del proyecto

Cada proyecto tiene un `ESTADO.md` en su raíz. Es el cuaderno de bitácora que permite que cualquier sesión nueva sepa dónde quedó la anterior, sin depender de la memoria del modelo.

**Estructura mínima:**

```markdown
# Estado de [Proyecto]

**Última actualización:** YYYY-MM-DD

## Rebanada actual
[En qué rebanada vamos. Estado: planeando / construyendo / probando / lista]

## Hecho
- Rebanada 1: [descripción] ✅ [fecha]
- Rebanada 2: [descripción] ✅ [fecha]

## Próximo
- Rebanada N+1: [descripción y por qué sigue esa]

## Notas de la sesión
> Decisiones chicas de implementación van aquí. Decisiones grandes con alternativas formales → `decisions/NNN-<nombre>.md`.

- [ej. "para parsing de fechas usé `date-fns` por consistencia con otras libs del proyecto"]

## Blockers / pendientes externos
- [cosas que dependen de algo fuera del código: API key, trial pendiente, decisión externa, etc.]

## Notas para la próxima sesión
- [lo que el "yo del futuro" necesita saber para retomar sin perder tiempo]
```

**Cuándo y cómo se actualiza:**

`ESTADO.md` se toca en dos momentos distintos:

1. **A media sesión** — al cerrar una rebanada o al tomar una decisión chica de implementación. Editar la sección relevante directo, sin esperar a que el usuario lo pida. Mostrar un diff chiquito al usuario en 1-2 líneas ("actualicé ESTADO.md: rebanada 3 marcada como hecha, próxima = autenticación"). Si la decisión es arquitectónica con alternativas evaluadas → NO va aquí, va a `decisions/NNN-<nombre>.md`. Si es decisión grande que cambia el rumbo del proyecto → leer en voz alta antes de guardar para que el usuario apruebe.

2. **Al cerrar la sesión** — ejecutar el Protocolo de fin de sesión completo (arriba). Eso incluye actualizar `ESTADO.md` + commit + resumen al usuario.

**Si el proyecto no tiene `ESTADO.md`** → proponer crearlo en la primera sesión que se retome el proyecto.

## Persistencia — `ESTADO.md` vs `decisions/` vs memoria global

Hay tres sistemas de persistencia y es fácil duplicar o perder cosas. Regla:

| `ESTADO.md` (vivo, cambia cada sesión) | `decisions/NNN-<nombre>.md` (append-only, una entrada por decisión grande) | Memoria global (cross-proyecto, `~/.claude/projects/.../memory/`) |
|---|---|---|
| Rebanada actual y próxima | Decisiones arquitectónicas con alternativas evaluadas formalmente | Perfil del usuario (rol, preferencias, contexto personal) |
| Qué se hizo en la última sesión | Decisiones de tooling post-evaluación (resultado del sub-protocolo) | Feedback sobre cómo trabajar (correcciones, validaciones) |
| Notas de la sesión (decisiones chicas de implementación) | Cambios de rumbo del proyecto, con la razón | Referencias a sistemas externos (Linear, Slack, dashboards) |
| Blockers / pendientes externos del proyecto | Razón de "por qué NO se eligió Y" cuando se eligió X | Hechos cross-proyecto que aplican a otras sesiones aunque cambies de proyecto |
| Notas para la próxima sesión | (NO se borra cuando una decisión es reemplazada — se marca "Reemplazada por NNN") | Estructura general del trabajo del usuario (organización, clientes habituales, stack default, etc.) |

**Cuando dudes:**
- ¿Cambia entre sesiones o solo importa "ahorita"? → `ESTADO.md`
- ¿Es decisión técnica con alternativas que el "yo del futuro" debe entender? → `decisions/NNN-<nombre>.md`
- ¿Te sirve aunque mañana trabajes en otro proyecto distinto? → memoria global

**No duplicar:**
- Si algo ya está en memoria global, no copiarlo a `ESTADO.md`. Y al revés. La memoria global se carga sola en cualquier sesión, no necesitas re-anotarla.
- Si una decisión está en `decisions/`, NO repetirla en `ESTADO.md`. Si es relevante para retomar, dejar nota corta tipo "ver `decisions/003-X`" y nada más.

## Retrospectivas — mejorar el flujo mismo

El flujo no es sagrado. Cuando algo claramente falló (3h tiradas en una rebanada desbordada, mismo error de comunicación dos veces, workaround silencioso que se coló) o al cerrar/pausar un proyecto: pausa y pregunta qué ayudó, qué estorbó, qué hicimos fuera del flujo y por qué.

**Acción que vuelve útil la retro (no ritual):** si una propuesta de cambio es clara → editar el flujo ahí mismo (escalón o overview que corresponda). Patrones repetidos en feedback → guardar como memoria global `feedback_*.md`. Skill que nunca se usó → quitar de la tabla. Si la retro no produce edits, no fue retro útil.

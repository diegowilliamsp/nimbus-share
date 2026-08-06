# Escalón: rebanada-ready — Definition of Ready + effort

> **Escalón del flujo NIMBUS (v3 — carga por escalones).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- Antes de arrancar a codear cualquier rebanada (dentro de `proyecto-nuevo` o `proyecto-continuar`).

## Dependencias declaradas

- Si la decisión abierta del DoR es de tooling → encadena con el escalón `evaluacion-herramientas`.
- La recomendación de effort la consume el **candado** (declaración obligatoria de escalones); aquí vive el detalle de los tiers.

---

## Antes de arrancar una rebanada — Definition of Ready

Una rebanada solo arranca cuando cumple las **cinco** condiciones. Sin esto se arranca a ciegas y se tropieza a media ejecución.

1. **Objetivo claro en una frase.** "Al terminar esta rebanada, [X] funcionará." Si no se puede decir en una frase, está mal definida.
2. **Criterio de verificación definido.** Cómo vamos a saber que jala — comando a correr, output esperado, captura, query, schema check, lo que aplique al tipo de rebanada.
3. **Cabe en una sesión (idealmente <2h, máximo 4h).** Si se ve más grande, partirla. Señales de que está demasiado grande: "no sé cuánto va a tomar", involucra >3 archivos nuevos, requiere aprender una librería desde cero, o tiene >2 incertidumbres técnicas activas. Si se desborda en ejecución → pausar, partir y replantear, no seguir empujando.
4. **Sin decisiones de diseño abiertas.** Lo que requiere grilling se grillea ANTES de arrancar, no a media construcción.
5. **Dependencias listas.** API keys, accesos, libs instaladas, datos de prueba — todo lo externo está disponible.

Si falta una de las 5 → no arrancar. Resolver primero (preguntar, grillear, conseguir el acceso, partir la rebanada). Si la decisión abierta es de tooling → invocar el escalón `evaluacion-herramientas`.

## Recomendación de effort de razonamiento al arrancar la rebanada

Una vez la rebanada pasa el DoR y ANTES de empezar a codear, el Constructor recomienda al Director qué nivel de esfuerzo de razonamiento de Opus usar para esa rebanada, con la razón en una línea. El Director aprueba o lo mueve. **El Constructor solo recomienda — no puede cambiar su propio effort a media sesión; el switch lo mueve el Director.** No es condición de gating del DoR (no se bloquea el arranque por esto); es un paso de cierre del DoR.

Escala de esfuerzo (eje distinto de `ultracode`). **La escalera operativa vive en `ROUTER.md` §🎚️ EFFORT y el hook la inyecta cada turno** — aquí está el detalle de los tiers que tocan una rebanada:

| Tier | Tacómetro | Cuándo |
|---|---|---|
| **low** | `⚪ ▰▱▱▱▱` | Fuera de rebanada: ack, leer, buscar, correr un comando. |
| **medium** | `🔵 ▰▰▱▱▱` | Fuera de rebanada: conversar, explicar, edit chico de un archivo. |
| **high** | `🟢 ▰▰▰▱▱` | Default y **piso del trabajo de proyecto**. Rebanada normal: lógica clara, pocos archivos, sin incertidumbre técnica fuerte. |
| **xhigh** | `🟡 ▰▰▰▰▱` | Varias incertidumbres técnicas activas, refactor que toca varios módulos, diseño no trivial. |
| **max** | `🔴 ▰▰▰▰▰` | Decisión arquitectónica, debugging duro (`/diagnose`), o acción de reversibilidad incierta/cara (lo irreversible sube el tier, no la confianza). |

**Regla del empate:** si dudas y la acción es **irreversible** → sube de tier. Si es reversible → baja y reintenta si falla. El costo de quedarse corto en algo reversible es un reintento; en algo irreversible es algo que no se deshace.

**En Workflow el effort se pone POR ROL**, no para toda la flota: los roles mecánicos y los refutadores van `low`–`high`, los auditores y jueces `xhigh`. Una flota entera en el tier más alto es donde se quema la cuota.

**El modelo se elige junto con el effort** — son la misma decisión con dos perillas. La escalera de modelo (con la regla de que una flota HEREDA el modelo de sesión y multiplica su costo por N) está en `ROUTER.md` §🤖 MODELO, inyectada cada turno.

`ultracode` **no es un tier de esfuerzo** — es un eje aparte: activa orquestación multi-agente (sub-agentes en paralelo, review adversarial), cuesta muchos más tokens y es de pago. El Constructor lo sugiere por separado cuando la rebanada se beneficia de barrido exhaustivo (auditoría amplia, review adversarial, migración grande); el Director lo confirma siempre explícito. Nunca se asume.

Formato de la recomendación — va en la línea de effort del **bloque ESTATUS al final** de la respuesta (ver `ROUTER.md` §Candado):

```
│ 🎚️ EFFORT    <tacómetro> <tier>                   /effort
```

Medidor = **tacómetro de color** (semáforo de zona + barra proporcional): `high 🟢 ▰▰▰▱▱` (crucero) · `xhigh 🟡 ▰▰▰▰▱` · `max 🔴 ▰▰▰▰▰` (a fondo) — el color sube con la potencia. Si la rebanada se beneficia de `ultracode` (eje aparte, ver arriba), sumar una línea dentro del marco: `│ + ultracode sugerido: <razón>`.

## Recomendación de roles del pipeline al arrancar la rebanada

Junto con el effort —y como la misma decisión, "cómo atacamos esta tajada"— el Constructor recomienda qué **roles del pipeline de mando** de NIMBUS conviene activar para la rebanada. Los roles:

- **🧭 Director** — tú. Apruebas, decides, das la luz verde.
- **🔄 Transformador** — convierte tu idea cruda en un enunciado claro y estructurado (no inventa lo que falta; pregunta).
- **🧠 Analista** — arma el plan o compara opciones (no escribe el código final).
- **👷 Constructor** — Claude Code: ejecuta y escribe el código.
- **🔍 Auditor** — revisa adversarialmente lo hecho (señala fallos; no propone la solución).

La recomienda el **Constructor por juicio** sobre la naturaleza de la rebanada; tú decides. Activar el pipeline multi-rol (Transformador/Analista/Auditor como sub-agentes en paralelo) cuesta más tokens y es **opt-in explícito** — nunca se asume; la mayoría de las tareas las hace el Constructor directo.

Cada rol se dibuja con su **ícono** (waypoints encadenados con `→`). El Constructor siempre codea, así que 👷 aparece en toda cadena que llega a código.

Vocabulario de cadenas (mapeo caso → roles):

| Cadena (íconos) | Cuándo |
|---|---|
| **`👷` Constructor directo** | Ejecución pura, fix chico, housekeeping, doc/redacción. Es el **default**. |
| **`👷→🔍` → Auditor** | Cierre de rebanada con código nuevo o sensible (revisión adversarial). |
| **`🧠→👷→🔍` Analista → Constructor → Auditor** | Decisión con alternativas, integración nueva, cambio de stack (plan + revisión). |
| **`🔄→🧠→👷→🔍` pipeline completo** | Idea cruda ambigua que se va a aterrizar de cero. |

Formato — **sub-línea SIEMPRE presente** debajo de la línea de effort en el bloque ESTATUS, en cada turno de proyecto (aunque sea `👷 directo`):

```
│ 🎚️ EFFORT    <tacómetro> <tier>                   /effort
│   🎭 ROLES   <íconos de la cadena> · porque <razón>
```

Es **obligatoria** (entra en la regla "nunca omite áreas" del candado como sub-línea fija de effort): si va directa muestra `👷 directo`, de modo que su **ausencia señala que la feature no corrió**. NO la calcula el hook (a diferencia de `💾` y `📊`): es juicio del Constructor, igual que el tier de effort.

# Escalón: rebanada-ready — Definition of Ready + effort

> **Escalón del flujo NIMBUS (v3 — carga por escalones, ver [`decisions/004`](../../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

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

Escala de esfuerzo (eje distinto de `ultracode`):

| Tier | Cuándo |
|---|---|
| **high** | Default. Rebanada normal: lógica clara, pocos archivos, sin incertidumbre técnica fuerte. |
| **xhigh** | Varias incertidumbres técnicas activas, refactor que toca varios módulos, diseño no trivial. |
| **max** | Decisión arquitectónica, debugging duro (`/diagnose`), o acción de reversibilidad incierta/cara (ver bloque `irreversibilidad-sobre-confianza-v2.3.0` del `CLAUDE.md` global). |

`ultracode` **no es un tier de esfuerzo** — es un eje aparte: activa orquestación multi-agente (sub-agentes en paralelo, review adversarial), cuesta muchos más tokens y es de pago. El Constructor lo sugiere por separado cuando la rebanada se beneficia de barrido exhaustivo (auditoría amplia, review adversarial, migración grande); el Director lo confirma siempre explícito. Nunca se asume.

Formato de la recomendación (voice-friendly, una línea): *"Effort recomendado para esta rebanada: &lt;tier&gt; porque &lt;razón&gt;. ¿Lo dejamos ahí o lo mueves?"* — y si aplica, sumar *"+ esta rebanada se beneficiaría de `ultracode` por &lt;razón&gt;"*.

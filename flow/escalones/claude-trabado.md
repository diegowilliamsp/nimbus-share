# Escalón: claude-trabado — protocolo cuando Claude se traba

> **Escalón del flujo NIMBUS (v3 — carga por escalones).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- Claude topa con un muro: dependencia rota, API que no entiende, decisión de diseño no anticipada en el grill, comportamiento inesperado del sistema. Se carga proactivamente cuando el Constructor detecta que se trabó.

## Dependencias declaradas

- Bug duro o regresión de performance → usar la skill `/diagnose`.

---

Cuando Claude topa con un muro (dependencia rota, API que no entiende, decisión de diseño no anticipada en el grill, comportamiento inesperado del sistema):

1. **Intentar máximo 2 veces** lo mismo (o variantes muy cercanas). Si en el 2º intento sigue sin jalar, **detenerse**.
2. **Si es bug duro o regresión de performance** → invocar `/diagnose` (loop disciplinado de reproducir → minimizar → hipotetizar → instrumentar → fix). No seguir tirando intentos al voleo.
3. **Reportar al usuario** en 2-3 líneas: qué se intentó, qué pasó, cuál es la duda concreta.
4. **NUNCA improvisar un workaround silencioso.** No metas un `try/except` que traga el error, no cambies el approach a otro sin avisar, no comentes código "temporalmente" sin documentarlo. Esa es la principal fuente de bugs raros que aparecen después.
5. **Si la decisión no estaba en el grill** (ej. surge una pregunta de arquitectura nueva a mitad de la rebanada), pausar y preguntar antes de elegir por tu cuenta.

La regla mental: **es mejor pausar 30 segundos a preguntar que gastar 2 horas defendiendo un workaround equivocado.**

# Escalón: proyecto-nuevo — arrancar desde cero

> **Escalón del flujo NIMBUS (v3 — carga por escalones).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- "vamos a trabajar en un proyecto nuevo" / "empecemos [feature/proyecto]" / "hagamos un proyecto nuevo" / "voy a empezar [X]" / "abramos [X]".

## Dependencias declaradas

- **Paso 0 (pre-cero)** encadena con el escalón `filtro-plataforma` (corre ANTES del scaffolding; solo veredicto ESCALAR habilita continuar).
- **Sub-paso previo** (si {{USER_NAME}} no nombró el proyecto) encadena con el escalón `ideas-crudas` (revisar `~/.claude/IDEAS.md`).
- **Setup de pre-commit** vive en el escalón `mecanica-git`.
- **Paso 4** (antes de codear cada rebanada) encadena con el escalón `rebanada-ready` (DoR + recomendación de effort).
- **Al cerrar cada rebanada** encadena con el escalón `rebanada-done` (Definition of Done).
- **Grilling de visión** usa las skills `/grill-me` o `/grill-with-docs`; ejecución no-trivial usa `/tdd`.

---

0. **Inicializar el proyecto.** Antes del grill, montar el esqueleto. Esto lo hace Claude solo, sin pedir permiso — es scaffolding, no decisión.
   - **Sub-paso pre-cero — Filtro de irrelevancia y riesgo de plataforma:** aplicar primero el escalón `filtro-plataforma` con la idea del proyecto como input. Genera veredicto DESCARTAR / REESTRUCTURAR / ESCALAR + justificación por sección. Solo veredicto ESCALAR habilita continuar con scaffolding del esqueleto. Veredicto REESTRUCTURAR requiere re-empaque de la idea con los cambios propuestos antes de volver al paso 0. Veredicto DESCARTAR detiene el flujo y anota descarte en `persona/RETROS.md` con rationale + condición de re-entrada.
   - **Sub-paso previo (si aplica):** si {{USER_NAME}} dijo algo genérico SIN nombrar el proyecto ("hagamos un proyecto nuevo", "empecemos algo"), aplicar primero el escalón `ideas-crudas` → ofrecer revisar `~/.claude/IDEAS.md` antes del scaffolding. Si {{USER_NAME}} nombró el proyecto en la frase, saltar este sub-paso. (En cualquier caso, el sub-paso pre-cero del filtro se ejecuta una vez la idea esté nombrada).
   - Crear directorio si no existe
   - `git init` + primer commit vacío (`git commit --allow-empty -m "init"`)
   - Crear archivos: `CLAUDE.md`, `CONTEXT.md`, `ESTADO.md`, `.gitignore` (con plantillas mínimas)
   - Crear carpeta `decisions/` con un `.gitkeep` adentro (para que git la rastree aunque esté vacía)
   - Si ya hay código en el directorio: correr `/init` para autogenerar `CLAUDE.md` con las convenciones detectadas
   - Setup de pre-commit checks (ver escalón `mecanica-git`) según el stack. Si el stack todavía no está decidido → diferir hasta que se cierre el grill (paso 2 o 3 de este flujo).
   - Avisar al usuario en 1 línea cuando termine: "Esqueleto listo en [path]. Vamos al grill."

1. **Grilling de visión** → invocar `/grill-me` (sin código todavía) o `/grill-with-docs` (si ya hay codebase). Sacar a la luz:
   - Para qué sirve este proyecto, para quién
   - Restricciones duras (stack, deadline, budget, integraciones obligatorias)
   - Must-haves y must-NOTs
   - Lenguaje del dominio (cómo se llaman las cosas — clientes, leads, jobs, etc.)

   NO incluir en esta fase: estructura de archivos, qué librerías, orden de pasos.

2. **Escribir `CONTEXT.md`** del proyecto con la visión + lenguaje compartido. Este doc se actualiza vivo, no es de una sola vez.

3. **Definir solo las primeras 2-3 rebanadas verticales.** Cada rebanada = algo que funciona end-to-end, lo mínimo útil. Ejemplo en un agente tipo Jarvis:
   - Rebanada 1: solo voz (mic in / bocina out, sin LLM, sin memoria)
   - Rebanada 2: agregar LLM (hablas, responde)
   - Rebanada 3: memoria persistente
   - Rebanadas 4+ se diseñan después, no ahora.

4. **Ejecutar rebanada 1** → para lógica no-trivial, `/tdd`. Verificar que corre. Commit. (Antes de codear, pasar el Definition of Ready del escalón `rebanada-ready`.)

5. **Volver al paso 3** para la siguiente rebanada (re-evaluar con info real, no con el plan viejo).

# Escalón: filtro-plataforma — irrelevancia y riesgo de plataforma

> **Escalón del flujo NIMBUS (v3 — carga por escalones, ver [`decisions/004`](../../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- "evalúa esta idea contra riesgo de plataforma" / "vale la pena empezar X" / "auditoría de viabilidad de X" / "audita X contra el filtro de plataforma"
- "hay riesgo de que [Anthropic/OpenAI/Google/otro] saque esto nativo en X meses"
- Cualquier trigger del escalón `proyecto-nuevo` — el filtro corre como paso pre-grilling, ANTES del scaffolding del esqueleto.
- Cualquier idea de `~/.claude/IDEAS.md` que se vaya a aterrizar — el filtro corre antes de marcar la entrada como `Estado: aterrizada → ver proyecto X`.

## Dependencias declaradas

- Corre como paso pre-cero del escalón `proyecto-nuevo`; veredicto ESCALAR habilita su scaffolding.
- Al aterrizar una idea de `~/.claude/IDEAS.md`, corre antes de marcarla aterrizada (ver escalón `ideas-crudas`).

## Cuándo NO aplica

- Sub-rebanadas técnicas dentro de proyectos ya arrancados con `CONTEXT.md` aprobado. Proyectos activos no se re-auditan rebanada por rebanada.
- Bug fixes, refactors, mantenimiento, housekeeping.
- Adopción de tooling existente para problemas conocidos. Eso va por el escalón `evaluacion-herramientas`.
- Pivotes menores dentro de la visión del `CONTEXT.md` (ej. cambiar un proveedor de datos por otro equivalente dentro del mismo proyecto — no requiere re-filtro).

---

Sub-protocolo que se invoca cuando {{USER_NAME}} anuncia intención de arrancar trabajo nuevo: proyecto completo nuevo, idea cruda que se va a aterrizar a proyecto, o feature ambiciosa dentro de un proyecto existente que genera dependencia estratégica nueva del proyecto entero. Filtra ideas que podrían ser "tierra rentada" — funciones que las plataformas grandes (Anthropic, OpenAI, Google) podrían integrar nativamente en 6-12 meses, dejando el proyecto irrelevante.

Origen: reporte estratégico del Director adoptado el 2026-05-22. Tres mitigaciones del Constructor aplicadas al transcribir: (a) datos sin fuente primaria etiquetados como [CONJETURA] heredada del reporte; (b) "Detección de Drift" del reporte renombrada en NIMBUS como "Drift de plataforma" para evitar choque semántico con `arquitectura-mando-v2.2.0` §Detección de drift que es sobre SHAs de archivos en handoffs YAML; (c) conceptos "Maturity Premium" y "Bucle de Datos" marcados como operacionalización-pendiente cuando se apliquen a proyecto concreto.

## Las seis secciones del filtro

### 1. Axioma del Orquestador: sintaxis vs propósito

Determinar si el valor del proyecto reside en la sintaxis (capacidad de generar texto/código/imágenes/audio) o en el propósito (resolver un problema de negocio persistente).

- **Zona de Muerte:** si el producto resuelve una limitación temporal del modelo base (resumir PDFs, formatear datos, crear agentes básicos sin maquinaria detrás), es un parche. Cuando Anthropic / OpenAI / Google integren esa función nativamente, el negocio desaparece.
- **Zona de Poder:** si el producto usa la IA como un motor intercambiable para mover una maquinaria de negocio compleja, los avances de las Big Tech solo hacen que el servicio sea más potente y económico.

Pregunta operacional: ¿el valor está en la generación per se, o en la integración con maquinaria que persiste cuando el modelo base cambia?

### 2. Test del Wrapper: delgado vs grueso

Categorización técnica inmediata para medir defensibilidad.

- **Thin Wrapper (Envoltorio Delgado):** simple interfaz sobre una API. Vulnerable y fácil de replicar en un fin de semana por cualquier ingeniero.
- **Thick AI System (Sistema Grueso):** se integra bidireccionalmente con Sistemas de Registro (CRM, ERP, bases de datos), captura datos propietarios y ejecuta acciones en el mundo real con consecuencias verificables.

Pregunta operacional: si {{USER_NAME}} desaparece mañana, ¿cuánto trabajo cuesta replicar la solución desde cero? Wrapper delgado responde en horas; Sistema grueso responde en meses con datos propietarios irrecuperables.

### 3. Foso de la Verticalización (Último Kilómetro)

Las Big Tech construyen herramientas horizontales para mercado masivo. Estrategia de élite: enfocarse en el "Último Kilómetro" de las empresas, especialmente PYMES (1-500 empleados) que no tienen departamentos de IA propios.

Defensa por nicho: atacar dominios de alta ambigüedad o alta regulación (legal local, salud, manufactura específica, prospección B2B regional) donde se requiere contexto cultural y de proceso que los gigantes ignoran por diseño (no escala su modelo de negocio).

Pregunta operacional: ¿este nicho tiene contexto cultural, regulatorio o de proceso que solo se obtiene viviendo el problema seis o más meses con clientes reales?

### 4. Evolución de modelo: Copiloto a Autopiloto (SaaS 3.0)

El software que "ayuda" (Copiloto) está perdiendo valor frente al sistema que "hace el trabajo" (Autopiloto).

- **La Cuña de Subcontratación:** identificar procesos que las empresas ya externalizan a servicios humanos (ventas outsourced, soporte tier-1, auditoría externa). Esos son los procesos donde Autopiloto puede entrar como sustituto del servicio humano externo, no como herramienta del empleado interno.
- **Monetización:** no cobrar por "asiento de usuario" (modelo Copiloto), sino por resultado logrado o trabajo terminado (modelo Autopiloto).

Dato del reporte fuente: "el mercado de labor es 25 veces más grande que el de software" — [CONJETURA] heredada, sin fuente primaria citada en el reporte original.

Pregunta operacional: ¿el cliente está dispuesto a pagar por resultado (Autopiloto) o solo por asiento (Copiloto)? El primer caso es defensible; el segundo es vulnerable al licenciamiento por sede de las plataformas grandes.

### 5. Pruebas de Resistencia (cinco preguntas críticas)

El Constructor exige respuestas satisfactorias a las cinco antes de proceder con el grilling de visión del paso 1 del escalón `proyecto-nuevo`:

1. **Prueba del Problema del Lunes.** ¿Es esta una prioridad máxima que el cliente revisará el lunes a primera hora porque afecta sus ingresos directos? Si la respuesta es "es interesante pero no urgente", probable Zona de Muerte.
2. **Hipótesis LIMO (Less-Is-More).** ¿Contamos con las plantillas cognitivas (trazas de razonamiento experto del dominio) que la IA generalista no posee para este nicho? Conexión directa con el principio de Plantillas Cognitivas (Hipótesis LIMO) del piso — pocos ejemplos curados superan a muchos ejemplos genéricos.
3. **Bucle de Datos (Data Flywheel).** ¿El producto se vuelve más inteligente con cada corrección que el usuario hace? Operacionalización pendiente cuando se aplique a proyecto concreto: definir métrica cuantitativa de "más inteligente" (accuracy en eval interno, precision/recall en muestra de validación, tiempo a primera corrección, tasa de overrides, etc.).
4. **Drift de plataforma.** Si el modelo base mejora mañana, ¿el negocio se vuelve más valioso o más irrelevante? Si "más irrelevante", probable Zona de Muerte; si "más valioso" (el motor del proyecto se hace más capaz con mejor modelo subyacente), Zona de Poder. **Renombrado en NIMBUS desde "Detección de Drift" del reporte fuente para evitar choque semántico con el bloque `arquitectura-mando-v2.2.0` §Detección de drift, que es sobre SHAs de archivos en handoffs YAML inter-agente.**
5. **Maturity Premium.** ¿El cliente está dispuesto a pagar más por confianza, cumplimiento del proceso, auditabilidad de resultados? Operacionalización pendiente cuando se aplique a proyecto concreto: definir cómo se mide la prima del cliente sobre solución genérica equivalente (USD adicional por mes, % adicional sobre solución base, etc.).

### 6. Lógica de Decisión (Matriz de Acción)

Output del filtro = veredicto explícito de tres opciones que el Constructor empaca al Director para Luz Verde:

- **DESCARTAR si:** propuesta es "IA para [Tarea General]" sin control de flujo ni datos propios. Riesgo de plataforma > 80% según juicio del Constructor con criterios operacionales (Zona de Muerte de §1 + Thin Wrapper de §2 + sin Foso de Verticalización de §3 + sin Bucle de Datos de §5.3 + Drift de plataforma negativo de §5.4). El Constructor empaca veredicto DESCARTAR con razón concreta por sección + propuesta de pivote opcional si emerge naturalmente del análisis.
- **REESTRUCTURAR si:** es una buena idea pero modelo de cobro es por suscripción / Copiloto. Cambiar a cobro por éxito (Autopiloto) y verticalizar profundamente. El Constructor empaca propuesta de reestructuración con cambios específicos al `CONTEXT.md` que se redactaría.
- **ESCALAR si:** proyecto es "Dueño del Proceso", usa la IA como infraestructura base, genera foso de confianza y cumplimiento (Maturity Premium operacionalizable). El Constructor empaca veredicto ESCALAR con resumen de fortalezas por sección para alimentar el grilling de visión del paso 1 del escalón `proyecto-nuevo`.

## Aplicación operacional

1. {{USER_NAME}} dispara trigger (ver §"Cuándo carga este escalón").
2. Constructor (o Transformador cuando aplique) ejecuta el filtro de seis secciones con la idea como input.
3. Constructor genera reporte de auditoría con veredicto (DESCARTAR / REESTRUCTURAR / ESCALAR) + justificación por sección + tres conceptos operacionalización-pendiente declarados si aplica.
4. Director firma Luz Verde antes de proceder a grilling de visión (proyecto nuevo) o antes de marcar idea como `Estado: aterrizada` (idea cruda de IDEAS.md).
5. Si veredicto = DESCARTAR, Constructor anota el descarte en `persona/RETROS.md` con rationale + condición de re-entrada (mismo patrón que descartes del balde 4 de manuales sub-fase 3 v2.3.0).

## Cross-link con otros escalones

- **`ideas-crudas`:** cuando una idea pasa de `Estado: cruda` a `Estado: aterrizada → ver proyecto X`, este filtro se ejecuta antes de marcar aterrizada. Si veredicto = DESCARTAR, la idea se marca como `Estado: descartada (YYYY-MM-DD) — razón: filtro irrelevancia [sección que falló]`.
- **`proyecto-nuevo`:** este filtro corre como paso pre-cero antes del scaffolding del esqueleto. Veredicto ESCALAR habilita el paso 0 (scaffolding); veredicto REESTRUCTURAR requiere re-empaque de la idea con los cambios propuestos antes del paso 0; veredicto DESCARTAR detiene el flujo y se anota en RETROS.md.
- **`evaluacion-herramientas`:** escalón distinto. Evaluación de herramientas decide qué tool usar para un problema conocido (post-decisión de hacer el proyecto); este filtro decide si el problema mismo vale la pena resolverlo como proyecto (pre-decisión de hacerlo). Aplicables secuencialmente cuando ambos disparan.

## Validación retroactiva opcional

El filtro puede aplicarse retroactivamente para auditar proyectos activos cuando el Director lo solicite explícito ("audita [tu-proyecto] contra el filtro"). Sin aplicación automática a proyectos con `CONTEXT.md` aprobado. El output es el mismo veredicto DESCARTAR / REESTRUCTURAR / ESCALAR con justificación por sección.

## Anti-patrones documentados del reporte fuente

1. "IA para [Tarea General]" sin control de flujo ni datos propios — Thin Wrapper vulnerable.
2. Cobro por asiento de usuario para trabajo que es Autopiloto subutilizado — modelo de monetización equivocado.
3. Sintaxis general sin propósito de negocio persistente — Zona de Muerte estructural.
4. Solapamiento con función nativa de plataforma proyectada a 6-12 meses — Drift de plataforma negativo.
5. Réplica de fin de semana posible por cualquier ingeniero competente — Thin Wrapper terminal.

## Tres datos y conceptos con estatus epistémico heredado del reporte fuente

- "Mercado de labor es veinticinco veces más grande que mercado de software" — [CONJETURA] del reporte fuente. Sin fuente primaria citada en el reporte original adoptado el 2026-05-22.
- "Maturity Premium" como concepto monetizable — operacionalización pendiente cuando se aplique a proyecto concreto. Definir métrica cuantitativa de prima del cliente sobre solución genérica equivalente.
- "Bucle de Datos / Data Flywheel" como mecanismo de defensa — operacionalización pendiente con métrica cuantitativa de "más inteligente con cada corrección" (accuracy en eval, precision/recall, tiempo a primera corrección, tasa de overrides, etc.).

# Escalón: evaluacion-herramientas — build vs reuse

> **Escalón del flujo NIMBUS (v3 — carga por escalones, ver [`decisions/004`](../../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- "evalúa [tool/categoría]" / "qué uso para X" / "dame opciones para X"
- "investiga [nombre/link]" / "vale la pena [X]"
- "compara X vs Y" / "build vs reuse esto"

## Dependencias declaradas

- **CASO B** (repo/nombre específico) y la **Validación antes de adoptar** encadenan con el escalón `seguridad-externos` — el análisis de seguridad va ANTES del spike funcional.
- Decisión arquitectónica → antes de recomendar, usar la skill `/grill-with-docs`.

---

Sub-protocolo que se invoca cuando una rebanada (o el proyecto entero) necesita decidir qué herramienta usar antes de poder arrancar. Cierra el punto 4 del DoR ("sin decisiones de diseño abiertas") cuando la decisión abierta es de tooling.

## Filtro previo — antes de evaluar

Pregúntate: ¿esto realmente pide herramienta?

- Si se resuelve en N líneas de código → decirlo y proponer resolver directo. NO entrar al protocolo.
- Si es muy específico al proyecto y no hay tool razonable → decirlo y construir.
- Solo entrar al protocolo cuando hay una pieza significativa que no vale la pena construir desde cero.

## Time-box según el peso de la decisión

| Peso | Cuándo | Esfuerzo de evaluación |
|---|---|---|
| **Local** | Decisión solo afecta esta rebanada (lib de parsing, util chiquita) | 15-20 min, 1-2 candidatos |
| **Arquitectónica** | Decisión afecta el proyecto entero (DB, ORM, framework, runtime) | Evaluación completa, 3-5 candidatos, web search a fondo |

Si vas a tirar 3h evaluando para una rebanada de 2h, algo está mal calibrado. Pausar y reconsiderar.

## CASO A — el usuario da una NECESIDAD abierta

1. **Web search obligatorio** (no de memoria — pricing y mantenimiento se desactualizan rápido). Buscar 3-5 candidatos balanceados:
   - Al menos 1 SaaS pagado de referencia
   - 1 SaaS alternativo
   - 1-2 opciones open source
2. Para cada candidato reportar:
   - Qué hace
   - Costo / licencia
   - Última actividad (commits recientes, releases)
   - Encaje con el stack actual del proyecto (sacado del `CONTEXT.md`)
3. Recomendar 1-2 finalistas con razón clara, no neutral. La recomendación tiene que ser pickeable, no "depende".

## CASO B — el usuario da un NOMBRE o LINK específico

1. **Investigar a fondo en web.**
   - SaaS: docs oficiales + reviews independientes (no solo el sitio del vendor).
   - OSS: clonar el repo y leer al menos 2-3 archivos clave del código real, no solo el README.
2. Reportar:
   - Qué hace, en términos del proyecto, no genéricos
   - Fortalezas concretas
   - Red flags: issues viejos sin atender, deps pesadas, mantenimiento muerto, pricing oculto, licencia incompatible (GPL/AGPL para producto comercial)
   - Esfuerzo de integración al proyecto actual (en horas, no en "fácil/difícil")
3. Si pide comparar contra otra herramienta → hacerlo contra el proyecto específico, no en abstracto.
4. **Análisis de seguridad obligatorio** → invocar el escalón `seguridad-externos` antes de pasar a la validación. La seguridad va antes que el spike funcional, no después.

## Principios de decisión

**OSS — un repo si basta, componer solo si vale:**

- Default: si un solo repo cumple bien, usarlo. Componer agrega complejidad y costo de mantenimiento.
- Componer (tomar piezas de varios) solo cuando aporta ventaja clara: ningún repo solo cubre el caso, o la composición da resultado notablemente mejor que el mejor individual.
- Ser explícito: "el repo X cubre todo, no hace falta componer" o "X cubre el 70%, conviene sumar Y de Z porque [razón concreta]".
- No asumir que hay que usar el repo completo aunque elijas uno solo: identificar qué partes vas a usar y cuáles ignorar.
- **Licencia siempre.** MIT/Apache/BSD son seguras para producto comercial. GPL/AGPL pueden contaminar el resto del código y deben flagearse antes de recomendar.

**Build vs reuse — reusar primero, construir el delta:**

- La meta NO es "usar solo cosas que existen" a toda costa. Es maximizar lo que ya existe y construir solo el delta necesario.
- Si un repo (o composición) cubre el 80% y no hay solución decente para el 20% restante → construir ese 20% es la opción correcta.
- No forzar un fit malo solo por evitar escribir código. Una herramienta que cumple a medias termina costando más en parches y workarounds que escribir la pieza limpia.
- Ser claro: "el repo X cubre el 80%; el 20% restante (describe qué) no tiene buena solución existente, conviene construirlo".

**Costo — gratis si cumple, pagado si lo justifica:**

- Default: si la opción gratis (OSS o tier free) cumple bien, usarla. El ahorro es valor real, sobre todo en etapa temprana.
- Pagar solo se justifica con ventaja concreta que el gratis no puede dar: cobertura de datos, soporte real, SLA, compliance, ahorro de tiempo significativo, o es core del producto y no puede fallar.
- Comparar con números cuando se pueda: "el pagado cuesta $X/mes pero ahorra Y horas/mes de mantenimiento, sí se justifica".
- Considerar el camino medio: tier free + upgrade después suele ser mejor que comprometerse a pagado de entrada.

**Bias a continuidad — primero lo que ya tienes:**

- Si el stack actual ya tiene algo que cubre razonablemente la necesidad, NO meter una tool nueva solo porque es "mejor en abstracto".
- Razón fuerte para cambiar = la tool actual claramente no cubre el caso, o el costo de mantenerla es mayor al de migrar.
- Cada tool nueva añade superficie de mantenimiento, dependencias, y carga cognitiva para quien retome el proyecto.

## Validación antes de adoptar

Antes del spike, **el análisis de seguridad debe estar hecho** (escalón `seguridad-externos`). Si el veredicto es `No recomendado` → no hay spike, volver a Casos A/B. Si es `Usar con precaución` → el spike incluye verificar que las mitigaciones funcionan, no solo el happy path.

Después de recomendar el finalista, **NO adoptar formalmente todavía.** Sugerir un spike corto con un caso real del proyecto (no el "happy path" del demo del vendor):

1. Tomar un caso real del proyecto que refleje un edge case típico.
2. Hacer un spike de 30-60 min con la tool candidata.
3. Si pasa → adoptar y documentar (siguiente paso).
4. Si falla → volver a Casos A/B con lo aprendido (probablemente había un requisito que no estaba claro).

Lo que se ve bien en docs a veces falla con la data real, edge cases, o el stack específico del proyecto. La prueba previa evita el costo de una mala adopción.

## Documentar la decisión

Después de adoptar (post-validación), crear `[proyecto]/decisions/NNN-<nombre>.md`:

````markdown
# NNN — <decisión en una frase>

**Fecha:** YYYY-MM-DD
**Estado:** Adoptado / Rechazado / Reemplazado por NNN-<otro>

## Problema
<qué se necesitaba resolver, en términos del proyecto>

## Opciones consideradas
- **<tool A>:** <pros / contras / costo / por qué no se eligió>
- **<tool B>:** <pros / contras / costo / por qué no se eligió>
- **<tool elegida>:** <pros / contras / costo>

## Decisión
<qué se eligió, o qué piezas se compusieron, y por qué>

## Consecuencias
<qué cambia en el proyecto: nuevas deps, costos, mantenimiento esperado, riesgos>
````

NNN es secuencial (001, 002, 003...). NO se borran las decisiones antiguas — se marcan como "Reemplazado por NNN-<otro>" cuando aplica.

## Conexión con grilling

Si la decisión es arquitectónica (afecta el proyecto entero), antes de recomendar invocar `/grill-with-docs` para confirmar el contexto del proyecto contra el `CONTEXT.md` existente. Sin esto, la recomendación es a ciegas.

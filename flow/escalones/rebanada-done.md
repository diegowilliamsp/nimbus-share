# Escalón: rebanada-done — Definition of Done

> **Escalón del flujo NIMBUS (v3 — carga por escalones, ver [`decisions/004`](../../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- Al cerrar una rebanada, para decidir si está realmente lista antes de pasar a la siguiente.

## Dependencias declaradas

- El cierre formal de la sesión (commit + ESTADO.md) vive en el escalón `cierre-sesion`.

---

## Definición de "rebanada lista" — Definition of Done

Una rebanada solo se marca como lista cuando cumple las **tres** condiciones, no dos:

1. **Corre end-to-end sin errores.** No "los tests pasan", sino que el flujo completo de la rebanada funciona.
2. **El usuario la verificó con sus ojos** — no basta con que Claude reporte "ya quedó". El método depende del tipo de rebanada:
   - **UI / frontend:** demo en el navegador o captura del flujo funcionando.
   - **CLI / script:** correr el comando juntos y revisar el output esperado.
   - **API / backend:** hit con `curl`/`httpie`, mostrar el response. Si hay efecto en DB, query de verificación.
   - **Pipeline de datos / ETL:** correr con sample real, mostrar el output (head del DataFrame, count de filas, schema check).
   - **Notebook:** correr cells end-to-end, mostrar las gráficas o tablas finales.
   - **Lógica con tests:** los tests pasan + un caso real verificado a mano. Los tests no son la verificación final, son red de seguridad.
3. **`ESTADO.md` actualizado** — la rebanada movida de "Próximo" a "Hecho" con fecha.

Si falta cualquiera de las 3, la rebanada NO está lista — no avanzar a la siguiente. Frases como "ya casi", "solo falta un detalle" significa que sigue en la actual, no es nueva.

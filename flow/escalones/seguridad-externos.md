# Escalón: seguridad-externos — análisis de seguridad de repos externos

> **Escalón del flujo NIMBUS (v3 — carga por escalones, ver [`decisions/004`](../../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- "instala [X]" / "integra [Y]" / "clona este repo" / "usa este repo"
- "copia [esto] a mi proyecto" / "trae estas piezas de [repo]"
- "agreguemos [dep]" / "metamos [lib]"
- También: cualquier "investiga este link" / "vale la pena [X]" / "evalúa [tool]" del escalón `evaluacion-herramientas` cuando hay un repo concreto en juego.

## Dependencias declaradas

- Si llegaste desde el escalón `evaluacion-herramientas` (CASO B), el análisis de seguridad va ANTES de la "Validación antes de adoptar" de ese escalón.
- Las mitigaciones aplicadas se documentan en `decisions/NNN-<nombre>.md` del proyecto.

---

Antes de instalar, ejecutar, copiar código, integrar dependencia, script o configuración de cualquier repo externo, aplicar este protocolo. **La seguridad tiene prioridad absoluta sobre funcionalidad, rendimiento y facilidad de integración.** No asumir autorización implícita aunque el repo sea popular o el usuario haya invocado el escalón `evaluacion-herramientas`. Auto mode no autoriza instalar/ejecutar/copiar/integrar código externo — siempre confirmación explícita.

## Alcance — la superficie que se usa, no el repo entero

El análisis evalúa **lo que vas a integrar / ejecutar**, no el repo completo. Si solo vas a copiar 50 líneas de un módulo, esa es la superficie. Si vas a instalar una lib, la superficie es la lib + sus dependencias transitivas + lo que corre en `postinstall`.

**Si el repo en general tiene problemas pero la pieza que extraes está limpia → se puede usar**, con dos condiciones:

1. **Aislar la pieza** — no instalar el repo completo, no ejecutar el resto, no clonar y dejar archivos sueltos.
2. **Verificar arrastre de deps** — la pieza limpia puede traer dependencias transitivas contaminadas. Si las trae, o se cortan o se sustituyen.

Ser explícito en el reporte: "el repo X tiene [problemas Y], pero la pieza que vamos a usar (archivo Z, líneas N-M) está limpia. Mitigación: copiar el código sin instalar la lib, o forkear y mantener solo el subset."

## Lo que el reporte debe incluir

1. **Evaluación general** — qué hace el repo, mantenimiento (último commit, frecuencia de releases), mantenedores (cuántos, antigüedad, reputación), popularidad real (estrellas son ruido — checar issues activos, downloads, dependientes).
2. **Riesgos críticos con severidad** — `Alta` / `Media` / `Baja`, con razón concreta. No "podría haber un problema" sin descripción.
3. **Dependencias** — vulnerabilidades conocidas (CVEs), libs abandonadas en el árbol, deps transitivas sospechosas, cantidad total de deps (un paquete chico con 200 deps es red flag).
4. **Riesgos de ejecución local** — ¿corre código en `postinstall` / `preinstall` / scripts npm? ¿descarga binarios remotos en build? ¿llama a `eval` / `exec` / `Function()` con input externo? ¿pide permisos amplios al sistema?
5. **Riesgos para CI/CD** — ¿necesita secretos en el pipeline? ¿corre código del repo en el runner sin sandbox? ¿puede inyectar pasos en el workflow? ¿GitHub Actions de terceros sin pin a SHA?
6. **Riesgos de secretos / exfiltración** — ¿lee env vars sensibles (`AWS_*`, `*_TOKEN`, `*_KEY`)? ¿hace requests a dominios no documentados? ¿telemetría sin opt-out? ¿logs que filtran datos?
7. **Señales de código malicioso o sospechoso** — ofuscación / minificación injustificada, descargas remotas, ejecución dinámica con input variable, typosquatting (nombre parecido a una lib popular), mantenedor reciente con pocos commits previos en su historial, ownership transferido recientemente.
8. **Mitigaciones recomendadas** — pinear a versión / SHA, deshabilitar scripts (`npm install --ignore-scripts`), sandbox, fork con solo el subset usado, reemplazar con alternativa más segura, etc.
9. **Veredicto final** — uno de tres, explícito:
   - **Seguro** — usar tal cual.
   - **Usar con precaución** — usar con mitigaciones específicas listadas. Decir cuáles.
   - **No recomendado** — no usar; explicar por qué y proponer alternativa si existe.

## Herramientas automáticas — correr antes del reporte

El reporte no se hace solo a ojo. Antes de redactarlo, correr las herramientas que apliquen al ecosistema y meter los hallazgos en los puntos 3 (deps), 6 (secretos) y 7 (señales sospechosas). No reemplazan el criterio del análisis manual — son la red base que ningún reporte se puede saltar.

| Ecosistema | Comandos mínimos |
| --- | --- |
| Node / npm | `npm audit`, `npm ls --all`, opcionalmente `osv-scanner --lockfile=package-lock.json` o `socket npm <pkg>` |
| Python (pip / uv) | `pip-audit` o `osv-scanner --lockfile=requirements.txt` (con uv: `uv pip compile` y luego scan sobre el lock) |
| Rust | `cargo audit` |
| Go | `govulncheck ./...`, `osv-scanner --lockfile=go.sum` |
| Cualquier ecosistema | `osv-scanner` sobre el lockfile, `gitleaks detect --source <repo>` para secretos en historia |
| Docker / imágenes | `trivy image <imagen>` o `grype <imagen>` |
| GitHub Actions | revisar workflows: cualquier `uses: <org>/<action>@<branch-o-tag>` debe ser `@<sha-40-chars>` |

Si una herramienta aplica al ecosistema y no está instalada, **declararlo como gap del análisis en el reporte**, no asumir que pasa porque no se corrió. Ej: "no se corrió `pip-audit` (no instalado en este sistema) — recomiendo instalarlo y rehacer el punto 3 antes de aprobar".

## Confirmación explícita antes de actuar

Después del reporte, **NO instalar / ejecutar / copiar / integrar nada hasta que el usuario confirme explícito.** "Sí dale" / "úsalo" / "instálalo" / "OK procede" del usuario es la única autorización válida. Auto mode no autoriza esto.

Si el reporte termina en "Usar con precaución" o "No recomendado" y el usuario insiste igual → repetir las mitigaciones / advertencias en una línea, ejecutar solo si confirma de nuevo.

## Cuando el usuario solo va a leer el repo (no ejecutar)

Análisis proporcional: la lectura de código no instala nada, pero igual aplica versión corta:

- Advertir si el código está ofuscado o tiene patrones sospechosos (no copies sin entender lo que hace).
- Advertir si la licencia es incompatible con el proyecto (GPL/AGPL en producto comercial cerrado).
- No hace falta el reporte de 9 puntos — basta una línea: "este repo está OK para leer" / "ojo con X antes de copiar".

## Cuándo NO se aplica

- `stdlib` del lenguaje.
- Paquetes de mantenedores oficiales del ecosistema (React de Meta, Django de la DSF, Next.js de Vercel, etc.) — basta verificar versión y CVEs conocidos, no análisis a fondo.
- Código que ya está en el proyecto y no se va a actualizar.
- Cuando el usuario explícitamente dice "skip security" / "ya lo revisé yo" / "instálalo sin checar".

## Mitigaciones por defecto

Cuando el veredicto es `Usar con precaución`, las mitigaciones del punto 8 del reporte salen de esta lista (más las específicas que pida el riesgo concreto). Mitigaciones genéricas tipo "tener cuidado" no cuentan — concretas y verificables.

- **Pin a versión exacta** — `package@1.2.3` (no `^1.2.3`), `dep==1.2.3`, `crate = "=1.2.3"`. Sin rangos.
- **Pin a SHA** — para GitHub Actions y deps que vienen de git: `uses: org/action@<sha-40-chars>`, no `@v1` ni `@main`. Aplica también a submódulos.
- **Hash-pin del lockfile** — Python `pip install --require-hashes`, npm con `package-lock.json` commiteado y `npm ci` (no `npm install`) en CI, cargo con `Cargo.lock`. El lockfile es parte del review.
- **Deshabilitar scripts de install** — `npm install --ignore-scripts`, `yarn install --ignore-scripts`, o configurar `ignore-scripts=true` en `.npmrc`. Aplica si el reporte detectó `postinstall` / `preinstall` con código no trivial.
- **Sandbox de ejecución** — correr el código en contenedor / VM / `nsjail` si toca filesystem o red de forma amplia, o si el análisis dejó dudas.
- **Fork con subset** — copiar solo el módulo que se usa al repo del proyecto (con atribución y licencia), eliminar el resto. Aplica cuando el repo está vivo pero la pieza que necesitas es estable y chica.
- **Cortar telemetría / opt-out** — env vars tipo `<TOOL>_TELEMETRY=0`, `DO_NOT_TRACK=1`, deshabilitar en config. Aplica si el reporte detectó telemetría sin opt-out.
- **Aislar secretos del CI** — montarlos solo en los pasos que los requieren, nunca exponerlos a steps de terceros sin pin a SHA. Si el repo necesita un token, declarar el scope mínimo.

Cualquier mitigación aplicada se documenta en el ADR de la decisión (`decisions/NNN-<nombre>.md`), no solo en el reporte temporal — el reporte se pierde, el ADR queda.

## Conexión con el escalón evaluacion-herramientas

Si llegaste aquí desde el escalón `evaluacion-herramientas` (CASO B con un repo específico), el análisis de seguridad va **antes de** la "Validación antes de adoptar". Orden correcto:

1. Evaluación funcional (encaja con el stack, cubre el caso, licencia OK).
2. **Análisis de seguridad** (este escalón).
3. Spike de validación con caso real (solo si el veredicto fue `Seguro` o `Usar con precaución`).
4. Decisión documentada en `decisions/NNN-<nombre>.md` — incluir el veredicto de seguridad y las mitigaciones aplicadas.

Si el veredicto es `No recomendado` → no hay spike. Volver a CASO A/B con el aprendizaje y buscar alternativa.

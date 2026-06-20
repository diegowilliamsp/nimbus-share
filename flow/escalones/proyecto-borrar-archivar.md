# Escalón: proyecto-borrar-archivar — archivar o borrar

> **Escalón del flujo NIMBUS (v3 — carga por escalones, ver [`decisions/004`](../../decisions/004-carga-dinamica-por-escalones-con-candado-hook.md)).** Se carga solo cuando dispara su trigger; asume el **piso** cargado (principios rectores, roles del meta-sistema y reglas de comunicación del `CLAUDE.md` global). No requiere el resto del flujo.

## Cuándo carga este escalón (triggers)

- **Archivar** (default seguro, recuperable): "archiva [proyecto]" / "guarda [proyecto] como archivado" / "pausa [proyecto] indefinido".
- **Borrar de verdad** (destructivo, no recuperable): "borra el proyecto [X]" / "elimina [X]" / "matemos [X]" / "tíralo".

## Dependencias declaradas

- Antes de un borrado/archivado con trabajo sin commitear, encadena con el escalón `cierre-sesion`.
- El snapshot de seguridad y el respaldo previo a operaciones destructivas viven en el escalón `mecanica-git`.

---

Cerrar un proyecto para siempre (o pausarlo indefinidamente) es operación destructiva. Tiene su propio protocolo, distinto al cierre de sesión.

**Regla clave:** si el usuario no es explícito, asumir **archivar**, no borrar. Borrar requiere que la palabra "borra" / "elimina" / "tira" aparezca literal.

**Inventario antes de tocar nada:**

Listar al usuario qué se va a afectar, en este orden:

1. Directorio del proyecto: `<path>` (tamaño, último commit).
2. Memorias en `~/.claude/projects/<perfil-detectado>/memory/` que referencian al proyecto (buscar `project_<nombre>.md` y otras referencias). El path exacto depende del usuario y se detecta dinámicamente con `ls ~/.claude/projects/`.
3. Entrada en `MEMORY.md`.
4. Repo remoto si existe (`gh repo view` o `git remote -v`).

Mostrar el inventario completo y pedir **confirmación explícita** antes de cualquier acción. Auto mode no autoriza esto.

## Protocolo: ARCHIVAR (default)

1. Crear `~/Developer/otros/_archive/` si no existe.
2. Cerrar sesión activa primero (escalón `cierre-sesion` completo) si hay trabajo sin commitear.
3. `mv <proyecto> ~/Developer/otros/_archive/<nombre>-YYYYMMDD/`.
4. Memorias del proyecto: mover a `~/.claude/projects/<perfil-detectado>/memory/archive/` (crear carpeta si no existe). NO borrar — el contexto sigue siendo útil si se retoma.
5. `MEMORY.md`: mover la entrada de la lista activa a una sección `## Archivados` al final del archivo. Si la sección no existe, crearla.
6. Repo remoto: NO tocarlo. Avisar al usuario "el repo remoto en [url] sigue activo, decide tú si lo borras manualmente".
7. Reporte final: qué se movió, dónde quedó, cómo recuperarlo (`mv ~/Developer/otros/_archive/<nombre>-YYYYMMDD <path-original>`).

## Protocolo: BORRAR DE VERDAD

1. **Confirmación doble.** Mostrar el inventario completo y pedir al usuario que escriba literal `BORRAR <nombre>` para confirmar. Si no lo escribe exacto, abortar.
2. **Snapshot de seguridad obligatorio:** `tar -czf ~/Developer/otros/_archive/.deleted/<nombre>-YYYYMMDD.tar.gz <proyecto>`. Crear `~/Developer/otros/_archive/.deleted/` si no existe. Esto NO se le dice "ya no recuperable" al usuario porque en realidad sí lo es desde el tar — pero el tar se borra solo si el usuario lo pide después. Es red de seguridad, no estado oficial.
3. `rm -rf <proyecto>`.
4. Memorias del proyecto: borrar archivos `project_<nombre>.md` y referencias.
5. `MEMORY.md`: quitar la entrada completamente (no archivar).
6. Repo remoto: si existe, preguntar al usuario "¿también borro el remoto en [url]? sí/no". Si dice sí, ejecutar `gh repo delete <repo> --yes`. Si dice no, dejarlo.
7. Reporte final: qué se borró, dónde está el snapshot tar.gz por si cambia de opinión.

## Si el usuario pide borrar a media sesión sin contexto

Si la frase llega sin que estuviéramos trabajando en ese proyecto en la sesión actual:

- NO ejecutar de inmediato.
- Leer primero los documentos del proyecto (`CLAUDE.md`, `CONTEXT.md`, `ESTADO.md`, vistazo a `decisions/` si existe) para tener contexto.
- Mostrar inventario y resumen de qué es el proyecto, qué tan reciente, qué se perdería.
- Preguntar: "¿quieres archivar (recuperable) o borrar de verdad?"
- Esperar respuesta explícita antes de cualquier `mv` o `rm`.

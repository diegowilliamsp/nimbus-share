#!/usr/bin/env bash
# Hook UserPromptSubmit de NIMBUS v3.7 — entrega los medidores calculados + el bloque
# inyectable del router (marcadores NIMBUS:INYECTAR en ~/.claude/ROUTER.md).
#
# ORDEN DE LA SALIDA (regla de diseño, no estética): lo CALCULADO primero, la prosa nunca.
# Motivo medido el 2026-08-06: el harness corta la salida de un hook que excede su tope
# (~13.9 KB observado) e inyecta solo un preview de ~2 KB. Con el router entero (15.7 KB)
# se perdían la tabla trigger→escalón Y los medidores. Ver ROUTER.md §"Por qué el bloque
# va primero y es chico".
#
# FAIL-OPEN de ley: cualquier fallo de medición => "s/d"; el turno NUNCA se rompe.
# Diseño y porqué de cada medidor: flow/ROUTER.md, sección "El porqué" (lo que va DEBAJO
# del marcador NIMBUS:INYECTAR:FIN no se inyecta — se lee bajo demanda).

# --- 1. Leer stdin (JSON del harness) sin colgar; tolerar ausencia ---
input=""
if [ ! -t 0 ]; then
  input=$(cat 2>/dev/null)
fi

# --- 1b. Extractor de campos JSON: jq si existe, sed si no, vacío si nada ---
# El hook puede correr con un PATH restringido, así que jq es opcional, nunca requisito.
JQ=""
for c in jq /opt/homebrew/bin/jq /usr/local/bin/jq /usr/bin/jq; do
  if command -v "$c" >/dev/null 2>&1; then JQ="$c"; break; fi
done

json_str() {  # $1 = nombre del campo; imprime el valor o nada
  local k="$1"
  if [ -z "$input" ]; then return 0; fi
  if [ -n "$JQ" ]; then
    printf '%s' "$input" | "$JQ" -r --arg k "$k" '.[$k] // empty' 2>/dev/null
  else
    # Respaldo sin jq: sirve para valores simples (rutas, ids). No se usa para prompt_text.
    printf '%s' "$input" | sed -n "s/.*\"$k\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
  fi
}

transcript=$(json_str transcript_path)
sid=$(json_str session_id)

# --- 2. Medidor CONTEXTO + SESIÓN (todo envuelto; nunca aborta el turno) ---
gauge="⚪ s/d"
{
  CTX_FULL_BYTES=1500000   # tamaño de conversación tratado como "lleno / conviene reiniciar"; tunable
  CTX_AMBER_PCT=60         # ámbar   → recomendar /compact
  CTX_RED_PCT=80           # rojo    → recomendar /clear
  CTX_CRIT_PCT=92          # crítico → recomendar cerrar sesión

  pct=""
  if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    # Bytes DESDE el último /compact, no del archivo entero. El transcript nunca se
    # recorta: al compactar el harness escribe una marca y SIGUE en el mismo archivo.
    # Medir el archivo completo dejaba el medidor pegado en 100% justo después de
    # compactar — o sea, justo después de que el propio medidor pidió compactar
    # (medido 2026-08-06: 1,628,187 B de archivo vs 132,508 B reales = 100% vs 8.8%).
    # El patrón va SIN escapar a propósito: cuando el marcador aparece citado dentro de
    # texto de conversación va escapado (\"subtype\":\"...\"), así que hablar de él aquí
    # no dispara un falso positivo. LC_ALL=C para que length() cuente BYTES, no glifos.
    bytes=$(LC_ALL=C awk '
      { tot += length($0) + 1 }
      /"type":"system","subtype":"compact_boundary"/ { pre = tot - length($0) - 1 }
      END { print tot - pre }
    ' "$transcript" 2>/dev/null | tr -d ' ')
    if [ -n "$bytes" ] && [ "$bytes" -ge 0 ] 2>/dev/null; then
      pct=$(( bytes * 100 / CTX_FULL_BYTES ))
      [ "$pct" -gt 100 ] && pct=100
    fi
  fi

  ctx_cmd=""
  ctx_dot="🟢"
  if [ -n "$pct" ]; then
    if   [ "$pct" -ge "$CTX_CRIT_PCT" ]; then ctx_cmd="→ cerrar sesión"; ctx_dot="🆘"
    elif [ "$pct" -ge "$CTX_RED_PCT"  ]; then ctx_cmd="→ /clear";        ctx_dot="🔴"
    elif [ "$pct" -ge "$CTX_AMBER_PCT" ]; then ctx_cmd="→ /compact";      ctx_dot="🟡"
    fi
  fi

  elapsed_lbl=""
  turns=""
  if [ -n "$sid" ]; then
    sdir="$HOME/.claude/.nimbus-sessions"
    mkdir -p "$sdir" 2>/dev/null
    sfile="$sdir/$sid"
    now=$(date +%s)
    if [ -f "$sfile" ]; then
      read -r start t < "$sfile" 2>/dev/null
      [ -z "$t" ] && t=0
      t=$(( t + 1 ))
    else
      start=$now
      t=1
    fi
    [ -z "$start" ] && start=$now
    echo "$start $t" > "$sfile" 2>/dev/null
    turns=$t
    secs=$(( now - start ))
    [ "$secs" -lt 0 ] && secs=0
    mins=$(( secs / 60 ))
    if [ "$mins" -ge 60 ]; then
      elapsed_lbl="$(( mins / 60 ))h$(printf '%02d' $(( mins % 60 )))"
    else
      elapsed_lbl="${mins}min"
    fi
  fi

  if [ -n "$pct" ]; then
    fill=$(( pct / 10 ))
    [ "$fill" -gt 10 ] && fill=10
    [ "$fill" -lt 0 ] && fill=0
    bar=""
    i=0
    while [ "$i" -lt 10 ]; do
      if [ "$i" -lt "$fill" ]; then bar="${bar}▓"; else bar="${bar}░"; fi
      i=$(( i + 1 ))
    done
    sess=""
    [ -n "$elapsed_lbl" ] && sess=" · sesión ${elapsed_lbl}/${turns}t"
    cmd_sfx=""
    [ -n "$ctx_cmd" ] && cmd_sfx=" ${ctx_cmd}"
    gauge="${ctx_dot} ${bar} ~${pct}%${sess}${cmd_sfx}"
  elif [ -n "$elapsed_lbl" ]; then
    gauge="⚪ s/d · sesión ${elapsed_lbl}/${turns}t"
  fi
} 2>/dev/null

# --- 2b. Estado de guardado (💾) del repo en el cwd; fail-open (no-repo => omitido) ---
savestate=""
{
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    dirty=$(git status --porcelain 2>/dev/null)
    if [ -n "$dirty" ]; then
      n=$(printf '%s\n' "$dirty" | grep -c .)
      savestate="🔴 ░░░░░░░░░░ sin guardar · ${n}"
    else
      ahead=$(git rev-list --count '@{u}..HEAD' 2>/dev/null)
      if   [ -z "$ahead" ];                  then savestate="🟡 █████░░░░░ limpio · local"
      elif [ "$ahead" -gt 0 ] 2>/dev/null;   then savestate="🟡 █████░░░░░ limpio · ${ahead}⇡"
      else                                        savestate="🟢 ██████████ pusheado"
      fi
    fi
  fi
} 2>/dev/null

# --- 2c. Modelo y effort — REAL (transcript) contrastado contra el default (settings) ---
# Ninguno viene en el stdin del hook (el contrato de UserPromptSubmit trae session_id,
# prompt_id, transcript_path, cwd, permission_mode, hook_event_name, prompt_text).
# Dos fuentes, a propósito:
#   REAL     = cola del transcript. Cada registro de assistant trae el modelo que corrió
#              ("message":{"model":...) y el effort con el que corrió ("effort":...).
#              Va un turno atrasado (es el turno anterior), pero es lo que DE VERDAD pasó.
#   DEFAULT  = ~/.claude/settings.json, donde escriben /model y /effort. Es el default de
#              sesiones NUEVAS: un override solo-para-esta-sesión no aparece aquí.
# Si discrepan (comparando FAMILIA, no string), se marca — esa discrepancia es justo la
# señal de que hay un override vivo, no un error.
cfgline=""
cfgwarn=""
{
  # Familia normalizada, para no marcar "claude-opus-5" vs "opus[1m]" como discrepancia.
  fam() { printf '%s' "$1" | tr 'A-Z' 'a-z' | sed 's/claude-//; s/\[1m\]//; s/-[0-9].*$//' | tr -cd 'a-z'; }

  rm_=""; re_=""
  if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    # Solo la cola: barato aunque el transcript pese megas. `isSidechain":false` descarta
    # a los sub-agentes, que pueden correr con otro modelo y falsearían la lectura.
    tailbuf=$(tail -c 300000 "$transcript" 2>/dev/null | grep '"isSidechain":false' 2>/dev/null)
    rm_=$(printf '%s\n' "$tailbuf" | grep -o '"message":{"model":"[^"]*"' | tail -1 | sed 's/.*"model":"//; s/"$//')
    re_=$(printf '%s\n' "$tailbuf" | grep -o '"effort":"[a-z]*"'          | tail -1 | sed 's/.*:"//; s/"$//')
  fi

  sm=""; se=""
  S="$HOME/.claude/settings.json"
  if [ -f "$S" ]; then
    if [ -n "$JQ" ]; then
      sm=$("$JQ" -r '.model // empty' "$S" 2>/dev/null)
      se=$("$JQ" -r '.effortLevel // empty' "$S" 2>/dev/null)
    else
      sm=$(sed -n 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$S" | head -1)
      se=$(sed -n 's/.*"effortLevel"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$S" | head -1)
    fi
  fi

  if [ -n "$rm_" ] || [ -n "$re_" ]; then
    cfgline="🤖 ${rm_:-s/d} · 🎚️ ${re_:-s/d}   ← REAL, lo que corrió el turno pasado; recomienda CONTRA esto"
    dm=""; de=""
    [ -n "$rm_" ] && [ -n "$sm" ] && [ "$(fam "$rm_")" != "$(fam "$sm")" ] && dm="modelo=${sm}"
    [ -n "$re_" ] && [ -n "$se" ] && [ "$re_" != "$se" ]                   && de="effort=${se}"
    if [ -n "$dm" ] || [ -n "$de" ]; then
      cfgwarn="   ⚠️ settings.json (default de sesiones nuevas) dice ${dm}${dm:+ }${de} — hay override vivo en ESTA sesión"
    fi
  elif [ -n "$sm" ] || [ -n "$se" ]; then
    # Sin transcript legible: se cae al default, con la etiqueta honesta.
    cfgline="🤖 ${sm:-s/d} · 🎚️ ${se:-s/d}   ← default de settings.json (no pude leer el turno real)"
  fi
} 2>/dev/null

# --- 2d. Pre-match del escalón contra prompt_text (SUGERENCIA, sin autoridad) ---
# El match por palabras se rompe con paráfrasis; quien entiende la frase es el Constructor.
# Sirve de red: si el hook propone y el Constructor no carga nada, algo se saltó.
# Sin jq NO se intenta: extraer prompt_text con sed es frágil (comillas/saltos escapados)
# y buscar sobre el JSON crudo daría falsos positivos con el cwd (ej. ".../PROYECTOS/...").
prematch=""
{
  if [ -n "$JQ" ] && [ -n "$input" ]; then
    ptext=$(printf '%s' "$input" | "$JQ" -r '.prompt_text // empty' 2>/dev/null)
    if [ -n "$ptext" ]; then
      hits=""
      add() { case " $hits " in *" $1 "*) ;; *) hits="$hits $1";; esac; }
      p() { printf '%s' "$ptext" | grep -qiE "$1" 2>/dev/null && add "$2"; }
      p 'proyecto nuevo|empecemos|voy a empezar|abramos|hagamos un proyecto'  'proyecto-nuevo'
      p 'sigamos con|continuemos con|retomemos|seguimos con'                  'proyecto-continuar'
      p 'adopta|adoptarlo|registra este proyecto|usa nimbus'                  'adoptar-proyecto'
      p 'archiva|borra el proyecto|elimina el proyecto|t[íi]ralo'             'proyecto-borrar-archivar'
      p 'trabado|atorado|bug duro|regresi[óo]n de performance'                'claude-trabado'
      p 'eval[úu]a|qu[ée] uso para|build vs reuse|comp[áa]rame'               'evaluacion-herramientas'
      p 'instala|integra|clona este repo|agregu?emos dep|agrega dep'          'seguridad-externos'
      p 'vale la pena empezar|riesgo de plataforma|saqu[ee]n? esto nativo'    'filtro-plataforma'
      p 'guarda esta idea|anota esta idea|anota esto en ideas|descarta la idea' 'ideas-crudas'
      p 'configura nimbus|personaliza nimbus|onboarding|setup nimbus|nimbus-setup' 'nimbus-onboarding'
      p 'nos vemos|ah[íi] la dejamos|ya cerramos|c[óo]rtale|cerramos sesi[óo]n' 'cierre-sesion'
      p 'pre-commit|reset --hard|force push|git destructivo'                  'mecanica-git'
      [ -n "$hits" ] && prematch="🧩 posible escalón:${hits}  ← sugerencia por palabra; confirma o corrige"
    fi
  fi
} 2>/dev/null

# --- 3. SALIDA: lo calculado PRIMERO (sobrevive cualquier corte del harness) ---
echo "━━ NIMBUS · medido por el hook — copiar TAL CUAL en el ESTATUS ━━"
[ -n "$savestate" ] && echo "💾 GUARDADO   ${savestate}"
echo "📊 CONTEXTO   ${gauge}"
[ -n "$cfgline" ]   && echo "${cfgline}"
[ -n "$cfgwarn" ]   && echo "${cfgwarn}"
[ -n "$prematch" ]  && echo "${prematch}"
echo ""

# --- 4. Bloque inyectable del router (una sola fuente de verdad: ~/.claude/ROUTER.md) ---
R="$HOME/.claude/ROUTER.md"
if [ ! -f "$R" ]; then
  echo "AVISO NIMBUS: ~/.claude/ROUTER.md no encontrado — router no cargado. Revisar symlink / install.sh."
else
  blk=$(awk '/NIMBUS:INYECTAR:INICIO/{f=1;next} /NIMBUS:INYECTAR:FIN/{f=0} f' "$R" 2>/dev/null)
  if [ -n "$blk" ]; then
    printf '%s\n' "$blk"
  else
    # Marcadores ausentes o rotos: NO quedarse callado — entregar el router entero.
    echo "AVISO NIMBUS: no encontré los marcadores NIMBUS:INYECTAR en ROUTER.md — entrego el router completo (puede truncarse)."
    cat "$R"
  fi
fi

# --- 5. Recordatorio de la ley (corto: la plantilla canónica ya va arriba) ---
echo ""
echo "LEY NIMBUS: cierra CADA respuesta con el bloque ESTATUS de arriba, SIEMPRE al final."
echo "Nunca lo omitas: trivial o ack => variante 'escalón 0' (💾 + 🧩 + 📊)."
echo "Carga SOLO el/los escalón(es) que apliquen, de ~/.claude/escalones/."

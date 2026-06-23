#!/usr/bin/env bash
# Hook UserPromptSubmit de NIMBUS v3: entrega el router + el mandato del ESTATUS en cada turno,
# y calcula el medidor de CONTEXTO + SESIÓN.
# FAIL-OPEN: cualquier fallo de la medición => gauge "s/d"; el router y el turno NUNCA se rompen.
# Diseño: NIMBUS v3 — carga dinámica por escalones + candado por hook.

# --- 1. Leer stdin (JSON del harness) sin colgar; tolerar ausencia ---
input=""
if [ ! -t 0 ]; then
  input=$(cat 2>/dev/null)
fi

# --- 2. Medidor CONTEXTO + SESIÓN (todo envuelto; nunca aborta el turno) ---
gauge="s/d (medición no disponible)"
{
  CTX_FULL_BYTES=1500000   # tamaño de conversación (bytes del transcript) tratado como "lleno / conviene reiniciar"; tunable
  CTX_AMBER_PCT=60         # ámbar   → recomendar /compact   (calibrable)
  CTX_RED_PCT=80           # rojo    → recomendar /clear
  CTX_CRIT_PCT=92          # crítico → recomendar cerrar sesión

  transcript=$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
  sid=$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

  # Contexto: bytes del transcript vs umbral de reinicio
  pct=""
  if [ -n "$transcript" ] && [ -f "$transcript" ]; then
    bytes=$(wc -c < "$transcript" 2>/dev/null | tr -d ' ')
    if [ -n "$bytes" ] && [ "$bytes" -ge 0 ] 2>/dev/null; then
      pct=$(( bytes * 100 / CTX_FULL_BYTES ))
      [ "$pct" -gt 100 ] && pct=100
    fi
  fi

  # Banda del medidor -> comando recomendado (verde=nada / ámbar=/compact / rojo=/clear / crítico=cerrar)
  ctx_cmd=""
  if [ -n "$pct" ]; then
    if   [ "$pct" -ge "$CTX_CRIT_PCT" ]; then ctx_cmd="→ cerrar sesión"
    elif [ "$pct" -ge "$CTX_RED_PCT"  ]; then ctx_cmd="→ /clear"
    elif [ "$pct" -ge "$CTX_AMBER_PCT" ]; then ctx_cmd="→ /compact"
    fi
  fi

  # Sesión: tiempo + turnos, estado por sesión en ~/.claude/.nimbus-sessions/<sid>
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

  # Barra de contexto (10 celdas) + sesión
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
    gauge="${bar} ~${pct}%${sess}${cmd_sfx}"
  elif [ -n "$elapsed_lbl" ]; then
    gauge="sesión ${elapsed_lbl}/${turns}t (contexto s/d)"
  fi
} 2>/dev/null

# --- 2b. Estado de guardado (💾) del repo en el cwd; fail-open (no-repo => omitido) ---
savestate=""
{
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      savestate="sin guardar"
    else
      ahead=$(git rev-list --count '@{u}..HEAD' 2>/dev/null)
      if   [ -z "$ahead" ];                  then savestate="limpio · sin upstream"
      elif [ "$ahead" -gt 0 ] 2>/dev/null;   then savestate="limpio · ${ahead} sin pushear"
      else                                        savestate="limpio · pusheado"
      fi
    fi
  fi
} 2>/dev/null

# --- 2c. Aviso de onboarding pendiente (NIMBUS aún sin personalizar) ---
if [ -f "$HOME/.claude/.nimbus-onboarding-pending" ]; then
  echo "NIMBUS sin configurar — di 'configura NIMBUS' (o /nimbus-setup) para personalizarlo a tu gusto."
  echo ""
fi

# --- 3. Router (con guard) ---
if [ ! -f "$HOME/.claude/ROUTER.md" ]; then
  echo "AVISO NIMBUS: ~/.claude/ROUTER.md no encontrado — router no cargado. Revisar symlink / install.sh."
else
  cat "$HOME/.claude/ROUTER.md"
fi

# --- 4. Medición de este turno + recordatorio de la ley (ESTATUS al final) ---
echo ""
[ -n "$savestate" ] && echo "ESTADO DE GUARDADO (úsalo TAL CUAL en la línea '💾 guardado' del bloque ESTATUS): ${savestate}"
echo "MEDIDOR DE ESTE TURNO (estimación; úsalo TAL CUAL en la línea '📊 contexto' del bloque ESTATUS): ${gauge}"
echo ""
echo "RECORDATORIO DE LEY (NIMBUS): en CADA turno, CIERRA tu respuesta (SIEMPRE al final, nunca arriba)"
echo "con el bloque ESTATUS enmarcado — formato canónico en ROUTER.md §Candado: líneas con ícono"
echo "(🎚️ effort con medidor · 🧩 escalón(es)+conteo · 📊 contexto usando el MEDIDOR de arriba · y según"
echo "el caso ✅ se hizo / ▶️ sigue (roadmap) / ⏳ esperando si es fuera de roadmap). Carga SOLO ese(esos)"
echo "escalón(es) de ~/.claude/escalones/. NUNCA omitas el ESTATUS: trivial o ack => variante 'escalón 0'."
echo ""
echo "SEGURIDAD: si el medidor de arriba trae '→ /compact' o '→ /clear', PRIMERO commitea el trabajo SIN"
echo "pedir permiso (solo es guardar, autorizado por el Director) — recomendar limpiar contexto implica que TODO está guardado."

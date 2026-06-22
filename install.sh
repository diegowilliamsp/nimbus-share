#!/usr/bin/env bash
# NIMBUS — instalador portable, idempotente y no-destructivo.
# Instala el flujo de trabajo NIMBUS (carga por escalones + candado por hook) en ~/.claude/.
# Funciona en cualquier máquina/usuario: detecta paths dinámicamente, no hardcodea nada.
# Reglas: bash puro, backup antes de tocar ~/.claude/, nunca pisa tu CLAUDE.md global.
set -euo pipefail

# --- Colores ---
B=$'\033[34m'; G=$'\033[32m'; Y=$'\033[33m'; N=$'\033[0m'
say() { printf '%s→%s %s\n' "$B" "$N" "$1"; }
ok()  { printf '%s✓%s %s\n' "$G" "$N" "$1"; }
warn(){ printf '%s!%s %s\n' "$Y" "$N" "$1"; }

# --- 1. Detección dinámica de paths (cero rutas absolutas hardcodeadas) ---
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"   # override para sandbox de tests: CLAUDE_DIR=/tmp/x bash install.sh
MODE="copy"
[ "${1:-}" = "--dev" ] || [ "${1:-}" = "--symlink" ] && MODE="symlink"

say "Instalando NIMBUS"
say "  repo:   $REPO_DIR"
say "  destino: $CLAUDE_DIR  (modo: $MODE)"
mkdir -p "$CLAUDE_DIR"

# --- 2. Backup automático (red de seguridad) ---
if [ -e "$CLAUDE_DIR" ] && [ -n "$(ls -A "$CLAUDE_DIR" 2>/dev/null || true)" ]; then
  BACKUP="$CLAUDE_DIR.backup-$(date +%Y%m%d-%H%M%S)"
  cp -R "$CLAUDE_DIR" "$BACKUP"
  ok "Backup: $BACKUP  (restaurar: rm -rf \"$CLAUDE_DIR\" && mv \"$BACKUP\" \"$CLAUDE_DIR\")"
fi

# --- 3. Identidad: una sola pregunta para el token de nombre (el grill completo lo corre Claude) ---
USER_NAME="${NIMBUS_USER_NAME:-}"
if [ -z "$USER_NAME" ] && [ -t 0 ]; then
  printf '¿Cómo te llamas (para que NIMBUS te hable por tu nombre)? [el Director]: '
  read -r USER_NAME || true
fi
USER_NAME="${USER_NAME:-el Director}"
PERSONA_DIR="$CLAUDE_DIR/persona"

# Helper: copia un archivo sustituyendo tokens, o symlinkea (modo dev, sin sustituir)
place() { # place <src> <dst>
  local src="$1" dst="$2"
  mkdir -p "$(dirname -- "$dst")"
  if [ "$MODE" = "symlink" ]; then
    ln -sfn "$src" "$dst"
  else
    sed -e "s/{{USER_NAME}}/$USER_NAME/g" \
        -e "s#{{REPO_DIR}}#$REPO_DIR#g" \
        -e "s#{{PERSONA_DIR}}#$PERSONA_DIR#g" \
        "$src" > "$dst"
  fi
}

# --- 4. Instalar el motor (overview + router + escalones + skills) ---
say "Instalando el flujo (overview + router + escalones)..."
place "$REPO_DIR/flow/FLUJO_PROYECTOS.md" "$CLAUDE_DIR/FLUJO_PROYECTOS.md"
place "$REPO_DIR/flow/ROUTER.md" "$CLAUDE_DIR/ROUTER.md"
mkdir -p "$CLAUDE_DIR/escalones"
for f in "$REPO_DIR"/flow/escalones/*.md; do place "$f" "$CLAUDE_DIR/escalones/$(basename "$f")"; done
N_ESC=$(ls -1 "$CLAUDE_DIR"/escalones/*.md | wc -l | tr -d ' ')
ok "Flujo: FLUJO_PROYECTOS.md + ROUTER.md + $N_ESC escalones"

say "Instalando skills curadas (sin pisar las existentes)..."
mkdir -p "$CLAUDE_DIR/skills"
for d in "$REPO_DIR"/skills/*/; do
  name=$(basename "$d")
  if [ -d "$CLAUDE_DIR/skills/$name" ]; then warn "skill $name ya existe, no se pisa"; else cp -R "$d" "$CLAUDE_DIR/skills/"; fi
done
ok "Skills listas"

# --- 5. Capa persona (datos del usuario, desde templates vacíos) ---
say "Creando tu capa persona (vacía, tuya)..."
mkdir -p "$PERSONA_DIR"
for t in "$REPO_DIR"/templates/persona/*.tmpl; do
  [ -e "$t" ] || continue
  out="$PERSONA_DIR/$(basename "${t%.tmpl}")"
  if [ -e "$out" ]; then warn "$(basename "$out") ya existe, no se pisa"; else place "$t" "$out"; fi
done
ok "Capa persona en $PERSONA_DIR"

# --- 6. Piso: anexar el bloque claude-flow-proyectos al CLAUDE.md global (NUNCA pisar) ---
GLOBAL="$CLAUDE_DIR/CLAUDE.md"
say "Anexando el bloque NIMBUS al CLAUDE.md global..."
touch "$GLOBAL"
if grep -q 'BEGIN claude-flow-proyectos' "$GLOBAL" 2>/dev/null; then
  warn "El bloque claude-flow-proyectos ya está en tu CLAUDE.md global, no se duplica"
else
  { echo ""; place "$REPO_DIR/flow/CLAUDE.md.snippet" /dev/stdout; } >> "$GLOBAL"
  ok "Bloque NIMBUS anexado (no se tocó el resto de tu CLAUDE.md)"
fi

# --- 7. Hook del candado (portable, con $HOME, no rutas absolutas) ---
say "Instalando el hook del candado..."
mkdir -p "$CLAUDE_DIR/hooks"
cat > "$CLAUDE_DIR/hooks/nimbus-router.sh" <<'HOOK'
#!/usr/bin/env bash
# Hook UserPromptSubmit de NIMBUS: entrega el router + el mandato del candado en cada turno.
if [ -f "$HOME/.claude/.nimbus-onboarding-pending" ]; then
  echo "NIMBUS sin configurar — di 'configura NIMBUS' (o /nimbus-setup) para personalizarlo a tu gusto."
fi
if [ ! -f "$HOME/.claude/ROUTER.md" ]; then
  echo "AVISO NIMBUS: ~/.claude/ROUTER.md no encontrado — revisar install.sh."
else
  cat "$HOME/.claude/ROUTER.md"
fi
echo ""
echo "RECORDATORIO DE LEY (NIMBUS): si esto es trabajo de proyecto, antes de responder declara"
echo "el candado como BADGE ENMARCADO (marco + effort <tier> con medidor + escalón(es); formato"
echo "en ROUTER.md §Candado) y carga SOLO ese(esos) escalón(es) de ~/.claude/escalones/."
echo "Si es trivial o ack: badge 'escalón 0 — nada que cargar'."
HOOK
chmod +x "$CLAUDE_DIR/hooks/nimbus-router.sh"
ok "Hook script: $CLAUDE_DIR/hooks/nimbus-router.sh"

# --- 8. Registrar el hook en settings.json (jq atómico si está; si no, instrucción manual) ---
SETTINGS="$CLAUDE_DIR/settings.json"
HOOK_CMD='bash "$HOME/.claude/hooks/nimbus-router.sh"'
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
if grep -q 'nimbus-router.sh' "$SETTINGS" 2>/dev/null; then
  warn "El hook ya está registrado en settings.json"
elif command -v jq >/dev/null 2>&1; then
  cp "$SETTINGS" "$SETTINGS.backup-$(date +%Y%m%d-%H%M%S)"
  TMP="$(mktemp)"
  if jq --arg cmd "$HOOK_CMD" \
     '.hooks.UserPromptSubmit = ((.hooks.UserPromptSubmit // []) + [{"hooks":[{"type":"command","command":$cmd}]}])' \
     "$SETTINGS" > "$TMP" 2>/dev/null && jq -e . "$TMP" >/dev/null 2>&1; then
    mv "$TMP" "$SETTINGS"
    ok "Hook registrado en settings.json (jq atómico)"
  else
    rm -f "$TMP"; warn "No se pudo mergear con jq; registra el hook a mano (ver abajo)"
  fi
else
  warn "jq no está instalado — registra el hook a mano en $SETTINGS:"
  printf '%s\n' '  "hooks": { "UserPromptSubmit": [ { "hooks": [ { "type": "command", "command": "bash \"$HOME/.claude/hooks/nimbus-router.sh\"" } ] } ] }'
  printf '%s\n' '  (o pídele a Claude Code: "registra el hook de NIMBUS en mi settings.json")'
fi

# --- 9. Marcador de onboarding (idempotente: solo si no se completó antes) ---
if [ ! -f "$CLAUDE_DIR/.nimbus-onboarding-done" ]; then
  touch "$CLAUDE_DIR/.nimbus-onboarding-pending"
fi

# --- 10. Chequeo de salud ---
echo ""
if [ -x "$REPO_DIR/nimbus-doctor.sh" ]; then CLAUDE_DIR="$CLAUDE_DIR" bash "$REPO_DIR/nimbus-doctor.sh" || true; fi
echo ""
ok "NIMBUS instalado."
echo "   Abre Claude Code y di 'configura NIMBUS' para personalizarlo a tu gusto (grill de onboarding)."
echo "   Para quitarlo: bash \"$REPO_DIR/uninstall.sh\""

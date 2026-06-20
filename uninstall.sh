#!/usr/bin/env bash
# NIMBUS — desinstalador simétrico. Quita TODO lo que install.sh puso, sin dejar un hook roto.
# NO borra tu capa persona (tus ideas/retros/criterios) — eso es tuyo.
set -euo pipefail
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
B=$'\033[34m'; G=$'\033[32m'; Y=$'\033[33m'; N=$'\033[0m'

echo "Esto quitará NIMBUS de $CLAUDE_DIR (flujo, router, escalones, hook, bloque del CLAUDE.md)."
echo "Tu capa persona ($CLAUDE_DIR/persona) NO se borra."
printf 'Para confirmar, escribe la palabra DESINSTALAR: '
read -r ans || true
[ "$ans" = "DESINSTALAR" ] || { echo "Abortado."; exit 0; }

BACKUP="$CLAUDE_DIR.backup-$(date +%Y%m%d-%H%M%S)"
cp -R "$CLAUDE_DIR" "$BACKUP"
printf '%s✓%s Backup: %s\n' "$G" "$N" "$BACKUP"

rm -f "$CLAUDE_DIR/FLUJO_PROYECTOS.md" "$CLAUDE_DIR/ROUTER.md" "$CLAUDE_DIR/hooks/nimbus-router.sh"
rm -rf "$CLAUDE_DIR/escalones"
rm -f "$CLAUDE_DIR/.nimbus-onboarding-pending" "$CLAUDE_DIR/.nimbus-onboarding-done"
printf '%s✓%s Flujo, router, escalones y hook script eliminados\n' "$G" "$N"

# Quitar el bloque claude-flow-proyectos del CLAUDE.md global (entre marcadores)
GLOBAL="$CLAUDE_DIR/CLAUDE.md"
if [ -f "$GLOBAL" ] && grep -q 'BEGIN claude-flow-proyectos' "$GLOBAL"; then
  TMP="$(mktemp)"
  awk 'BEGIN{s=0} /# --- BEGIN claude-flow-proyectos/{s=1} /# --- END claude-flow-proyectos/{s=0;next} s==0{print}' "$GLOBAL" > "$TMP" && mv "$TMP" "$GLOBAL"
  printf '%s✓%s Bloque NIMBUS quitado de tu CLAUDE.md global (lo demás intacto)\n' "$G" "$N"
fi

# Quitar la entrada del hook de settings.json (jq si está; si no, avisar)
SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS" ] && grep -q 'nimbus-router.sh' "$SETTINGS"; then
  if command -v jq >/dev/null 2>&1; then
    TMP="$(mktemp)"
    if jq '(.hooks.UserPromptSubmit) |= map(select(.hooks | map(.command) | any(contains("nimbus-router.sh")) | not))
           | if ((.hooks.UserPromptSubmit // []) | length)==0 then del(.hooks.UserPromptSubmit) else . end
           | if ((.hooks // {}) | length)==0 then del(.hooks) else . end' \
       "$SETTINGS" > "$TMP" 2>/dev/null && jq -e . "$TMP" >/dev/null 2>&1; then
      mv "$TMP" "$SETTINGS"; printf '%s✓%s Hook quitado de settings.json\n' "$G" "$N"
    else rm -f "$TMP"; printf '%s!%s Quita a mano la entrada nimbus-router.sh de %s\n' "$Y" "$N" "$SETTINGS"; fi
  else
    printf '%s!%s jq no está; quita a mano la entrada nimbus-router.sh de %s\n' "$Y" "$N" "$SETTINGS"
  fi
fi
echo ""
printf '%s✓%s NIMBUS desinstalado. Tu capa persona sigue en %s/persona\n' "$G" "$N" "$CLAUDE_DIR"

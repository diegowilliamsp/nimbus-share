#!/usr/bin/env bash
# NIMBUS doctor — chequeo de salud de la instalación (read-only). Exit 0 sano / 1 con fallas.
set -uo pipefail
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
G=$'\033[32m'; R=$'\033[31m'; N=$'\033[0m'
fail=0
chk() { if eval "$2"; then printf '%s✓%s %s\n' "$G" "$N" "$1"; else printf '%s✗%s %s\n' "$R" "$N" "$1"; fail=1; fi; }

echo "NIMBUS doctor — destino: $CLAUDE_DIR"
chk "FLUJO_PROYECTOS.md presente"           "[ -f '$CLAUDE_DIR/FLUJO_PROYECTOS.md' ]"
chk "ROUTER.md presente"                    "[ -f '$CLAUDE_DIR/ROUTER.md' ]"
want=$(ls -1 "$REPO_DIR"/flow/escalones/*.md 2>/dev/null | wc -l | tr -d ' ')
have=$(ls -1 "$CLAUDE_DIR"/escalones/*.md 2>/dev/null | wc -l | tr -d ' ')
chk "escalones instalados ($have/$want)"    "[ '$have' = '$want' ] && [ '$want' != '0' ]"
chk "hook script ejecutable"                "[ -x '$CLAUDE_DIR/hooks/nimbus-router.sh' ]"
chk "hook registrado en settings.json"      "grep -q nimbus-router.sh '$CLAUDE_DIR/settings.json' 2>/dev/null"
chk "bloque NIMBUS en CLAUDE.md global"      "grep -q 'BEGIN claude-flow-proyectos' '$CLAUDE_DIR/CLAUDE.md' 2>/dev/null"
chk "sin {{tokens}} sin sustituir"          "! grep -rq '{{' '$CLAUDE_DIR/escalones' '$CLAUDE_DIR/ROUTER.md' 2>/dev/null"

echo ""
if [ "$fail" = "0" ]; then echo "${G}NIMBUS sano.${N}"; else echo "${R}NIMBUS con fallas — revisa lo marcado ✗ (re-corre install.sh).${N}"; fi
exit $fail

#!/usr/bin/env bash
set -euo pipefail
SECONDS=0

SCRIPT_COLOR='\033[1;35m'
ERROR_COLOR='\033[1;31m'
RESET_COLOR='\033[0m'

fail() {
  echo -e "${ERROR_COLOR}Error: $1${RESET_COLOR}"
  exit 1
}

echo -e "${SCRIPT_COLOR}Dotfiles installer starting…${RESET_COLOR}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "$HOME/.bashrc" ]; then
  cp "$HOME/.bashrc" "$HOME/.bashrc.bak.$(date +%s)"
fi

cp "$SCRIPT_DIR/.bashrc"              "$HOME/.bashrc"
cp "$SCRIPT_DIR/.venv.sh"             "$HOME/.venv.sh"
# cp "$SCRIPT_DIR/.checkrust.sh"        "$HOME/.checkrust.sh"

chmod +x "$HOME/.venv.sh"
# chmod +x "$HOME/.checkrust.sh"

# "$HOME/.checkrust.sh"

echo -e "${SCRIPT_COLOR}Dotfiles installed in ${SECONDS} seconds — reloading shell…${RESET_COLOR}"
exec "$SHELL"

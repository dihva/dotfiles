#!/usr/bin/env bash
set -euo pipefail
SECONDS=0

SCRIPT_COLOR='\033[1;35m'
PIP_COLOR='\033[1;34m'
ERROR_COLOR='\033[1;31m'
RESET_COLOR='\033[0m'

fail() {
  echo -e "${ERROR_COLOR}Error: $1${RESET_COLOR}"
  if [ -d ".venv" ]; then
    rm -rf .venv
  fi
  exit 1
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || fail "Unable to change directory to ${SCRIPT_DIR}."

if [[ -f "requirements.txt" ]]; then
  REQ_FILE="requirements.txt"
elif [[ -f "reqs.txt" ]]; then
  REQ_FILE="reqs.txt"
else
  echo -e "${ERROR_COLOR}No requirements.txt or reqs.txt found — skipping dependency install.${RESET_COLOR}"
  REQ_FILE=""
fi

if ! command -v python3 &>/dev/null; then
  echo -e "${ERROR_COLOR}python3 not found. Trying to install…${RESET_COLOR}"
  if   command -v apt-get &>/dev/null; then
       sudo apt-get update && sudo apt-get install -y python3 python3-venv
  else
       fail "Couldn’t auto-install python (no supported package manager)."
  fi
  command -v python3 &>/dev/null || fail "Auto-install failed — please install python3 manually."
fi

if [ -d ".venv" ]; then
  echo -e "${SCRIPT_COLOR}The .venv directory already exists.${RESET_COLOR}"
  read -p "Do you want to replace it? (y/n): " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "${SCRIPT_COLOR}Removing existing .venv directory...${RESET_COLOR}"
    rm -rf .venv || fail "Failed to remove existing .venv directory."
  else
    echo -e "${ERROR_COLOR}Operation aborted by user.${RESET_COLOR}"
    exit 0
  fi
fi

echo -e "${SCRIPT_COLOR}Creating virtual environment in .venv...${RESET_COLOR}"
python3 -m venv .venv || fail "Failed to create virtual environment."

echo -e "${SCRIPT_COLOR}Upgrading pip...${RESET_COLOR}"
if ! .venv/bin/pip install --upgrade pip \
        > >(sed "s/^/${PIP_COLOR}/; s/\$/${RESET_COLOR}/") \
        2> >(sed "s/^/${ERROR_COLOR}/; s/\$/${RESET_COLOR}/"); then
  fail "Failed to upgrade pip."
fi

if [[ -n "$REQ_FILE" ]]; then
  echo -e "${SCRIPT_COLOR}Installing dependencies from ${REQ_FILE}...${RESET_COLOR}"
  if ! .venv/bin/pip install -r "${REQ_FILE}" \
          > >(sed "s/^/${PIP_COLOR}/; s/\$/${RESET_COLOR}/") \
          2> >(sed "s/^/${ERROR_COLOR}/; s/\$/${RESET_COLOR}/"); then
    fail "Failed to install dependencies."
  fi
else
  echo -e "${SCRIPT_COLOR}No dependencies to install.${RESET_COLOR}"
fi

echo -e "${SCRIPT_COLOR}Setup complete in ${SECONDS} seconds. Activating venv...${RESET_COLOR}"
source .venv/bin/activate
echo -e "${SCRIPT_COLOR}Venv activated. Launching a fresh shell…${RESET_COLOR}"
exec "$SHELL"

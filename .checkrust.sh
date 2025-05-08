#!/usr/bin/env bash
set -euo pipefail
SECONDS=0

SCRIPT_COLOR='\033[1;35m'
ERROR_COLOR='\033[1;31m'
RESET_COLOR='\033[0m'

fail() { echo -e "${ERROR_COLOR}Error: $1${RESET_COLOR}"; exit 1; }

TARGET_DIR="${1:-$PWD}"

echo -e "${SCRIPT_COLOR}Scanning ${TARGET_DIR} for Rust source files…${RESET_COLOR}"

if find "$TARGET_DIR" -type f -name '*.rs' | grep -q .; then
  echo -e "${SCRIPT_COLOR}Rust code detected.${RESET_COLOR}"
  
  if ! command -v rustup &>/dev/null; then
    echo -e "${SCRIPT_COLOR}Installing Rust toolchain…${RESET_COLOR}"

    if ! command -v curl &>/dev/null; then
      sudo apt-get update -y
      sudo apt-get install -y curl build-essential
    fi

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
  else
    echo -e "${SCRIPT_COLOR}Rust already installed — skipping.${RESET_COLOR}"
  fi
else
  echo -e "${SCRIPT_COLOR}No *.rs files found. Skipping Rust install.${RESET_COLOR}"
fi

echo -e "${SCRIPT_COLOR}Done in ${SECONDS}s.${RESET_COLOR}"

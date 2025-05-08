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

echo -e "${SCRIPT_COLOR}Scanning for Rust source files…${RESET_COLOR}"
if ! find . -type f -name '*.rs' -print -quit | grep -q .; then
  echo -e "${SCRIPT_COLOR}No .rs files found — nothing to do.${RESET_COLOR}"
  exit 0
fi

echo -e "${SCRIPT_COLOR}.rs files detected. Verifying toolchain…${RESET_COLOR}"
if command -v cargo &>/dev/null && command -v rustc &>/dev/null; then
  echo -e "${SCRIPT_COLOR}Rust toolchain already present. All set.${RESET_COLOR}"
  exit 0
fi

echo -e "${SCRIPT_COLOR}Installing Rust (rustup + cargo)…${RESET_COLOR}"
if command -v apt-get &>/dev/null; then
  sudo apt-get update
  sudo apt-get install -y curl build-essential
else
  fail "Supported package manager (apt-get) not found."
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --no-modify-path || fail "rustup installation failed."

source "$HOME/.cargo/env" || true

command -v cargo &>/dev/null || fail "cargo still missing after install."

echo -e "${SCRIPT_COLOR}Rust toolchain installed in ${SECONDS} seconds.${RESET_COLOR}"

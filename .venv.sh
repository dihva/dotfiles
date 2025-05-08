#!/bin/bash
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
  fail "No requirements.txt or reqs.txt file found in ${SCRIPT_DIR}"
fi

if ! command -v python3 &> /dev/null; then
  fail "python3 is not installed. Please install Python3."
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
if ! .venv/bin/pip install --upgrade pip > >(sed "s/^/${PIP_COLOR}/; s/\$/${RESET_COLOR}/") \
                                2> >(sed "s/^/${ERROR_COLOR}/; s/\$/${RESET_COLOR}/"); then
  fail "Failed to upgrade pip."
fi

echo -e "${SCRIPT_COLOR}Installing dependencies from ${REQ_FILE}...${RESET_COLOR}"
if ! .venv/bin/pip install -r "${REQ_FILE}" > >(sed "s/^/${PIP_COLOR}/; s/\$/${RESET_COLOR}/") \
                                          2> >(sed "s/^/${ERROR_COLOR}/; s/\$/${RESET_COLOR}/"); then
  fail "Failed to install dependencies."
fi

echo -e "${SCRIPT_COLOR}Setup complete. All dependencies have been installed.${RESET_COLOR}"
echo -e "${SCRIPT_COLOR}Process completed in ${SECONDS} seconds.${RESET_COLOR}"

echo -e "${SCRIPT_COLOR}Activating virtual environment...${RESET_COLOR}"
source .venv/bin/activate
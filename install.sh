#!/bin/bash
echo "Setting up codespaces..."

# Bash setup
cp "$PWD/.bashrc" "$HOME/.bashrc"
cp "$PWD/.venv.sh" "$HOME/.venv.sh"
chmod +x "$HOME/.venv.sh"

echo "Setup done run: source ~/.bashrc"

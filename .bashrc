py() {
  python3 "$@"
}

pif() {
  pip freeze > "$@"
}

rs() {
  cargo run "$@"
}

mvenv() {
  bash ~/.venv.sh
}

twee() {
  bash ~/.twee.sh
}

export PS1="\[\e[38;5;218m\]fweakette\[\e[38;5;153m\]@\h\[\e[0m\]:\[\e[38;5;117m\] \w\[\e[0m\]\$ "

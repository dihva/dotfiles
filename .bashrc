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

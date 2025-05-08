py() {
  python3 "$@"
}

rs() {
  cargo run "$@"
}

mvenv() {
  bash ~/.venv.sh
}
py() {
  python3 "$@"
}

pif() {
  pip freeze > "$@"
}

rs() {
  cargo run "$@"
}

rsb() {
  cargo build --release --target-dir .target "$@"
}

mvenv() {
  bash ~/.venv.sh
}

twee() {
  ~/.neotwee "$@"
  #you can use -f btw
}

cls() {
  clear
  #im lwk schitzo
}

speedtest() {
  speedtest-cli "$@"
  #you can use --simple and --json btw
}

is() {
  [[ $# -lt 1 ]] && { echo "usage: is <path> [...]" >&2; return 1; }

  local status=0
  for path in "$@"; do
    if [[ -e $path ]]; then
      echo "$path true"
    else
      echo "$path false"
      status=1
    fi
  done

  return $status
}

#idk if i really want this rn lmao
#root dir on launch
#if [[ $- == *i* ]]; then
#  cd /
#fi

export PS1="\[\e[38;5;218m\]\u\[\e[38;5;153m\]@\h\[\e[0m\]:\[\e[38;5;117m\] \w\[\e[0m\]\$ "

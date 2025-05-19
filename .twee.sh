#!/usr/bin/env bash

set -o errtrace
trap 'echo "Error on line $LINENO. Command: $BASH_COMMAND"' ERR

if ! command -v tree >/dev/null 2>&1; then
    echo "Error: 'tree' command not found."
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: 'jq' command not found."
    exit 1
fi

TREE_VERSION=$(tree --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if (( $(echo "$TREE_VERSION < 2.0" | bc -l 2>/dev/null) )); then
    echo "Error: tree version $TREE_VERSION is too old. Required ≥2.0.0 for JSON support."
    exit 1
fi

set -euo pipefail

TARGET="${1:-.}"

if [ ! -d "$TARGET" ] && [ ! -f "$TARGET" ]; then
    echo "Error: Target '$TARGET' is not a valid file or directory."
    exit 1
fi

ROOT_NAME="$(basename "$(realpath "$TARGET")")"

TREE_JSON="$(tree -a -J "$TARGET")" || { echo "Error: tree command failed"; exit 1; }

readarray -t ROWS < <(
  jq -r '
    def walk(d):
      "\(d)\t\(.type)\t\(.name)" ,
      ( if .type=="directory"
           and ( .name | startswith(".") )
           and d>0
        then empty
        else (.contents? // [])[] | walk(d+1)
        end );
    .[] | walk(0)
  ' <<<"$TREE_JSON"
) || { echo "Error: jq command failed to parse tree output"; exit 1; }

if [ ${#ROWS[@]} -eq 0 ]; then
  echo "WARNING: No rows parsed from JSON output."
  echo "ERROR: Cannot continue with empty tree data"
  exit 1
fi

LINES=${#ROWS[@]}
declare -a DEPTH TYPE NAME
for ((i=0;i<LINES;i++)); do
  IFS=$'\t' read -r DEPTH[$i] TYPE[$i] NAME[$i] <<<"${ROWS[$i]}"
done

dir_count=0
file_count=0

if [ $LINES -eq 0 ]; then
  echo "No files or directories found."
  exit 0
fi

for ((i=0;i<LINES;i++)); do
  if [[ ${TYPE[$i]:-empty} == "directory" ]]; then
    let dir_count=dir_count+1
  else
    let file_count=file_count+1
  fi
done

print_line () {
  local idx=$1 depth=$2 is_last=$3 name=$4 is_dir=$5
  local prefix=""

  for ((lvl=0; lvl<depth-1; lvl++)); do
    local have_sib=0
    for ((j=idx+1; j<LINES; j++)); do
      (( DEPTH[j] < lvl )) && break
      if (( DEPTH[j] == lvl )); then have_sib=1; break; fi
    done
    (( have_sib )) && prefix+="│   " || prefix+="    "
  done

  (( depth > 0 )) && { [[ $is_last -eq 1 ]] && prefix+="└── " || prefix+="├── "; }

  if (( depth == 0 )); then
    echo "${prefix}${ROOT_NAME}/"
  else
    (( is_dir )) && name+="/"
    echo "${prefix}${name}"
  fi
}

root_printed=false

for ((i=0; i<LINES; i++)); do
  if (( DEPTH[i] == 0 )) && $root_printed; then
    continue
  fi
  
  if (( DEPTH[i] == 0 )); then
    root_printed=true
  fi

  last=1
  for ((j=i+1; j<LINES; j++)); do
    (( DEPTH[j] < DEPTH[i] )) && break
    if (( DEPTH[j] == DEPTH[i] )); then last=0; break; fi
  done

  is_dir=0
  [[ ${TYPE[$i]} == "directory" ]] && is_dir=1
  print_line "$i" "${DEPTH[$i]}" "$last" "${NAME[$i]}" "$is_dir"
done

echo
printf "%d directories, %d files\n" "$dir_count" "$file_count"

#!/usr/bin/env bash
# tree.sh
#
# Usage:
#   ./tree.sh [OPTIONS] [DIR]
#
# Description:
#   Recursively lists the contents of DIR (default: current directory) in a
#   tree-like format. Supports ASCII or Unicode branch characters, showing
#   hidden files, and limiting display depth.
#
# Options:
#   --ascii         Use ASCII branches ("|--", "\--") instead of Unicode ("├──", "└──")
#   -a              Show hidden files and directories (dotfiles)
#   -L <depth>      Limit the display depth (1 = root only, 2 = root + immediate children, ...)
#   --              End of options; treat all following arguments as paths
#
# Examples:
#   ./tree.sh                         # Unicode tree of current directory
#   ./tree.sh --ascii -a -L 2 src/    # ASCII tree of src/ up to depth 2

set -euo pipefail

# --- defaults ---
BRANCH_MID="├── "
BRANCH_LAST="└── "
VERT="│   "
SPACE="    "
show_all=false
max_depth=999999

# --- parse options ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ascii)
      BRANCH_MID="|-- "
      BRANCH_LAST="\\-- "
      VERT="|   "
      SPACE="    "
      shift
      ;;
    -a)
      show_all=true
      shift
      ;;
    -L)
      [[ $# -ge 2 ]] || { echo "Option -L requires an argument" >&2; exit 1; }
      max_depth="$2"; shift 2
      if ! [[ "$max_depth" =~ ^[0-9]+$ ]] || (( max_depth < 1 )); then
        echo "Invalid depth for -L (must be >= 1): $max_depth" >&2
        exit 1
      fi
      ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) break ;;
  esac
done

dir="${1:-.}"

enable_glob_safely() {
  had_noglob=0
  if [[ -o noglob ]]; then
    had_noglob=1
    set +f
  fi
  shopt -s nullglob
  if $show_all; then
    shopt -s dotglob
  else
    shopt -u dotglob
  fi
}
restore_glob_state() {
  if (( had_noglob )); then
    set -f
  fi
}

list_dir() {
  local d="$1" prefix="$2" depth="$3"
  (( depth <= max_depth )) || return 0

  enable_glob_safely
  local entries=( "$d"/* )
  restore_glob_state

  local n=${#entries[@]}
  (( n == 0 )) && return 0

  local sorted=()
  while IFS= read -r -d '' e; do
    sorted+=( "$e" )
  done < <(
    for e in "${entries[@]}"; do printf '%s\0' "$e"; done | LC_ALL=C sort -z
  )

  local count=${#sorted[@]}
  local i path name last
  for i in "${!sorted[@]}"; do
    path="${sorted[i]}"
    name="${path##*/}"
    last=$(( i == count-1 ? 1 : 0 ))

    if (( last )); then
      printf '%s%s%s\n' "$prefix" "$BRANCH_LAST" "$name"
    else
      printf '%s%s%s\n' "$prefix" "$BRANCH_MID" "$name"
    fi

    if [[ -d "$path" ]] && (( depth < max_depth )); then
      if (( last )); then
        list_dir "$path" "${prefix}${SPACE}" $((depth+1))
      else
        list_dir "$path" "${prefix}${VERT}"  $((depth+1))
      fi
    fi
  done
}

# --- main ---
printf '%s\n' "$dir"
[[ -d "$dir" ]] || exit 0

if (( max_depth >= 2 )); then
  list_dir "$dir" "" 1
fi

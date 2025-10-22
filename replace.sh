#!/usr/bin/env bash
# replace.sh
#
# Usage:
#   ./replace.sh [--undo] <changes.csv>
#
# Description:
#   Performs literal, in-place, line-preserving replacements based on a CSV list.
#   Each CSV row after the header must be: file,old,new
#   Normal mode replaces  old -> new.  --undo replaces  new -> old.
#
# Notes:
#   * No newlines are ever inserted by this script; it does not reflow lines.
#   * CSV values must not contain literal newlines.
#   * Uses only standard tools (bash, sed, awk, tail).

set -euo pipefail

mode="normal"
csv=""

# --- parse args ---
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [--undo] <changes.csv>" >&2
  exit 1
fi
if [[ "$1" == "--undo" ]]; then
  mode="undo"
  csv="${2:-}"
else
  csv="$1"
fi
if [[ -z "$csv" || ! -f "$csv" ]]; then
  echo "Error: CSV file not found: $csv" >&2
  exit 1
fi

# --- process CSV (no line merging; no formatting) ---
tail -n +2 "$csv" | while IFS=, read -r file old new; do
  file=$(echo "$file" | awk '{$1=$1;print}')
  old=$(echo "$old"  | awk '{$1=$1;print}')
  new=$(echo "$new"  | awk '{$1=$1;print}')
  [[ -f "$file" ]] || { echo "Warning: file not found: $file"; continue; }
  if [[ "$mode" == "undo" ]]; then
    sed -i "s|$new|$old|g" "$fi

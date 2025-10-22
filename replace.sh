#!/usr/bin/env bash
# replace.sh
#
# Usage:
#   ./replace.sh [--undo] <changes.csv>
#
# Description:
#   Applies or reverts text replacements defined in a CSV file. Each line
#   (after the header) specifies a file path, an old string, and a new string.
#   The script performs global substitutions ("old" → "new") for all matches
#   in the given files.
#
#   With the --undo option, the operation is reversed ("new" → "old"),
#   effectively restoring files to their previous state.
#
# CSV format:
#   file,old,new
#   path/to/file.txt,Hello,Hi
#   path/to/file.md,dog,cat
#
# Examples:
#   ./replace.sh changes.csv          # replace "old" → "new"
#   ./replace.sh --undo changes.csv   # revert "new" → "old"
#
# Notes:
#   * Uses only standard Unix tools: bash, sed, awk, tail, read
#   * No external dependencies required
#   * Backslashes or special regex characters in CSV values should be escaped

set -euo pipefail

# --- defaults ---
mode="normal"
csv=""

# --- parse arguments ---
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

# --- display mode ---
if [[ "$mode" == "undo" ]]; then
  echo "🌀 Undo mode: reversing replacements (new → old)"
else
  echo "🔁 Normal mode: applying replacements (old → new)"
fi

# --- process CSV ---
tail -n +2 "$csv" | while IFS=, read -r file old new; do
  # Trim leading/trailing spaces
  file=$(echo "$file" | awk '{$1=$1;print}')
  old=$(echo "$old"  | awk '{$1=$1;print}')
  new=$(echo "$new"  | awk '{$1=$1;print}')

  if [[ -f "$file" ]]; then
    if [[ "$mode" == "undo" ]]; then
      sed -i "s|$new|$old|g" "$file"
      echo "Reverted in $file: '$new' → '$old'"
    else
      sed -i "s|$old|$new|g" "$file"
      echo "Replaced in $file: '$old' → '$new'"
    fi
  else
    echo "⚠️  Warning: file not found: $file"
  fi
done

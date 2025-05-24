#!/usr/bin/env bash
# dump.sh
#
# Usage:
#   ./dump.sh              > all.txt                # dump current directory
#   ./dump fileA dirB      > mix.txt                # dump arbitrary number of files and directories
#
# Output format:
#   ##### START relative/path #####
#   ...content...
#   #####  END  relative/path #####
#
# Automatically skips binary files that are not text/*.

set -euo pipefail

CALLER_PWD=$(pwd)
readonly CALLER_PWD

dump_file() {
    local abs="$1"

    # skip if not a text file
    if ! file --mime-type -b "$abs" | grep -q '^text/'; then
        return
    fi

    local rel
    rel=$(realpath --relative-to="$CALLER_PWD" "$abs")

    printf '##### START %s #####\n' "$rel"
    cat -- "$abs"
    printf '\n#####  END  %s #####\n\n' "$rel"
}

process_path() {
    local target="$1"

    if [[ -d "$target" ]]; then
        # recursively find all files in the directory
        find "$target" -type f -print0 |
        while IFS= read -r -d '' f; do
            dump_file "$f"
        done
    elif [[ -f "$target" ]]; then
        dump_file "$target"
    else
        echo "Path not found or unsupported: $target" >&2
        return 1
    fi
}

# if no arguments are given, default to current directory
if [[ $# -eq 0 ]]; then
    set -- .
fi

# process each path argument
for path in "$@"; do
    process_path "$path"
done

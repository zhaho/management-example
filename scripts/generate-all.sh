#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

SOURCE_DIR="${1:?Usage: generate-all.sh <source_dir> <format>}"
FMT="${2:?Usage: generate-all.sh <source_dir> <format>}"

files=("$SOURCE_DIR"/teams/*.yaml)
if [ ${#files[@]} -eq 0 ]; then
  echo "No team configs found in $SOURCE_DIR/teams/"
  exit 1
fi

for team_file in "${files[@]}"; do
  team_name=$(basename "$team_file" .yaml)
  echo ">>> Processing team: $team_name"
  task generate:team TEAM="$team_name" FORMAT="$FMT"
done

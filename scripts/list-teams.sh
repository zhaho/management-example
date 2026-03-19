#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

SOURCE_DIR="${1:?Usage: list-teams.sh <source_dir>}"

files=("$SOURCE_DIR"/teams/*.yaml)
if [ ${#files[@]} -eq 0 ]; then
  echo "No team configs found in $SOURCE_DIR/teams/"
  exit 0
fi

printf "%-20s %-30s %-12s\n" "TEAM" "NAMESPACE" "ENVIRONMENT"
printf "%-20s %-30s %-12s\n" "----" "---------" "-----------"
for team_file in "${files[@]}"; do
  team=$(basename "$team_file" .yaml)
  ns=$(yq '.namespace' "$team_file")
  env=$(yq '.environment' "$team_file")
  printf "%-20s %-30s %-12s\n" "$team" "$ns" "$env"
done

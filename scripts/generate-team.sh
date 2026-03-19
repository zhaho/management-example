#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:?Usage: generate-team.sh <source_dir> <deploy_dir> <team> <format>}"
DEPLOY_DIR="${2:?Usage: generate-team.sh <source_dir> <deploy_dir> <team> <format>}"
TEAM="${3:?Usage: generate-team.sh <source_dir> <deploy_dir> <team> <format>}"
FMT="${4:?Usage: generate-team.sh <source_dir> <deploy_dir> <team> <format>}"

team_file="$SOURCE_DIR/teams/$TEAM.yaml"

if [ ! -f "$team_file" ]; then
  echo "Error: Team configuration not found: $team_file"
  exit 1
fi

# Export values from the team config as environment variables
# so envsubst can substitute them into the base templates.
export NAMESPACE=$(yq '.namespace' "$team_file")
export TEAM_NAME=$(yq '.name' "$team_file")
export ENVIRONMENT=$(yq '.environment' "$team_file")
export TEAM_GROUP=$(yq '.group' "$team_file")
export CPU_REQUEST=$(yq '.resources.cpu_request' "$team_file")
export CPU_LIMIT=$(yq '.resources.cpu_limit' "$team_file")
export MEMORY_REQUEST=$(yq '.resources.memory_request' "$team_file")
export MEMORY_LIMIT=$(yq '.resources.memory_limit' "$team_file")
export MAX_PODS=$(yq '.resources.pods' "$team_file")

output_dir="$DEPLOY_DIR/$FMT/$TEAM"
mkdir -p "$output_dir"

for template in "$SOURCE_DIR"/base/*.yaml; do
  resource_name=$(basename "$template" .yaml)
  if [ "$FMT" = "json" ]; then
    envsubst < "$template" | yq -o json > "$output_dir/$resource_name.json"
  else
    envsubst < "$template" > "$output_dir/$resource_name.yaml"
  fi
  echo "  -> $output_dir/$resource_name.$FMT"
done

echo "Done: generated $FMT files for team '$TEAM'"

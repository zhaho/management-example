#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:?Usage: new-team.sh <source_dir> <team> <namespace> <environment>}"
TEAM="${2:?Usage: new-team.sh <source_dir> <team> <namespace> <environment>}"
NS="${3:?Usage: new-team.sh <source_dir> <team> <namespace> <environment>}"
ENV="${4:?Usage: new-team.sh <source_dir> <team> <namespace> <environment>}"

output_file="$SOURCE_DIR/teams/$TEAM.yaml"
if [ -f "$output_file" ]; then
  echo "Error: Team configuration already exists: $output_file"
  exit 1
fi

{
  echo "name: $TEAM"
  echo "namespace: $NS"
  echo "environment: $ENV"
  echo "group: $TEAM-admins"
  echo "resources:"
  echo "  cpu_request: \"500m\""
  echo "  cpu_limit: \"2\""
  echo "  memory_request: \"512Mi\""
  echo "  memory_limit: \"2Gi\""
  echo "  pods: \"20\""
} > "$output_file"

echo "Created: $output_file"
echo "Edit the file to adjust resource limits, then run:"
echo "  task generate:team TEAM=$TEAM"

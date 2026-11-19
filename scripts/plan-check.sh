#!/usr/bin/env bash
set -euo pipefail
plan_json=$(mktemp)
trap 'rm -f "$plan_json"' EXIT
terraform -chdir="$1" show -json "$2" > "$plan_json"
conftest test --parser json --policy policy "$plan_json"

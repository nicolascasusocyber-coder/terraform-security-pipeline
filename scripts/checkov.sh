#!/usr/bin/env bash
set -euo pipefail
checkov --directory "$1" --framework terraform --skip-download \
  --check CKV_AWS_24,CKV_AWS_53,CKV_AWS_54,CKV_AWS_55,CKV_AWS_56

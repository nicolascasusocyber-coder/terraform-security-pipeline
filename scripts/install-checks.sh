#!/usr/bin/env bash
set -euo pipefail
python -m pip install 'checkov==3.2.495'
archive=conftest_0.71.1_Linux_x86_64.tar.gz
curl -fsSL "https://github.com/open-policy-agent/conftest/releases/download/v0.71.1/$archive" -o "$RUNNER_TEMP/$archive"
(
  cd "$RUNNER_TEMP"
  curl -fsSL https://github.com/open-policy-agent/conftest/releases/download/v0.71.1/checksums.txt -o conftest-checksums.txt
  awk -v archive="$archive" '$2 == archive' conftest-checksums.txt | sha256sum -c -
  tar -xzf "$archive" conftest
)
echo "$RUNNER_TEMP" >> "$GITHUB_PATH"

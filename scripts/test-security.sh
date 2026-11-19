#!/usr/bin/env bash
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

expect_failure() {
  local marker=$1 result=0
  shift
  "$@" > "$work/rejection.log" 2>&1 || result=$?
  cat "$work/rejection.log"
  [[ $result -eq 1 ]] && grep -Fq "$marker" "$work/rejection.log"
}

export AWS_ACCESS_KEY_ID=offline-demo
export AWS_SECRET_ACCESS_KEY=offline-demo
export AWS_EC2_METADATA_DISABLED=true
unset AWS_SESSION_TOKEN AWS_PROFILE AWS_DEFAULT_PROFILE AWS_WEB_IDENTITY_TOKEN_FILE AWS_ROLE_ARN
export TF_VAR_offline_plan=true
export TF_VAR_bucket_name=terraform-security-pipeline-local-test

terraform fmt -check -recursive terraform
terraform -chdir=terraform init -backend=false -input=false
terraform -chdir=terraform validate
bash scripts/checkov.sh terraform
terraform -chdir=terraform plan -input=false -out="$work/secure.tfplan"
bash scripts/plan-check.sh terraform "$work/secure.tfplan"

mkdir "$work/negative"
cp terraform/*.tf "$work/negative/"
python3 - "$work/negative/main.tf" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
original = path.read_text()
updated = original.replace("[aws_vpc.demo.cidr_block]", '["0.0.0.0/0"]\n    ipv6_cidr_blocks = ["::/0"]')
start = updated.index('resource "aws_s3_bucket_server_side_encryption_configuration"')
end = updated.index('resource "aws_s3_bucket_public_access_block"', start)
path.write_text(updated[:start] + updated[end:] + """
resource "aws_ebs_volume" "test_only" {
  availability_zone = "eu-west-1a"
  size              = 1
  encrypted         = false
}
""")
PY
expect_failure CKV_AWS_24 bash scripts/checkov.sh "$work/negative"
terraform -chdir="$work/negative" init -backend=false -input=false
terraform -chdir="$work/negative" plan -input=false -out="$work/negative.tfplan"
expect_failure PUBLIC_SSH bash scripts/plan-check.sh "$work/negative" "$work/negative.tfplan"
grep -Fq '::/0' "$work/rejection.log"
grep -Fq S3_ENCRYPTION "$work/rejection.log"
grep -Fq EBS_ENCRYPTION "$work/rejection.log"
conftest verify --policy policy

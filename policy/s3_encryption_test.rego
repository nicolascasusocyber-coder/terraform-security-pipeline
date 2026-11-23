package main

import rego.v1

test_encryption_must_match_bucket if {
    findings := deny with input as {"resource_changes": [
        {"mode": "managed", "type": "aws_s3_bucket", "address": "aws_s3_bucket.demo",
         "change": {"after": {"bucket": "demo"}}},
        {"mode": "managed", "type": "aws_s3_bucket_server_side_encryption_configuration",
         "change": {"after": {"bucket": "other", "rule": [
            {"apply_server_side_encryption_by_default": [{"sse_algorithm": "AES256"}]},
         ]}}},
    ]}
    count(findings) == 1
    some finding in findings
    startswith(finding, "S3_ENCRYPTION")
}

test_reject_non_plan_input if {
    findings := deny with input as {}
    "PLAN_FORMAT expected Terraform plan JSON with resource_changes" in findings
}

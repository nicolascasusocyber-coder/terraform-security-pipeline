package main

import rego.v1

deny contains msg if {
    resource := input.resource.aws_s3_bucket[_]
    not input.resource.aws_s3_bucket_server_side_encryption_configuration
    msg := "GOVERNANCE VIOLATION (ISO 27001 A.8.24): S3 bucket must have server-side encryption enabled."
}

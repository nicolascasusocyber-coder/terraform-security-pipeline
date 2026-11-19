package main

import rego.v1

deny contains msg if {
    bucket := planned_resource[_]
    bucket.type == "aws_s3_bucket"
    not has_encryption(object.get(bucket.change.after, "bucket", null))
    msg := sprintf("S3_ENCRYPTION %s requires explicit encryption (ISO 27001 A.8.24 mapping)", [bucket.address])
}

has_encryption(bucket_name) if {
    is_string(bucket_name)
    config := planned_resource[_]
    config.type == "aws_s3_bucket_server_side_encryption_configuration"
    config.change.after.bucket == bucket_name
    some rule in config.change.after.rule
    some defaults in rule.apply_server_side_encryption_by_default
    defaults.sse_algorithm in {"AES256", "aws:kms", "aws:kms:dsse"}
}

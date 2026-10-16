package main

# ISO 27001 A.8.24: Check S3 server-side encryption configuration resource
deny[msg] {
    some i
    input.resource.aws_s3_bucket_server_side_encryption_configuration[i]
    not input.resource.aws_s3_bucket_server_side_encryption_configuration[i].rule
    msg := sprintf("GOVERNANCE VIOLATION (ISO 27001 A.8.24): S3 bucket encryption configuration '%v' lacks required rules.", [i])
}

package main

import future.keywords.in

# Rule 1: Deny creation of S3 buckets without server-side encryption
deny[msg] {
    some resource in input.resource_changes
    resource.type == "aws_s3_bucket"

    not has_server_side_encryption(resource)

    msg := sprintf("GOVERNANCE VIOLATION (ISO 27001 A.8.24): S3 Bucket '%v' must have server-side encryption enabled.", [resource.address])
}

has_server_side_encryption(bucket) {
    some encryption in input.resource_changes
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"
    some configured_encryption in input.configuration.root_module.resources
    configured_encryption.address == encryption.address
    some reference in configured_encryption.expressions.bucket.references
    contains(reference, bucket.address)
    some rule in encryption.change.after.rule
    rule.apply_server_side_encryption_by_default.sse_algorithm != ""
}

# Rule 2: Deny EBS volumes that are not encrypted
deny[msg] {
    some resource in input.resource_changes
    resource.type == "aws_ebs_volume"

    resource.change.after.encrypted == false

    msg := sprintf("GOVERNANCE VIOLATION (ISO 27001 A.8.24): EBS Volume '%v' must be encrypted at rest.", [resource.address])
}

# Rule 3: Deny security groups allowing SSH (port 22) from 0.0.0.0/0
deny[msg] {
    some resource in input.resource_changes
    resource.type == "aws_security_group"

    some ingress in resource.change.after.ingress
    ingress.from_port <= 22
    ingress.to_port >= 22
    "0.0.0.0/0" in ingress.cidr_blocks

    msg := sprintf("GOVERNANCE VIOLATION (ISO 27001 A.8.20): Security Group '%v' allows unrestricted SSH ingress from 0.0.0.0/0.", [resource.address])
}

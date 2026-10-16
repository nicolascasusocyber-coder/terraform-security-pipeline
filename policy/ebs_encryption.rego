package main

# ISO 27001 A.8.24: Check EBS encryption
deny[msg] {
    some i
    volume := input.resource.aws_ebs_volume[i]
    volume.encrypted != true
    msg := sprintf("GOVERNANCE VIOLATION (ISO 27001 A.8.24): EBS Volume '%v' must have encryption enabled.", [i])
}

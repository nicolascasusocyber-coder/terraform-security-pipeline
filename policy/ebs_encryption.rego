package main

import rego.v1

deny contains msg if {
    volume := input.resource.aws_ebs_volume[_]
    not volume.encrypted
    msg := "GOVERNANCE VIOLATION (ISO 27001 A.8.24): EBS Volume must have encryption set to true."
}

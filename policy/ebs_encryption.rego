package main

import rego.v1

deny contains msg if {
    volume := planned_resource[_]
    volume.type == "aws_ebs_volume"
    not volume.change.after.encrypted == true
    msg := sprintf("EBS_ENCRYPTION %s requires encryption (ISO 27001 A.8.24 mapping)", [volume.address])
}

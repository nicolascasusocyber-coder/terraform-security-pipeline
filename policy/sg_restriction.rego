package main

import rego.v1

deny contains msg if {
    sg := input.resource.aws_security_group[_]
    ingress := sg.ingress[_]
    ingress.from_port <= 22
    ingress.to_port >= 22
    cidr := ingress.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    msg := "GOVERNANCE VIOLATION (ISO 27001 A.8.20): Security group allows unrestricted SSH access (0.0.0.0/0)."
}

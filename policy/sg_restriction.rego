package main

# ISO 27001 A.8.20: Check SSH security group restrictions
deny[msg] {
    some i
    sg := input.resource.aws_security_group[i]
    some j
    ingress := sg.ingress[j]
    ingress.from_port <= 22
    ingress.to_port >= 22
    some k
    ingress.cidr_blocks[k] == "0.0.0.0/0"
    msg := sprintf("GOVERNANCE VIOLATION (ISO 27001 A.8.20): Security group '%v' allows unrestricted SSH access (0.0.0.0/0).", [i])
}

package main

import rego.v1

planned_resource contains resource if {
    some resource in input.resource_changes
    resource.mode == "managed"
    is_object(resource.change.after)
}

deny contains "PLAN_FORMAT expected Terraform plan JSON with resource_changes" if {
    not is_array(input.resource_changes)
}

deny contains msg if {
    resource := planned_resource[_]
    some ingress in ssh_ingress(resource)
    ssh_protocol(ingress)
    some cidr in public_sources(ingress)
    msg := sprintf("PUBLIC_SSH %s allows SSH from %s (ISO 27001 A.8.20 mapping)", [resource.address, cidr])
}

ssh_ingress(resource) := resource.change.after.ingress if resource.type == "aws_security_group"

ssh_ingress(resource) := [resource.change.after] if resource.type == "aws_vpc_security_group_ingress_rule"

ssh_ingress(resource) := [resource.change.after] if {
    resource.type == "aws_security_group_rule"
    resource.change.after.type == "ingress"
}

ssh_protocol(rule) if {
    object.get(rule, "ip_protocol", object.get(rule, "protocol", "")) in {"-1", "all"}
}

ssh_protocol(rule) if {
    object.get(rule, "ip_protocol", object.get(rule, "protocol", "")) in {"tcp", "6"}
    rule.from_port <= 22
    rule.to_port >= 22
}

public_sources(rule) contains cidr if {
    some field in {"cidr_blocks", "ipv6_cidr_blocks"}
    some cidr in object.get(rule, field, [])
    cidr in {"0.0.0.0/0", "::/0"}
}

public_sources(rule) contains cidr if {
    some field in {"cidr_ipv4", "cidr_ipv6"}
    cidr := object.get(rule, field, "")
    cidr in {"0.0.0.0/0", "::/0"}
}

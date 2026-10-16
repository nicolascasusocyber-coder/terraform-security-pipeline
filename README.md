# Automating Security Checks in Terraform Cloud Infrastructure

This repository implements an automated pre-deployment security scanning pipeline for Terraform Infrastructure as Code (IaC) using GitHub Actions, Checkov, and Open Policy Agent (OPA/Conftest).

## Project Features
- **Static Security Analysis:** Scans Terraform code for known vulnerabilities using Checkov.
- **Policy-as-Code Enforcement:** Evaluates `terraform plan` outputs against custom OPA Rego governance rules mapped to ISO 27001 controls.
- **Zero Cloud Cost:** Utilizes local plan generation without requiring active AWS infrastructure credentials.

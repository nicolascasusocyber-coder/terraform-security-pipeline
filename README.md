# Automating Security Checks in Terraform Cloud Infrastructure

GitHub Actions runs Checkov against Terraform source and Conftest against a
generated Terraform plan. The demo provisions one VPC, one security group,
and one empty S3 bucket with explicit AES-256 encryption and public access blocked.

## Security checks

Open **Actions → Terraform security checks** to see the checks and download the
`security-checks` log artifact. CI also runs on pushes and pull requests to
`main`. It plans from empty local state with dummy AWS credentials and skips AWS
identity lookups. Dependency installation requires internet access.

| Test | Expected result |
| --- | --- |
| Secure configuration | Terraform validates, selected Checkov controls pass, and Conftest accepts the plan |
| Public SSH over IPv4 and IPv6 | Checkov flags SSH and Conftest reports `PUBLIC_SSH` for both CIDRs |
| Missing explicit S3 encryption and unencrypted EBS | Conftest reports `S3_ENCRYPTION` and `EBS_ENCRYPTION` |
| Encryption configured for a different bucket | Rego unit test requires a denial for the unmatched bucket |

The negative test changes a temporary copy and generates its own plan. The EBS
volume exists only in that test. Run the same tests locally with Terraform 1.12.2,
Python, Checkov 3.2.495 and Conftest 0.71.1 on your PATH using
`bash scripts/test-security.sh` from the repository root.

The Checkov profile covers public SSH and four S3 public-access-block settings
(`CKV_AWS_24`, `CKV_AWS_53`–`56`). Conftest maps encryption checks to
ISO/IEC 27001:2022 Annex A.8.24 and public SSH to A.8.20 for the research report.
The checks cover these specific configuration patterns. Broader assessment would
include other exposure paths and operational controls.

## AWS demo

The deployment workflow runs manually from `main`, repeats security tests,
and uses the `aws-demo` environment. Follow the [deployment setup](docs/deployment.md)
before enabling AWS access. See the [recording script](docs/demo.md) for a
short demonstration and evidence checklist.

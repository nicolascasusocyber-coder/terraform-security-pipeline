# Demo recording and report evidence

1. Open **Actions → Terraform security checks**, select a completed run, and
   show the green job. Say “Checkov checks the source. Conftest evaluates the
   changes Terraform plans to make. The secure configuration passes both.”
2. Expand **Run positive and negative security tests**. Show Checkov's
   `CKV_AWS_24` result and Conftest's `PUBLIC_SSH`, `S3_ENCRYPTION`, and
   `EBS_ENCRYPTION` findings. Say “The test creates a separate configuration
   with public SSH and disabled or missing encryption. Both scanners reject
   it. The overall job passes because it checks for those expected failures.”
3. If the approved AWS deployment ran, show the environment approval and the
   apply summary. Then show the VPC, the restricted security group and the
   bucket's encryption and public access settings. Record the destroy summary
   after the demo. If the report only has CI evidence, describe the deployment
   workflow as configured in code, and record its actual execution status.
4. In the report, include the commit SHA, Actions run link and date, tool
   versions, test conditions, and actual results. Download the
   `security-checks` artifact before it expires and excerpt the relevant
   findings. Keep account IDs, credentials, Terraform state, and saved plans
   out of the recording and report.

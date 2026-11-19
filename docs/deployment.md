# Protected AWS deployment

1. Obtain authorization for the specific AWS account and region, use of a
   GitHub OIDC role, creation of the demo resources, and any charges.
   A company account requires approval from its owner. Confirm the state bucket
   and cleanup plan with the account owner.
2. In GitHub, create the environment `aws-demo`, restrict deployments to
   `main`, and configure required reviewers. Disable self-review and
   administrator bypass if an independent reviewer is available. On plans or
   repository visibility settings without required reviewers, keep AWS access
   disabled. GitHub documents which plans and repository visibility settings
   support this feature.
3. Have the AWS administrator configure the GitHub OIDC provider
   `token.actions.githubusercontent.com` with audience `sts.amazonaws.com`
   and a dedicated role. The role trust policy should allow
   `sts:AssumeRoleWithWebIdentity` only when both exact conditions below match.

   ```json
   {
     "StringEquals": {
       "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
       "token.actions.githubusercontent.com:sub": "repo:nicolascasusocyber-coder/terraform-security-pipeline:environment:aws-demo"
     }
   }
   ```

   Update the subject if the repository name or owner changes. Keep branch
   restriction in the GitHub environment because the OIDC subject names the
   environment. See [GitHub's AWS OIDC guide](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws).
4. Scope role permissions to the demo bucket and its configuration, the VPC
   and security group lifecycle in the chosen region, and the state and lock
   keys below. Use EC2 resource and tag conditions for mutations when supported
   and account/region scope for required read actions. Limit state-bucket
   listing to the state prefix, grant Get/Put on the state key, and grant
   Get/Put/Delete on the lock key. Validate the policy with the AWS
   administrator before enabling the role. The exact permissions depend on
   the account's restrictions and state-bucket encryption.
5. Put these variables on the GitHub environment.

   | Variable | Value |
   | --- | --- |
   | `AWS_ROLE_ARN` | Dedicated OIDC role ARN |
   | `AWS_ACCOUNT_ID` | Authorized account ID |
   | `AWS_REGION` | Approved AWS region |
   | `DEMO_BUCKET` | Globally unique demo bucket name, distinct from the state bucket |
   | `STATE_BUCKET` | Existing private, encrypted and versioned S3 state bucket in the region |

   The workflow uses `terraform-security-pipeline/demo.tfstate` and
   `terraform-security-pipeline/demo.tfstate.tflock` in the state bucket.
6. In **Actions → AWS demo deployment → Run workflow**, select `main` and
   `apply`, type `APPROVE-AWS`, and obtain environment approval. The job uses
   OIDC, evaluates the AWS plan with Conftest, and applies that same saved plan.
   Keep state files and saved plans private.
7. After recording, dispatch `destroy` on `main` with the same confirmation
   and approval. Keep the demo bucket empty so Terraform can remove it. Verify
   cleanup in the Actions log and AWS console. Leave the existing state bucket
   in place.

# Pipeline audit — 10 October 2026

Scope: this repository's PR, deployment, manual plan, destroy and drift workflows; the reusable workflows in `terraform-gha-workflows`; and read-only inspection of GitHub branch rules, environments and Actions settings. The incident run was `38056893128`. No AWS deployment, IAM changes, repository settings changes, artifact deletion or key rotation were performed.

## Findings and fixes

| Severity | Finding | Resolution |
| --- | --- | --- |
| High | A compute plan with 9 additions exported `has_changes`, but compute apply was skipped after no-change upstream applies. GitHub implicitly added `success()` to the apply condition. | Apply uses `!cancelled()`, explicitly requires a successful plan and changes, and permits legitimate upstream skips. Regression tests reproduce the old incident and cover all eight change combinations. |
| High | A deployment could report success even when a changed stack was never applied. | A final `Deployment result` job checks every plan and verifies that each changed stack applied successfully. Missing outputs fail the gate. |
| High | Binary plans, including compute private keys from state, were uploaded unencrypted. | v3 uploads only encrypted plans, verifies the original plan digest after decryption and before Terraform reads it, and fails safely on missing encryption keys. Existing v2 artifacts are outside this fix. |
| High | Live reusable workflows could be called from PR events or feature branches if the caller granted OIDC access. | Reject PR events, tags and non-default branches before AWS credentials. Manual plan and drift callers additionally require `master`. AWS OIDC trust remains a separate control requiring cloud review. |
| Medium | Mutable action/reusable workflow tags permitted dependency changes without a reviewed code change. | Verified full commit SHA pins and weekly Dependabot updates. The caller pins the commit published as v3.0.0. |
| Medium | Reusable inputs were inserted directly into shell commands; root paths were unchecked. | Quoted environment inputs and resolved workspace/root/variable-file containment checks before AWS access. |
| Medium | Drift disabled state locking; manual plan did not share deployment concurrency. | All live callers share concurrency without cancellation, including manual plan. Drift and shared Terraform operations retain locking with five-minute waits. |
| Medium | Reusable workflow changes had no CI. | Credential-free actionlint, shell execution, encryption, integrity and policy regression tests run on shared PRs/main/merge queues. |
| Medium | Default six-hour job execution limits and persisted checkout tokens enlarged the failure/exposure window. | Bounded job execution time and checkout credential persistence disabled. Latest-commit verification uses an explicitly scoped token. |
| Medium | A rerun could conflict with an existing artifact of the same name, or apply a plan from a different attempt. | Artifact names include `github.run_attempt`. Recovery requires rerunning all jobs. |

## Verified controls and remaining actions

The active `protect_master` ruleset requires the `PR checks` status from GitHub Actions, with strict status checking, and blocks force pushes and branch deletion. The classic branch-protection endpoint returns 404 because protection is managed through rulesets. The inspected rules do not require PR review or CODEOWNERS approval. Add those rules with independent reviewers when a second maintainer is available.

All six apply/destroy environments have required reviewers and protected-branch deployment policies. They currently allow self-review and administrator bypass. That is an explicit separation-of-duties gap; independent review cannot be achieved by YAML alone. Add a second reviewer, prevent self-review, disable bypass, and restrict the environment to `master`. These settings were inspected and left unchanged.

Actions currently permits all actions and does not require SHA pinning repository-wide. Workflow code now pins dependencies, but administrators should also enable an action allowlist and SHA policy. Protect shared `main` with the new `Shared workflow checks` status before subsequent releases.

Planning, drift and deployment still use `AWS_TERRAFORM_ROLE_ARN`. No AWS credentials were available for inspecting its policies or OIDC trust. Review exact account, branch/environment subjects, resource permissions and trust audience; create a restricted planning role separately. Plans may need read access to state and permission to acquire/release its lock, so a planning role is not simply a blanket AWS ReadOnlyAccess role.

Existing unencrypted v2 artifacts may contain state private keys. Review access, remove retained plaintext plan artifacts using an approved cleanup, and assess SSH key rotation. This audit deliberately did not download the secret-bearing artifacts or change live key material. Encryption protects future artifact contents, not already exposed keys. Terraform also prints values that were not marked sensitive; never put unmarked credentials in inputs or outputs.

PR checks expose no AWS credentials. Infracost is a source-based total estimate, not a cost delta or budget gate. Fork PRs do not receive its API secret and therefore fail that check; bring external changes to a trusted branch after review. Do not use `pull_request_target` to execute untrusted PR code with secrets. Budget thresholds and an independently reviewed cost policy remain an organization decision.

Drift detection fails on real drift, desired changes or plan errors; it never applies. Terraform state versioning, encryption and lockfiles remain unchanged. Manual destroy retains typed confirmation, separate protected environments and exact-plan checks. Networking/storage destruction can affect dependent stacks; use the reviewed recovery order rather than destroying upstream infrastructure first.

## v3 rollout

1. Publish the shared release after its Linux CI passes and pin its full merge-commit SHA in the caller PR.
2. Before merging the caller PR, add `TF_PLAN_PASSPHRASE` under repository Settings → Secrets and variables → Actions. Generate at least 32 random characters, for example `openssl rand -hex 32`. Do not commit or paste it into tickets/chat. All changed plan/apply/destroy jobs explicitly receive only this secret.
3. Review and merge the caller PR after `PR checks` passes. A merge triggers deployment; each changed stack still requires its environment approval. The new compute VM remains a real change to review.
4. Review the new plan, confirm no existing-instance replacement, and approve the intended environment. If an artifact expires, the branch advances, state changes or the secret rotates, rerun **all jobs** for a new plan and approvals.

Validation covers local shell behavior, orchestration scenarios and Linux CI. It does not establish live AWS least privilege, successful cloud apply, or independent human review. These fixes harden the pipeline; they are not a claim of compliance certification.

References: [GitHub job dependencies](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-jobs), [secure use of Actions](https://docs.github.com/en/actions/reference/security/secure-use), [script injection prevention](https://docs.github.com/en/actions/concepts/security/script-injections), and [Terraform plan locking and sensitive data](https://developer.hashicorp.com/terraform/cli/commands/plan).

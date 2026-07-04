# Contributing Guidelines

## PR Process for Infrastructure Changes

### Step 1: Create a Feature Branch
```bash
git checkout -b feature/description
# Example: feature/add-ebs-csi-driver
```

### Step 2: Make Changes
- Update Terraform files in the appropriate component directory
- Follow naming conventions (snake_case)
- Add/update documentation and comments
- Ensure all variables have descriptions

### Step 3: Local Validation
```bash
# Format code
terraform fmt -recursive

# Validate syntax
cd environments/dev/eks
terraform init -backend=false
terraform validate

# Run TFLint
cd ../..
tflint --init
tflint --recursive environments/dev/

# Fix any issues and commit
git add .
git commit -m "meaningful commit message"
```

### Step 4: Push and Create PR
```bash
git push origin feature/description
```
→ Open PR against `main` or `master` branch

### Step 5: Automated Checks
The PR will automatically trigger:
1. ✓ **Terraform Format Check** - Code formatting validation
2. ✓ **Terraform Validation** - Syntax and configuration checks
3. ✓ **TFLint** - Best practices and naming conventions
4. ✓ **TFSec** - Security vulnerability scanning
5. ✓ **Cost Estimation** - Infrastructure cost comparison
6. ✓ **Documentation Check** - Variable and output documentation

### Step 6: Address Review Comments
- Review automated check reports in PR comments
- Fix any issues and push updates
- Checks re-run automatically on each push

### Step 7: Manual Review
- Team lead reviews the changes
- Validates business logic and requirements
- Approves or requests changes

### Step 8: Merge
- After approval, merge to `main`
- Automatic `terraform apply` is triggered
- Resources are deployed to the specified environment

## Requirements for All PRs

### Code Quality
- [ ] Code passes `terraform fmt` without changes
- [ ] `terraform validate` succeeds
- [ ] TFLint reports no critical violations
- [ ] No TFSec security findings

### Documentation
- [ ] All variables have descriptions
- [ ] All outputs have descriptions
- [ ] Comments explain complex logic
- [ ] `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` are present

### Resource Requirements
- [ ] All resources have tags (at minimum: `Name`, `Environment`, `ManagedBy`)
- [ ] Consistent naming convention (snake_case)
- [ ] No sensitive data in code (use AWS Secrets Manager instead)

### Testing
- [ ] Plan output reviewed for expected changes
- [ ] No unexpected resource deletions or recreations
- [ ] Cost impact reviewed and approved

## Common Issues & Solutions

### "Terraform Format Check Failed"
```bash
terraform fmt -recursive
git add .
git commit -m "fix: terraform formatting"
git push
```

### "Variable not documented"
```terraform
variable "example" {
  type        = string
  description = "Clear description of what this variable does"  # ← Add this!
}
```

### "Missing tags on resource"
```terraform
tags = merge(
  var.common_tags,
  {
    Name        = "resource-name"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
)
```

### "TFSec Security Finding"
Review the finding and address per recommendation, or document exception with:
```terraform
# tfsec:skip=AVD-AWS-0001:This is required for legacy system compatibility
```

## Rollback Procedure

If issues are discovered after deployment:

1. **Immediate Actions**:
   - Communicate issue to team
   - Identify which resource(s) are affected
   - Check CloudTrail for recent changes

2. **Rollback Options**:
   - **Option A: Git Revert**
     ```bash
     git revert <commit-hash>
     git push origin main
     # Auto-triggers terraform apply with previous state
     ```
   
   - **Option B: Manual Destroy & Recreate**
     ```bash
     # Via GitHub Actions UI
     Actions → Terraform Destroy → Run workflow
     # Then re-merge the PR when ready
     ```

3. **Post-Rollback**:
   - Document root cause
   - Update validation rules if needed
   - Create follow-up PR to fix underlying issue

## Emergency Process (Break Glass)

For critical production issues that require immediate action:

1. Document the emergency
2. Notify team leads
3. Proceed with manual AWS console changes if necessary
4. Create PR within 4 hours documenting changes
5. Run `terraform import` to sync state
6. Review and merge PR

## Questions or Issues?

- Check existing PRs and issues
- Review workflow logs in GitHub Actions
- Consult with team lead
- Create a discussion thread

---

**Thank you for contributing to our infrastructure!** 🚀

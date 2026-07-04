# Terraform CI/CD Pipeline with GitHub Actions

This repository implements a robust enterprise-grade CI/CD pipeline for Terraform using GitHub Actions. The workflow automates Terraform operations with comprehensive validation, security scanning, cost estimation, and manual review gates.

## Workflow Overview

### Components Managed
- **Networking**: VPC, Subnets, Route Tables, Security Groups
- **Compute**: EC2 instances, Bastion hosts, Auto Scaling
- **Storage**: S3 buckets, versioning, encryption, lifecycle policies
- **ECR**: Elastic Container Registry repositories with lifecycle policies
- **EKS**: Kubernetes cluster with managed node groups, add-ons, and OIDC provider

### Available Workflows

#### 1. **Terraform Plan** (`terraform-plan.yml`)
- **Trigger**: Pull requests to `main` or `master`
- **Actions**:
  - Terraform format validation
  - Terraform initialization and validation
  - Terraform plan with cost estimation
- **Outputs**: Plan artifacts and cost estimates

#### 2. **Terraform Apply** (`terraform-apply.yml`)
- **Trigger**: Push to `main` or `master`
- **Workflow**:
  1. Runs `terraform-plan` for all components
  2. Runs `terraform-apply` after plan approval
- **Components**:
  - Networking
  - Compute
  - Storage
  - ECR
  - EKS

#### 3. **Terraform Destroy** (`terraform-destroy.yml`)
- **Trigger**: Manual dispatch via GitHub Actions UI
- **Parameters**:
  - Environment selection (dev)
  - Component selection (networking, compute, storage, ecr, eks)
  - Confirmation (require typing "DESTROY")
- **Safety**: Requires explicit confirmation to prevent accidental deletions

#### 4. **PR Validation** (`pr-validation.yml`) - **NEW**
- **Trigger**: Pull requests with changes to `environments/**` or `.github/workflows/**`
- **Comprehensive Checks**:
  1. **Terraform Format**: Validates code formatting (`terraform fmt`)
  2. **Terraform Validation**: Checks configuration syntax
  3. **TFLint**: Static analysis for best practices and naming conventions
  4. **TFSec**: Security vulnerability scanning
  5. **Infracost**: Infrastructure cost estimation and comparison
  6. **Documentation**: Ensures all variables and files are properly documented
- **PR Comments**: Automatic feedback with detailed reports
- **Exit Criteria**: All checks must pass before merge

## Environment Variables & Secrets

### Required Secrets
- `INFRACOST_API_KEY`: API key for Infracost cost estimation (optional but recommended)

### AWS Authentication
- Uses **OIDC Provider** for secure AWS credential exchange
- IAM Role: `arn:aws:iam::234617061868:role/github-actions-terraform-role`
- No static credentials stored

## Configuration Files

### `.tflint.hcl`
TFLint configuration for static analysis:
- AWS plugin enabled
- Naming convention enforcement (snake_case)
- Terraform version requirements
- Tag enforcement (Environment, ManagedBy, Project)
- Documentation requirements

## Usage Examples

### 1. Create a Pull Request
```bash
git checkout -b feature/new-resource
# Make changes to Terraform files
git add environments/dev/*/
git commit -m "Add new EKS add-on"
git push origin feature/new-resource
```
→ Automatically triggers PR validation checks

### 2. Merge to Main (Auto-Deploy)
```bash
# After PR approval and merge to main
# Automatically triggers terraform-apply
```

### 3. Manual Destroy (With Confirmation)
```bash
# Go to Actions → Terraform Destroy → Run workflow
# Select: environment=dev, component=eks, confirm_destroy=DESTROY
```

### 4. Local Development Setup

```bash
# Install TFLint locally
brew install tflint

# Configure TFLint
tflint --init

# Run validation locally before pushing
terraform fmt -recursive
terraform validate
tflint --recursive environments/dev/
```

## Security Best Practices

✅ **Implemented**:
- OIDC-based AWS authentication (no static keys)
- Cost estimation review before apply
- Security scanning (TFSec)
- Code review requirements
- Automated documentation checks
- Naming convention enforcement
- Tag requirement enforcement
- Plan review gates

✅ **Recommended**:
- Protect `main` branch with status checks
- Require PR reviews before merge
- Enable branch protection rules
- Regularly update IAM role permissions
- Review Infracost alerts
- Monitor TFSec findings

## Troubleshooting

### Terraform Format Check Fails
```bash
terraform fmt -recursive
```

### TFLint Violations
```bash
tflint --init
tflint --recursive environments/dev/
```

### Cost Estimation Missing
- Ensure `INFRACOST_API_KEY` is set in repository secrets
- Free API key available at https://www.infracost.io

### AWS Authentication Errors
- Verify IAM role trust relationship with GitHub OIDC provider
- Check repository secrets for AWS configuration

## References
- [Terraform Docs](https://www.terraform.io/docs/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [TFLint](https://github.com/terraform-linters/tflint)
- [TFSec](https://github.com/aquasecurity/tfsec)
- [Infracost](https://www.infracost.io/)

---

**Maintainer:** [bhowmickkrishnendu](https://github.com/bhowmickkrishnendu)

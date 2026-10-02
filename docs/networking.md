# Networking design

Networking is the foundation for the EC2 and future EKS roots. Its Terraform state is separate from the other components at `dev/networking/terraform.tfstate`. Compute reads three outputs from this state: the VPC ID, public subnet IDs, and private subnet IDs.

## What the code builds

`environments/dev/networking/main.tf` calls version `6.6.1` of the community VPC module. The current `dev.tfvars` sets `environment = "dev"`, `aws_region = "ap-south-1"`, and `vpc_cidr = "10.0.0.0/16"`. The module call describes this layout:

| Availability zone | Public subnet | Private subnet |
| --- | --- | --- |
| `ap-south-1a` | `10.0.1.0/24` | `10.0.11.0/24` |
| `ap-south-1b` | `10.0.2.0/24` | `10.0.12.0/24` |

The VPC is named `dev-vpc`. DNS support and DNS hostnames are enabled. The module manages the VPC, subnet resources, and supporting routing from these inputs. The code sets `enable_nat_gateway = false`, so the private subnets have no NAT path for general internet access. Before placing a private EC2 instance or EKS node there, decide how it will reach package repositories, SSM, ECR, STS, and other services it needs. NAT, VPC endpoints, or another approved network path are design choices that are not implemented here yet.

The output names are `vpc_id`, `public_subnets`, and `private_subnets`. They are the contract for roots that read networking state. Compute uses the first public subnet for `bastion` and the first private subnet for a future private instance. That means the second subnet exists but compute does not currently spread instances across zones. EKS code refers to `vpc_cidr`, `private_subnet_ids`, and `public_subnet_ids`, which this root does not output. EKS needs that interface fixed before planning a deployment.

## Why this layout matters

A VPC CIDR is the address space for the whole network. Each `/24` subnet is a smaller slice of that `/16` space. Public and private here describe intended routing, not a property of an EC2 instance by itself. An instance also needs the right subnet, public IP choice, security group, and route to be reachable. The bastion code sets a public IP in the first public subnet. A private instance would use the first private subnet and no public IP.

The module tags resources with `Environment = dev` and `ManagedBy = terraform`. The root does not yet define a central tag map or a data-driven subnet map. The region is an input, but the availability zones and subnet CIDRs are hardcoded for `ap-south-1`. Changing only `aws_region` would not make this configuration portable to another region. Changing CIDRs or subnet order for deployed resources can also affect downstream addresses and instance placement, so inspect the complete plan before applying such a change.

## Code map and routine checks

- `backend.tf` selects the S3 state key and S3 lockfile.
- `versions.tf` constrains Terraform and the AWS provider; `.terraform.lock.hcl` selects the provider build.
- `provider.tf` uses `var.aws_region` and the standard AWS credential chain.
- `variables.tf` defines the three required inputs; `dev.tfvars` supplies their current values.
- `outputs.tf` publishes the VPC and subnet IDs used by compute.

Run these checks from the repository root after confirming the AWS account:

```powershell
$env:AWS_PROFILE = 'terraform-dev'
terraform -chdir=environments/dev/networking init -lockfile=readonly -input=false
terraform -chdir=environments/dev/networking validate
terraform -chdir=environments/dev/networking plan -var-file=dev.tfvars -input=false
```

The last verified live plan proposed zero resource changes. If a later plan changes a subnet or VPC ID, inspect the compute and EKS dependencies before applying. The state bucket and its protections are described in [backend.md](backend.md).

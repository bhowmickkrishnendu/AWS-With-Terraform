# Networking design

Networking is the foundation for the EC2 and future EKS roots. Its Terraform state is separate from the other components at `dev/networking/terraform.tfstate`. Compute reads three outputs from this state: the VPC ID, public subnet IDs, and private subnet IDs.

## What the code builds

`stacks/networking/main.tf` calls version `6.6.1` of the community VPC module. The current `terraform.tfvars` sets `environment = "dev"`, `aws_region = "ap-south-1"`, and `vpc_cidr = "10.0.0.0/16"`. The module call describes this layout:

| Availability zone | Public subnet | Private subnet |
| --- | --- | --- |
| `ap-south-1a` | `10.0.1.0/24` | `10.0.11.0/24` |
| `ap-south-1b` | `10.0.2.0/24` | `10.0.12.0/24` |

The VPC is named `dev-vpc`. DNS support and DNS hostnames are enabled. The module manages the VPC, subnet resources, and routing. Phase 2 moved the zone and subnet lists into `terraform.tfvars`. The list positions must stay aligned because each position describes one zone. Changing a deployed CIDR or list order can affect subnet IDs and the instances that use them, so review the plan before making such a change.

Private outbound access is set with `nat_gateway_mode`. `none` keeps the current deployed routing, `single` creates one NAT gateway, and `per_az` creates one NAT gateway in each zone. The current `terraform.tfvars` uses `none`, so it creates no NAT gateway. An optional S3 gateway endpoint can add a route to the private route tables for in-region S3 traffic; it is disabled in `terraform.tfvars`. These defaults preserve the current VPC. NAT gateways and their elastic IPs have ongoing AWS costs. A single gateway costs less but makes both zones depend on one zone for outbound traffic.

`interface_endpoint_services` is an optional set of AWS service suffixes. For each entry, Terraform creates an interface endpoint in both private subnets with private DNS. A separate security group allows HTTPS to those endpoints only from the private subnet CIDRs. The current set is empty. Interface endpoints have a charge for each service and zone, so enable only the services a workload needs. For a private instance managed with SSM and no NAT, AWS lists `ssm`, `ssmmessages`, and `ec2messages`, plus an S3 path for agent updates. ECR image pulls need `ecr.api`, `ecr.dkr`, and S3. See [AWS Systems Manager VPC endpoint guidance](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html) and the [EKS private-cluster guide](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html). Endpoints do not provide general access to package repositories.

Enabling NAT later would provide general outbound access for packages and AWS public APIs, but security groups and IAM would still control what a private workload can use. A future EKS cluster also needs its own control-plane endpoint, image-pull, and workload identity checks. [AWS guidance for private EKS clusters](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html) explains the extra endpoints needed if a cluster is run without internet egress.

The existing output names `vpc_id`, `public_subnets`, and `private_subnets` remain the contract for roots that read networking state. Phase 2 also exposes `availability_zones`, the optional S3 endpoint ID, and a map of interface endpoint IDs. Compute uses the first public subnet for `bastion` and can select either subnet by index for a future private instance. EKS code refers to `vpc_cidr`, `private_subnet_ids`, and `public_subnet_ids`, which this root does not output. EKS needs that interface fixed before planning a deployment.

## Why this layout matters

A VPC CIDR is the address space for the whole network. Each `/24` subnet is a smaller slice of that `/16` space. Public and private here describe intended routing, not a property of an EC2 instance by itself. An instance also needs the right subnet, public IP choice, security group, and route to be reachable. The bastion code sets a public IP in the first public subnet. A private instance would use the first private subnet and no public IP.

The module tags resources with `Environment = dev` and `ManagedBy = terraform`. The S3 endpoint uses the same tags plus a name. Availability zones and subnet CIDRs are now inputs, so the code can describe another region, but changing the deployed `dev` values would be an infrastructure change. This root keeps `module.vpc` at its original Terraform address and keeps the existing state key and output names.

## Code map and routine checks

- `backend.tf` selects the S3 state key and S3 lockfile.
- `versions.tf` constrains Terraform and the AWS provider; `.terraform.lock.hcl` selects the provider build.
- `provider.tf` uses `var.aws_region` and the standard AWS credential chain.
- `variables.tf` defines the VPC, zone, subnet, NAT, and endpoint inputs; `terraform.tfvars` leaves private egress disabled.
- `outputs.tf` publishes the VPC and subnet IDs used by compute.

Run these checks from the repository root after confirming the AWS account:

```powershell
$env:AWS_PROFILE = 'terraform-dev'
terraform -chdir=stacks/networking init -lockfile=readonly -input=false
terraform -chdir=stacks/networking validate
terraform -chdir=stacks/networking plan -input=false
```

The latest Phase 2 live plan with NAT, the S3 endpoint, and interface endpoints disabled proposes zero changes. An earlier trial plan with `per_az` and the S3 endpoint enabled showed seven creates and no replacements, but those settings were left disabled. Private subnets still have no general outbound internet access. If a later plan changes a subnet or VPC ID, inspect compute and EKS dependencies before applying. The state bucket and its protections are described in [backend.md](backend.md).

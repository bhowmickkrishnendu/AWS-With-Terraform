# Compute design

The compute root manages the running bastion in `dev/compute/terraform.tfstate`. It reads VPC and subnet IDs from the networking state. The bastion is in a public subnet, has a public IP, and can be reached directly from a laptop when its security group allows the laptop's public source IP on TCP port 22. The internet gateway supplies the route. A NAT gateway is not needed for a public EC2 instance. NAT remains disabled because there is no private VM or EKS workload yet.

## VM definitions

`dev.tfvars` holds a map called `instance_definitions`. Each VM has its own AMI, instance type, subnet tier, optional availability zone, public IP setting, security group rules, and optional IAM role. The map key is part of its Terraform address. Keep `bastion` stable because the running instance is tracked as `module.instances["bastion"]`. A disabled definition keeps its security group but creates no instance. The disabled `private_ec2` definition retains a security group already in state until that VM is needed.

The bastion has `availability_zone = "ap-south-1a"` to keep its current subnet. For a new enabled VM with no AZ, `random_integer.subnet_choice` picks one subnet from the selected tier. Terraform saves that number in state, so the next plan uses the same subnet. This is a random choice once, not a fresh choice on every plan. Changing a deployed VM's AZ or subnet normally requires replacing that EC2 instance. Set the AZ before the first apply when you need a specific zone.

The EC2 community module is pinned to `6.4.0`. `create_security_group = false` makes the module attach only the VM's configured security group. Root volume size, type, and delete behavior use root defaults unless the VM overrides them. `extra_ebs`, tags, and user data are also per VM. The EBS mount template checks for an existing filesystem and mount before making changes; check the Linux device path on the selected AMI before adding a data volume.

## SSH and security groups

Public subnet placement does not create an SSH rule. The bastion's `security_group.ingress.ssh.cidr_blocks` currently contains `0.0.0.0/0`, matching its deployed direct-SSH access. That means any IPv4 address can attempt TCP 22. To allow only your laptop, replace it with your current public address as a `/32`, for example `203.0.113.10/32`. A private VPC CIDR such as `10.0.0.0/16` allows VPC sources, not a normal internet laptop. Keep the public IP and public route as well.

Each definition contains named ingress and egress rules. A rule can use an IPv4 CIDR or name `source_vm` to use another VM's security group. The disabled private VM group uses `source_vm = "bastion"` for SSH. Source VMs must use CIDR-only ingress rules so Terraform can build the groups in order. Both reusable group patterns keep rules inline, avoiding a mix of inline and separate rule resources. The bastion egress rules currently permit SSH and HTTPS to all IPv4 destinations, matching the existing configuration. Review these rules before using the bastion for more workloads.

Each enabled VM can set `iam` with an explicit role name, profile name, and map of managed policy ARNs. The bastion keeps its deployed role and profile names and its SSM managed policy attachment. Keeping that policy does not require you to connect through SSM. The role, profile, policy attachment, and existing security groups have `moved` blocks so Terraform can keep their state objects while adopting keyed addresses. Review the plan before any apply.

Terraform generates each enabled VM's SSH key, registers its public half with EC2, and stores the private half in Secrets Manager. The private key is also in Terraform state. Protect state and saved plans, and do not print the key in CI. The secret currently has a zero-day deletion recovery window, so review that choice before extending the pattern.

## User data and checks

`locals.tf` combines the optional EBS mount template with a VM's custom user data. The bastion uses `scripts/bastion.sh`, which runs package updates and sets its hostname. A future private VM that downloads packages needs NAT or another suitable outbound path. Networking has optional NAT and endpoints ready, but both remain disabled in the current `networking/dev.tfvars`.

```powershell
$env:AWS_PROFILE = 'terraform-dev'
terraform -chdir=environments/dev/compute init -lockfile=readonly -input=false
terraform -chdir=environments/dev/compute validate
terraform -chdir=environments/dev/compute plan -var-file=dev.tfvars -input=false
```

Check that the plan keeps `module.instances["bastion"].aws_instance.this[0]` and proposes no replacement. The compatibility outputs in `outputs.tf` still provide the bastion ID and public IP. See [networking.md](networking.md) for routing and [backend.md](backend.md) for state protection.

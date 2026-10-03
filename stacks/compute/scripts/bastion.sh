# Custom bootstrap for the bastion host.
# NOTE: do not add a "#!/bin/bash" line here — it is prepended automatically
# along with the EBS-mount script (this content is appended after both).

# Example: install basic tooling and set hostname from a templatefile var.
yum update -y
yum install -y htop tmux

hostnamectl set-hostname "${hostname}"

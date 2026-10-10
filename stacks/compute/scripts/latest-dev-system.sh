# The compute root prepends the bash shebang and set -e.
# Set the hostname before package operations so it survives a package failure.
hostnamectl set-hostname "${hostname}"
dnf update -y
dnf install -y tmux
systemctl enable --now amazon-ssm-agent

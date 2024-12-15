#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Starting script execution"

# Capture username and password from credentials.txt
USERNAME=$(grep 'Generated Username' /tmp/credentials.txt | cut -d ' ' -f 3)
PASSWORD=$(grep 'Generated Password' /tmp/credentials.txt | cut -d ' ' -f 3)

echo "Captured USERNAME: $USERNAME"
echo "Captured PASSWORD: $PASSWORD"

# Change default SSH port from 22 to 244
echo "Changing SSH port"
sudo sed -i 's/^#Port 22/Port 244/' /etc/ssh/sshd_config
sudo sed -i 's/^Port 22/Port 244/' /etc/ssh/sshd_config

# Enable PasswordAuthentication
echo "Enabling PasswordAuthentication"
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Enable ChallengeResponseAuthentication
echo "Enabling ChallengeResponseAuthentication"
sudo sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config

# PermitRootLogin prohibit-password
echo "Permitting RootLogin"
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin no/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

# Set MaxAuthTries to 5
echo "Setting MaxAuthTries"
echo "MaxAuthTries 5" | sudo tee -a /etc/ssh/sshd_config

# Set MaxSessions to 2
echo "Setting MaxSessions"
echo "MaxSessions 2" | sudo tee -a /etc/ssh/sshd_config

# Deny default user ec2-user login
echo "Denying ec2-user login"
#echo "DenyUsers ec2-user" | sudo tee -a /etc/ssh/sshd_config

# Comment out Include directive to avoid conflicting settings
echo "Commenting out Include directive"
sudo sed -i 's/^Include \/etc\/ssh\/sshd_config\.d\/\*\.conf/#Include \/etc\/ssh\/sshd_config\.d\/\*\.conf/' /etc/ssh/sshd_config

# Add the generated user
echo "Adding user $USERNAME"
sudo useradd -m "$USERNAME" --badname

# Set the generated password for the new user
echo "Setting password for $USERNAME"
echo "$USERNAME:$PASSWORD" 
sudo sh -c "echo '$USERNAME:$PASSWORD' | chpasswd"
sudo grep $USERNAME /etc/shadow

# Add the new user to the sudo group
echo "Adding $USERNAME to sudo group"
sudo usermod -aG wheel "$USERNAME"

# Safely add the new user to the sudoers file using sed
echo "Updating sudoers file"
sudo sed -i "/^root.*ALL=(ALL:ALL) ALL$/a $USERNAME ALL=NOPASSWD: ALL" /etc/sudoers
sudo sed -i "/^%admin.*ALL=(ALL) ALL$/a %$USERNAME ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
sudo sed -i "/^%sudo.*ALL=(ALL:ALL) ALL$/a %$USERNAME ALL=(ALL) NOPASSWD:ALL" /etc/sudoers

# Set proper ownership and permissions for /bin/bash and /home/ec2-user
echo "Setting ownership and permissions"
sudo chown -R "$USERNAME:$USERNAME" /home/ec2-user

# User Permissions
sudo mkdir -p /home/$USERNAME/.ssh
sudo cp /home/ec2-user/.ssh/authorized_keys /home/$USERNAME/.ssh/
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys

# Restart the SSH service
echo "Restarting SSH service"
sudo systemctl restart sshd

echo "Setup complete. The system will now restart."
sudo reboot

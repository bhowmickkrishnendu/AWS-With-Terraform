#!/bin/bash

# 1. Generate a password
PASSWORD=$(tr -dc 'A-Za-z0-9!@#$%^&*()+' < /dev/urandom | head -c 20)
echo "Generated Password: $PASSWORD"

# 2. Generate a username
USERNAME=$(tr -dc 'a-z' < /dev/urandom | head -c 6)
echo "Generated Username: $USERNAME"

# 3. Change default SSH port from 22 to 244
sudo sed -i 's/^#Port 22/Port 244/' /etc/ssh/sshd_config
sudo sed -i 's/^Port 22/Port 244/' /etc/ssh/sshd_config

# 4. Enable PasswordAuthentication
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 5. Enable ChallengeResponseAuthentication
sudo sed -i 's/^#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config

# 6. PermitRootLogin prohibit-password
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin no/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

# 7. Set MaxAuthTries to 5
echo "MaxAuthTries 5" | sudo tee -a /etc/ssh/sshd_config

# 8. Set MaxSessions to 2
echo "MaxSessions 2" | sudo tee -a /etc/ssh/sshd_config

# 9. Deny default user ec2-user login
echo "DenyUsers ec2-user" | sudo tee -a /etc/ssh/sshd_config

# 10. Comment out Include directive to avoid conflicting settings
sudo sed -i 's/^Include \/etc\/ssh\/sshd_config\.d\/\*\.conf/#Include \/etc\/ssh\/sshd_config\.d\/\*\.conf/' /etc/ssh/sshd_config

# 11. Add the generated user
sudo useradd -m $USERNAME

# 12. Set the generated password for the new user
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# 13. Add the new user to the sudo group
sudo usermod -aG wheel $USERNAME

# 14. Give the new user full access in the visudo file
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USERNAME

# 15. Set proper ownership and permissions for /bin/bash and /home/ec2-user
sudo chown -R $USERNAME:$USERNAME /home/ec2-user

# 16. Restart the SSH service
sudo systemctl restart sshd

echo "Setup complete. The system will now restart."
sudo reboot

#!/bin/bash

# Fedora 21 Hardening Script

echo “Hi:)”
sleep 3
echo “I’ll start now”
sleep 3

echo “maybe run sudo yum update -y”


echo "Installing and configuring fail2ban..."
# Install fail2ban
sudo yum install fail2ban -y

# Enable and start fail2ban service
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "Ensuring SELinux is in Enforcing mode..."
# Check SELinux status
sestatus

# Set SELinux to enforcing mode
sudo setenforce 1
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config


echo "Configuring firewall with firewalld..."
# Install firewalld if not installed
sudo yum install firewalld -y

# Start and enable firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Set default zone to 'drop' to reject all incoming traffic by default
sudo firewall-cmd --set-default-zone=drop

# Allow SSH service
sudo firewall-cmd --zone=public --add-service=ssh --permanent
sudo firewall-cmd --reload

echo "Hardening SSH configuration..."
# Edit SSH config file to disable root login and password authentication
sudo sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
sudo sed -i '/^PasswordAuthentication/s/yes/no/' /etc/ssh/sshd_config
sudo sed -i '/^ChallengeResponseAuthentication/s/yes/no/' /etc/ssh/sshd_config
sudo sed -i '/^UsePAM/s/yes/no/' /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart sshd

echo "Installing and configuring AIDE (Advanced Intrusion Detection Environment)..."
# Install AIDE
sudo yum install aide -y

# Initialize AIDE database
sudo aide --init

echo “you might want to move the aide db to a new server”
echo “sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db”

# Set up a cron job for daily checks
echo "0 0 * * * /usr/bin/aide --check" | sudo tee -a /etc/crontab

echo "Disabling core dumps..."
# Disable core dumps by modifying sysctl
echo "fs.suid_dumpable = 0" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Configuring automatic security updates..."
# Install yum-cron
sudo yum install yum-cron -y

# Enable and start yum-cron service
sudo systemctl enable yum-cron
sudo systemctl start yum-cron

# Enable automatic security updates
sudo sed -i 's/^update_cmd = .*/update_cmd = security/' /etc/yum/yum-cron.conf

echo "Removing unused packages..."
# List installed packages
rpm -qa

echo "Hardening process completed!"
sleep 5
echo “Remember to chmod +x harden_fedora.sh”

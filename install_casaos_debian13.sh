#!/bin/bash

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print messages
print_message() {
    echo -e "${2}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    print_message "This script must be run as root or with sudo." "${RED}"
    exit 1
fi

# Step 1: Update the system
print_message "Updating system packages..." "${YELLOW}"
apt update && apt upgrade -y
print_message "System updated successfully." "${GREEN}"

# Step 2: Install required dependencies
print_message "Installing curl, wget, and tar..." "${YELLOW}"
apt install -y curl wget tar
print_message "Dependencies installed successfully." "${GREEN}"

# Verify installations
for cmd in curl wget tar; do
    if command -v $cmd >/dev/null 2>&1; then
        print_message "$cmd is installed." "${GREEN}"
    else
        print_message "Failed to install $cmd." "${RED}"
        exit 1
    fi
done

# Step 3: Install Docker
print_message "Setting up Docker..." "${YELLOW}"

# Uninstall old Docker versions
apt remove -y docker docker-engine docker.io containerd runc || true

# Install Docker dependencies
apt install -y ca-certificates curl gnupg

# Add Docker’s official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian trixie stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
print_message "Docker installed successfully." "${GREEN}"

# Start and enable Docker
systemctl enable --now docker
if systemctl is-active --quiet docker; then
    print_message "Docker service is running." "${GREEN}"
else
    print_message "Failed to start Docker service." "${RED}"
    exit 1
fi

# Verify Docker
if docker run hello-world >/dev/null 2>&1; then
    print_message "Docker verified with hello-world container." "${GREEN}"
else
    print_message "Docker verification failed." "${RED}"
    exit 1
fi

# Step 4: Install CasaOS
print_message "Installing CasaOS..." "${YELLOW}"
if curl -fsSL https://get.casaos.io | bash; then
    print_message "CasaOS installed successfully." "${GREEN}"
else
    print_message "Failed to install CasaOS." "${RED}"
    exit 1
fi

# Step 5: Start and enable CasaOS service
print_message "Starting CasaOS service..." "${YELLOW}"
systemctl start casaos
systemctl enable casaos
if systemctl is-active --quiet casaos; then
    print_message "CasaOS service is running." "${GREEN}"
else
    print_message "Failed to start CasaOS service." "${RED}"
    exit 1
fi

# Step 6: Display access information
IP_ADDRESS=$(hostname -I | awk '{print $1}')
print_message "CasaOS installation complete!" "${GREEN}"
print_message "Access CasaOS at: http://${IP_ADDRESS}:80" "${YELLOW}"
print_message "Follow the web setup wizard to configure CasaOS." "${YELLOW}"
print_message "To check CasaOS status: sudo systemctl status casaos" "${YELLOW}"
print_message "To update CasaOS: sudo casaos-upgrade" "${YELLOW}"

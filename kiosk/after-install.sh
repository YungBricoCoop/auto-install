#!/bin/sh

# Install Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Docker has been installed successfully."


# Create deployment info file
DEPLOYMENT_INFO_FILE="/etc/deployment-info.txt"

DEPLOYMENT_TIME=$(date)

echo "System deployed on: $DEPLOYMENT_TIME" | sudo tee $DEPLOYMENT_INFO_FILE > /dev/null

sudo chmod 644 $DEPLOYMENT_INFO_FILE

echo "Deployment info written to $DEPLOYMENT_INFO_FILE"

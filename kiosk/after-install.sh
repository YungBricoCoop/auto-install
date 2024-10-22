#!/bin/sh

DEPLOYMENT_INFO_FILE="/etc/deployment-info.txt"
DEPLOYMENT_TIME=$(date)

KIOSK_USER="curious-otter"
KIOSK_URL="https://help.ubuntu.com/"

ACCOUNT_SERVICE_BASE_PATH="/var/lib/AccountsService/users"
ACCOUNT_SERVICE_PATH="/var/lib/AccountsService/users/$KIOSK_USER"

GDM_CUSTOM_PATH="/etc/gdm3/custom.conf"

AUTOSTART_DIR_PATH="/home/$KIOSK_USER/.config/openbox"
AUTOSTART_PATH="$AUTOSTART_DIR_PATH/autostart"

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

# Install Chrome
wget -P /tmp https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y /tmp/google-chrome-stable_current_amd64.deb
sudo apt --fix-broken install -y

# Setup kiosk mode
echo "Setting up kiosk mode..."
sudo mkdir -p $ACCOUNT_SERVICE_BASE_PATH
sudo tee $ACCOUNT_SERVICE_PATH > /dev/null << EOF
[User]
XSession=openbox
EOF

sudo tee -a $GDM_CUSTOM_PATH > /dev/null << EOF
[daemon]
AutomaticLoginEnable = true
AutomaticLogin = $KIOSK_USER
EOF

# Ensure home directory exists
if [ ! -d "/home/$KIOSK_USER" ]; then
    echo "Home directory for $KIOSK_USER not found. Creating it..."
    sudo mkhomedir_helper $KIOSK_USER
fi

# Create Openbox folder and autostart file
sudo -u $KIOSK_USER mkdir -p $AUTOSTART_DIR_PATH
sudo -u $KIOSK_USER tee $AUTOSTART_PATH > /dev/null << EOF
# Disable screen saver and power management
xset s off
xset s noblank
xset -dpms

# Start Google Chrome in kiosk mode
google-chrome --no-first-run --kiosk --disable-restore-session-state '$KIOSK_URL' &
EOF

# Create deployment info file
echo "System deployed on: $DEPLOYMENT_TIME" | sudo tee $DEPLOYMENT_INFO_FILE > /dev/null
sudo chmod 644 $DEPLOYMENT_INFO_FILE
echo "Deployment info written to $DEPLOYMENT_INFO_FILE"

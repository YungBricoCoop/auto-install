#!/bin/bash

DEPLOYMENT_INFO_FILE="/etc/deployment-info.txt"
DEPLOYMENT_TIME=$(date)

KIOSK_USER="curious-otter"
KIOSK_URL="https://help.ubuntu.com/"

ACCOUNT_SERVICE_BASE_PATH="/var/lib/AccountsService/users"
ACCOUNT_SERVICE_PATH="/var/lib/AccountsService/users/$KIOSK_USER"

GDM_CUSTOM_PATH="/etc/gdm3/custom.conf"

AUTOSTART_DIR_PATH="/home/$KIOSK_USER/.config/openbox"
AUTOSTART_PATH="$AUTOSTART_DIR_PATH/autostart"

log_step() {
    local message="$1"
    echo "$message" | sudo tee -a $DEPLOYMENT_INFO_FILE > /dev/null
}

log_error() {
    local message="$1"
    echo "ERROR: $message" | sudo tee -a $DEPLOYMENT_INFO_FILE > /dev/null
}

echo "Deployment started on: $DEPLOYMENT_TIME" | sudo tee $DEPLOYMENT_INFO_FILE > /dev/null
sudo chmod 644 $DEPLOYMENT_INFO_FILE

while ! id $KIOSK_USER &> /dev/null; do
  log_step "Waiting for $KIOSK_USER user to be created..."
  sleep 1
done

log_step "Disabling after install service..."
if sudo systemctl disable post-install-setup.service && \
  sudo rm /etc/systemd/system/post-install-setup.service && \
  sudo rm /usr/local/bin/setup-post-install.sh; then
   log_step "After install service disabled successfully."
else
   log_error "Failed to disable after install service."
fi

log_step "Installing Docker..."

if sudo apt-get update && \
   sudo apt-get install -y ca-certificates curl && \
   sudo install -m 0755 -d /etc/apt/keyrings && \
   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
   sudo chmod a+r /etc/apt/keyrings/docker.asc && \
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
   sudo apt-get update && \
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    log_step "Docker has been installed successfully."
else
    log_error "Docker installation failed."
fi

log_step "Installing Google Chrome..."

if wget -P /tmp https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
   sudo apt install -y /tmp/google-chrome-stable_current_amd64.deb && \
   sudo apt --fix-broken install -y; then
    log_step "Google Chrome installed successfully."
else
    log_error "Google Chrome installation failed."
fi

log_step "Setting up kiosk mode..."

if sudo mkdir -p $ACCOUNT_SERVICE_BASE_PATH && \
   sudo tee $ACCOUNT_SERVICE_PATH > /dev/null << EOF
[User]
XSession=openbox
EOF
then
    log_step "AccountService for $KIOSK_USER created successfully."
else
    log_error "Failed to create AccountService for $KIOSK_USER."
fi

if sudo tee -a $GDM_CUSTOM_PATH > /dev/null << EOF
[daemon]
AutomaticLoginEnable = true
AutomaticLogin = $KIOSK_USER
EOF
then
    log_step "GDM automatic login setup successfully."
else
    log_error "Failed to setup GDM automatic login."
fi

log_step "Setting up Openbox autostart..."

if sudo -u $KIOSK_USER mkdir -p $AUTOSTART_DIR_PATH && \
   sudo -u $KIOSK_USER tee $AUTOSTART_PATH > /dev/null << EOF
# Disable screen saver and power management
xset s off
xset s noblank
xset -dpms

# Start Google Chrome in kiosk mode
google-chrome --no-first-run --kiosk --disable-restore-session-state '$KIOSK_URL' &
EOF
then
    log_step "Openbox autostart setup successfully."
else
    log_error "Failed to setup Openbox autostart."
fi

log_step "System deployed successfully on: $DEPLOYMENT_TIME"

sudo reboot

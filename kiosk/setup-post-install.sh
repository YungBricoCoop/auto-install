#!/bin/bash

SERVICE_NAME="post-install-setup.service"
AFTER_INSTALL_SCRIPT="/usr/local/bin/after-install.sh"

echo "Downloading after-install.sh script..."
curl -o $AFTER_INSTALL_SCRIPT https://raw.githubusercontent.com/YungBricoCoop/auto-install/refs/heads/main/kiosk/after-install.sh
chmod +x $AFTER_INSTALL_SCRIPT

echo "Creating systemd service $SERVICE_NAME..."
cat << EOF > /etc/systemd/system/$SERVICE_NAME
[Unit]
Description=Run post-install setup script after user brave-penguin is created
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$AFTER_INSTALL_SCRIPT
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "Enabling systemd service $SERVICE_NAME..."
systemctl enable $SERVICE_NAME

echo "Systemd service $SERVICE_NAME is enabled and will run on the next boot."

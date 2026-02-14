#!/bin/bash
set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- INSTALL LOGIC ---

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   MTHAN APP INSTALLER${NC}"
echo -e "${BLUE}============================================${NC}"

# Check root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This installer must be run as root.${NC}"
  exit 1
fi

echo "Checking and installing dependencies..."
if [ -f /etc/debian_version ]; then
    apt-get update && apt-get install -y git curl
elif [ -f /etc/redhat-release ]; then
    dnf install -y git curl || yum install -y git curl
elif [ -f /etc/arch-release ]; then
    pacman -Sy --noconfirm git curl
fi

# 0. Cleanup old versions and migration
echo "Cleaning up old Root Panel versions..."

# Backup config if exists (legacy or modern)
CONFIG_BACKUP="/tmp/mthan_config_backup.yaml"
if [ -f "/root/.mthan/root/config.yaml" ]; then
    cp "/root/.mthan/root/config.yaml" "$CONFIG_BACKUP"
elif [ -f "/root/.mthan/vps/config.yaml" ]; then
    cp "/root/.mthan/vps/config.yaml" "$CONFIG_BACKUP"
fi

# Stop and cleanup legacy service if exists
if systemctl is-active --quiet mthan-vps.service; then
    echo "Stopping legacy mthan-vps service..."
    systemctl stop mthan-vps.service || true
    systemctl disable mthan-vps.service || true
    rm -f /etc/systemd/system/mthan-vps.service
fi

# Delete old folders
rm -rf /root/.mthan
rm -f /etc/systemd/system/mthan-user@.service

# 1. Create target directory
echo "Creating directory /root/.mthan/root..."
mkdir -p /root/.mthan/root/data
mkdir -p /root/.mthan/root/logging
mkdir -p /root/.mthan/root/modules

# Restore config if backup exists
if [ -f "$CONFIG_BACKUP" ]; then
    mv "$CONFIG_BACKUP" /root/.mthan/root/config.yaml
fi

# 2. Download binaries and scripts
echo "Downloading Root Panel from mthan-public..."
BASE_URL="https://raw.githubusercontent.com/antoine-mai/mthan-public/main"

# Download Root Binary
wget -q "$BASE_URL/bin/root" -O /root/.mthan/root/app
# Download Uninstall Script
wget -q "$BASE_URL/uninstall.sh" -O /root/.mthan/root/uninstall.sh

chmod +x /root/.mthan/root/app
chmod +x /root/.mthan/root/uninstall.sh

# Note: User Panel (mthan-user) will be downloaded on-demand from the Root Panel UI

# 4. Create systemd service for Root Panel
echo "Configuring Root Panel service..."

cat <<EOF > /etc/systemd/system/mthan-app.service
[Unit]
Description=MTHAN APP Root Panel
After=network.target

[Service]
ExecStart=/root/.mthan/root/app
WorkingDirectory=/root/.mthan/root
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Note: User Panel service template will be created when installing User Panel from UI

# 5. Start Root Panel service
echo "Starting Root Panel..."
systemctl daemon-reload
systemctl enable mthan-app.service

if systemctl is-active --quiet mthan-app.service; then
    echo "Restarting mthan-app.service..."
    systemctl restart mthan-app.service
else
    echo "Starting mthan-app.service..."
    systemctl start mthan-app.service
fi

# 6. Generate/Read config and show message
CONFIG_FILE="/root/.mthan/root/config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Generating default configuration..."
    PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')
    echo "port: 2205" > "$CONFIG_FILE"
    echo "username: root" >> "$CONFIG_FILE"
    echo "password: $PASSWORD" >> "$CONFIG_FILE"
    echo "hostname: localhost" >> "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
fi

# Read current credentials
USERNAME=$(grep "username:" "$CONFIG_FILE" | cut -d' ' -f2)
PASSWORD=$(grep "password:" "$CONFIG_FILE" | cut -d' ' -f2)
PORT=$(grep "port:" "$CONFIG_FILE" | cut -d' ' -f2)

# Improved IP detection (Force IPv4)
IP=$(curl -s -4 https://ifconfig.me || curl -s -4 https://api.ipify.org || echo "YOUR_SERVER_IP")

# 6. Configure Firewall
echo "Configuring firewall..."
if command -v ufw >/dev/null; then
    if ufw status | grep -q "Status: active"; then
        echo "Opening port $PORT in UFW..."
        ufw allow "$PORT/tcp"
    fi
elif command -v firewall-cmd >/dev/null; then
    echo "Opening port $PORT in firewalld..."
    firewall-cmd --permanent --add-port="$PORT/tcp"
    firewall-cmd --reload
fi

echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}   INSTALLATION COMPLETE${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "URL:        http://${IP}:${PORT}"
echo -e "Username:   $USERNAME"
echo -e "Password:   $PASSWORD"
echo -e "To uninstall, run: /root/.mthan/root/uninstall.sh"
echo -e "IMPORTANT: Ensure port ${PORT} is open in your cloud firewall (e.g., AWS/GCP/Azure console).\n"

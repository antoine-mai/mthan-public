#!/bin/bash
set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- UNINSTALL LOGIC ---
if [ "$1" == "--uninstall" ]; then
    echo -e "${RED}Uninstalling MTHAN VPS...${NC}"
    
    if systemctl is-active --quiet mthan-vps.service; then
        echo "Stopping service..."
        systemctl stop mthan-vps.service
    fi
    
    if [ -f /etc/systemd/system/mthan-vps.service ]; then
        echo "Disabling and removing service..."
        systemctl disable mthan-vps.service
        rm /etc/systemd/system/mthan-vps.service
        systemctl daemon-reload
    fi
    
    echo "Removing application binary..."
    rm -f /root/.mthan/vps/app
    
    # Optional: Purge data?
    # rm -rf /root/.mthan/vps/data
    
    echo -e "${GREEN}MTHAN VPS has been uninstalled.${NC}"
    exit 0
fi

# --- INSTALL LOGIC ---

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   MTHAN VPS INSTALLER${NC}"
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

# 1. Create target directory
echo "Creating directory /root/.mthan/vps..."
mkdir -p /root/.mthan/vps/data
mkdir -p /root/.mthan/vps/modules

# 2. Clone app from public repo
echo "Cloning repository from mthan-public..."
TEMP_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/antoine-mai/mthan-public "$TEMP_DIR"

# 3. Move vps/app to /root/.mthan/vps
echo "Installing application binary..."
if [ ! -f "$TEMP_DIR/vps/app" ]; then
    echo -e "${RED}Error: vps/app binary not found in repository.${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

mv "$TEMP_DIR/vps/app" /root/.mthan/vps/app
cp "$TEMP_DIR/vps/install.sh" /root/.mthan/vps/uninstall.sh
chmod +x /root/.mthan/vps/app
chmod +x /root/.mthan/vps/uninstall.sh

# Cleanup clone
rm -rf "$TEMP_DIR"

# 4. Create systemd service
echo "Configuring systemd service..."
cat <<EOF > /etc/systemd/system/mthan-vps.service
[Unit]
Description=MTHAN VPS
After=network.target

[Service]
ExecStart=/root/.mthan/vps/app
WorkingDirectory=/root/.mthan/vps
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 5. Reload daemon and handle service start/restart
echo "Applying service changes..."
systemctl daemon-reload
systemctl enable mthan-vps.service

if systemctl is-active --quiet mthan-vps.service; then
    echo "Restarting mthan-vps.service..."
    systemctl restart mthan-vps.service
else
    echo "Starting mthan-vps.service..."
    systemctl start mthan-vps.service
fi
# 6. Generate/Read config and show message
CONFIG_FILE="/root/.mthan/vps/config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Generating default configuration..."
    PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')
    echo "port: 2205" > "$CONFIG_FILE"
    echo "username: root" >> "$CONFIG_FILE"
    echo "password: $PASSWORD" >> "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
fi

# Read current credentials
USERNAME=$(grep "username:" "$CONFIG_FILE" | cut -d' ' -f2)
PASSWORD=$(grep "password:" "$CONFIG_FILE" | cut -d' ' -f2)
PORT=$(grep "port:" "$CONFIG_FILE" | cut -d' ' -f2)

# Improved IP detection (Force IPv4)
IP=$(curl -s -4 https://ifconfig.me || curl -s -4 https://api.ipify.org || echo "YOUR_SERVER_IP")

echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}   INSTALLATION COMPLETE${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "URL:        http://${IP}:${PORT}"
echo -e "Username:   $USERNAME"
echo -e "Password:   $PASSWORD"
echo -e "To uninstall, run: /root/.mthan/vps/uninstall.sh --uninstall"
echo -e "IMPORTANT: Ensure port ${PORT} is open in your cloud firewall.\n"

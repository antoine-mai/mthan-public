#!/bin/bash
set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${RED}Uninstalling MTHAN VPS...${NC}"

# Check root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run as root.${NC}"
  exit 1
fi

# Detect port from config
CONFIG_FILE="/root/.mthan/vps/config.yaml"
PORT=2205
if [ -f "$CONFIG_FILE" ]; then
    PORT=$(grep "port:" "$CONFIG_FILE" | cut -d' ' -f2)
fi

# Cleanup Firewall
echo "Cleaning up firewall rules..."
if command -v ufw >/dev/null; then
    if ufw status | grep -q "Status: active"; then
        echo "Closing port $PORT in UFW..."
        ufw delete allow "$PORT/tcp"
    fi
elif command -v firewall-cmd >/dev/null; then
    echo "Closing port $PORT in firewalld..."
    firewall-cmd --permanent --remove-port="$PORT/tcp"
    firewall-cmd --reload
fi

# Stop and disable main service
if systemctl is-active --quiet mthan-vps.service; then
    echo "Stopping mthan-vps service..."
    systemctl stop mthan-vps.service
fi
if [ -f /etc/systemd/system/mthan-vps.service ]; then
    echo "Removing mthan-vps service..."
    systemctl disable mthan-vps.service
    rm /etc/systemd/system/mthan-vps.service
fi

# Stop all user services
echo "Stopping all user panel services..."
systemctl stop "mthan-user@*.service" || true

# Remove user service template
if [ -f /etc/systemd/system/mthan-user@.service ]; then
    echo "Removing mthan-user template service..."
    rm /etc/systemd/system/mthan-user@.service
fi

systemctl daemon-reload

echo "Removing application binaries and data..."
rm -f /usr/local/bin/mthan-user

# Remove the entire .mthan directory
if [ -d /root/.mthan ]; then
    echo "Removing /root/.mthan directory..."
    rm -rf /root/.mthan
fi

echo -e "${GREEN}MTHAN VPS has been uninstalled.${NC}"

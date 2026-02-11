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

# Remove user service template
if [ -f /etc/systemd/system/mthan-user@.service ]; then
    echo "Removing mthan-user template service..."
    rm /etc/systemd/system/mthan-user@.service
fi

systemctl daemon-reload

echo "Removing application binaries and data..."
rm -f /root/.mthan/vps/app
rm -f /root/.mthan/vps/user
rm -f /root/.mthan/vps/uninstall.sh

# Optional: Keep config and logs for now, or purge?
# rm -rf /root/.mthan/vps

echo -e "${GREEN}MTHAN VPS has been uninstalled.${NC}"

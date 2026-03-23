# MTHAN VPS Platform

A lightweight and high-performance management panel for Linux infrastructure.

## Installation

Run this command on a fresh Ubuntu, Debian, CentOS, or Arch server:

```bash
curl -sSL https://raw.githubusercontent.com/antoine-mai/mthan-vps/main/install.sh | bash
```
*(Warning: This performs a clean install and overwrites any existing `/root/.mthan/` data)*

### Access Link
*   **URL**: `http://YOUR_SERVER_IP:2205`
*   **Login**: Use your existing Linux system username & password.

## Maintenance

### Update/Repair
To update the core application or repair a corrupted installation (keeps your data intact):

```bash
curl -sSL https://raw.githubusercontent.com/antoine-mai/mthan-vps/main/install.sh | bash -s -- --repair
```

### Uninstallation
Completely remove the platform:

```bash
sudo /root/.mthan/vps/uninstall.sh
```
# MTHAN VPS

A lightweight, modern VPS management panel designed for simplicity and performance.

## 🚀 Speed Installation

Run the following command as **root** to install MTHAN VPS on your server:

```bash
curl -sSL https://raw.githubusercontent.com/antoine-mai/mthan-public/main/vps/install.sh | bash
```

### What happens during installation?
- Dependencies checks (git, curl)
- Core binaries installation to `/root/.mthan/vps/`
- Systemd service configuration (`app.service`)
- Automatic firewall configuration (UFW/Firewalld/Iptables)
- Default credentials generation

## 🖥️ Accessing the Panel

Once installed, you can access the panel at:
- **URL**: `http://YOUR_SERVER_IP:2205`
- **Default Username**: `root`
- **Password**: (Displayed at the end of installation)

## 🛠️ Management

### Service Control
```bash
# Start service
systemctl start app.service

# Stop service
systemctl stop app.service

# Check logs
journalctl -u app.service -f
```

### Uninstallation
To completely remove MTHAN VPS from your system, run:
```bash
/root/.mthan/vps/uninstall.sh --uninstall
```

## 🔒 Security
- Runs as a systemd service.
- Strict Root enforcement in production.
- Isolated home directories for managed users.
- Automated config protection (600 permissions).
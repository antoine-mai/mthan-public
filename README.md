# 🚀 MTHAN VPS Ecosystem

Welcome to the **MTHAN Public** repository – the official distribution hub for MTHAN cloud management tools. Our mission is to provide high-performance, beautifully designed, and developer-friendly infrastructure solutions.

---

## 💎 MTHAN VPS (Control Panel)

MTHAN VPS is a lightweight yet ultra-modern management panel for Linux servers. Built with a focus on speed, aesthetics, and simplicity, it provides everything you need to manage your server environment with ease.

### ✨ Key Features
- **Modern UI/UX**: Premium design with full Dark/Light mode support.
- **Unified Management**: Control your apps, users, and server services from a single hub.
- **User Ecosystem**: Native support for independent User Panels with isolated environments.
- **One-Command Setup**: Zero-configuration installation process.

### 🚀 Quick Start
Install MTHAN VPS on any clean Linux server (**Ubuntu/Debian/CentOS**) by running:

```bash
curl -sSL https://raw.githubusercontent.com/antoine-mai/mthan-public/main/vps/install.sh | bash
```

### 🖥️ Accessing the Control Panel
- **URL**: `http://YOUR_SERVER_IP:2205`
- **Port**: `2205` (Default)
- **Security**: Root-level access required for administration.

---

## 👥 MTHAN User Panel (Client Access)

Starting with Version 1.0.6, the ecosystem includes a dedicated **User Application**. This allows server administrators to provide a restricted, specialized management interface for their clients.

- **Isolation**: Runs under individual user accounts.
- **Portability**: Built into the same lightweight binary architecture.
- **Automatic Setup**: Managed directly through the main Control Panel.

---

## 🛠️ Maintenance & Uninstallation

To update your installation, simply run the installer command again. To completely remove MTHAN VPS and all associated services:

```bash
/root/.mthan/vps/uninstall.sh --uninstall
```

---

## 🔒 Security & Standards
- **Binary Integrity**: All binaries are compiled from source and distributed via this secure channel.
- **Standardized Paths**: Application data and configurations are consistently managed under `/root/.mthan/`.
- **Minimal Footprint**: Optimized performance for low-resource VPS environments.

---

&copy; 2025 MTHAN. Built with ❤️ for the cloud community.
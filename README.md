# MTHAN Public Repository

Welcome to the **MTHAN Public** repository. This is an open collection of tools and applications managed by MTHAN.

## 📦 Available Projects

### 1. MTHAN VPS (Management Panel)
A lightweight, modern VPS management panel designed for simplicity and performance. All VPS-related files are located in the `/vps` directory.

#### 🚀 Fast Installation
Run the following command as **root** to install MTHAN VPS:
```bash
curl -sSL https://raw.githubusercontent.com/antoine-mai/mthan-public/main/vps/install.sh | bash
```

#### 🖥️ Accessing the Panel
- **URL**: `http://YOUR_SERVER_IP:2205`
- **Default Username**: `root`
- **Default Password**: (Generated at end of installation)

#### 🛠️ Uninstallation
To completely remove MTHAN VPS:
```bash
/root/.mthan/vps/uninstall.sh --uninstall
```

---

## 🏗️ Future Projects
More tools and modules will be added to this repository soon. Stay tuned!

## 🔒 Security & Standards
- All binaries provided here are built from verified source code.
- Official configuration paths are under `/root/.mthan/`.
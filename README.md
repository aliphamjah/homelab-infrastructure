# 🏠 Home Lab Infrastructure

> Personal development environment with Docker, WSL2, and automation scripts

[![Status](https://img.shields.io/badge/status-production-green)]()
[![Platform](https://img.shields.io/badge/platform-WSL2%20%2B%20Windows%2011-blue)]()
[![Docker](https://img.shields.io/badge/docker-27.3.1-blue)]()

---

## 📋 Overview

This repository contains the complete infrastructure setup for my personal home lab running on:
- **Hardware**: Lenovo ThinkPad T14 Gen 2 (AMD Ryzen 7 PRO 5850U, 32GB RAM, 1TB SSD)
- **Host OS**: Windows 11 Pro
- **Container Platform**: WSL2 (Ubuntu 22.04 LTS) + Docker Engine
- **Services**: 13 containerized services with 3 workload profiles

---

## 🚀 Quick Start

### Prerequisites
- Windows 11 with WSL2 enabled
- Ubuntu 22.04 LTS installed
- Docker Engine (native in WSL2)

### Installation
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/homelab-infrastructure.git
cd homelab-infrastructure

# Setup aliases
cat infrastructure/scripts/aliases.sh >> ~/.bashrc
source ~/.bashrc

# Start minimal profile
start-minimal
```

---

## 📚 Documentation

- **[MASTER.md](MASTER.md)** - Complete reference documentation
- **[QUICKREF.md](QUICKREF.md)** - Quick command reference
- **[CHANGELOG.md](CHANGELOG.md)** - Version history
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues & solutions

---

## 🎯 Service Profiles

### Minimal (4GB RAM)
```bash
start-minimal
```
- PostgreSQL 16
- Redis 7
- pgAdmin, Redis Commander

### Backend (8GB RAM)
```bash
start-backend
```
Minimal + MongoDB, Kafka, Zookeeper, Admin UIs

### Fullstack (14GB RAM)
```bash
start-fullstack
```
Backend + Elasticsearch, Kibana, Nginx

---

## 🔧 Scripts & Aliases

### Service Management
- `start-minimal` - Start minimal profile
- `start-backend` - Start backend profile
- `start-fullstack` - Start fullstack profile
- `stop-lab` - Stop all services (100% cleanup)

### Monitoring
- `lab-status` - Quick status check
- `lab-health` - Detailed health check
- `lab-logs` - View logs

### Maintenance
- `lab-cleanup` - Remove unused resources
- `lab-backup` - Backup all databases

See [MASTER.md](MASTER.md) for complete list.

---

## 📂 Project Structure
```
.
├── infrastructure/
│   ├── docker/
│   │   ├── compose/          # Docker Compose files
│   │   └── images/           # Custom Dockerfiles
│   ├── scripts/              # Automation scripts (11 scripts)
│   ├── configs/              # Service configurations
│   └── secrets/              # Secrets (gitignored)
├── projects/                 # Source code projects
├── docs/                     # Extended documentation
├── templates/                # Project templates
├── MASTER.md                 # Master reference doc
├── QUICKREF.md               # Quick reference
└── CHANGELOG.md              # Version history
```

---

## 🔐 Security Notes

- All secrets are gitignored (see `.gitignore`)
- Credentials stored locally in `CREDENTIALS.md` (not in repo)
- Private repository recommended
- Use SSH keys for Git authentication

---

## 📊 System Status

**Last Updated**: 2025-10-28

| Component | Status | Notes |
|-----------|--------|-------|
| Scripts | ✅ Operational | 11/11 working (100% reliability) |
| Services | ✅ Operational | All profiles tested |
| Memory | ✅ Optimal | 740Mi idle / 19Gi total |
| Cleanup | ✅ Verified | 0 containers after stop |

---

## 🛠️ Maintenance

### Daily
- Start/stop services as needed
- Check status: `lab-status`

### Weekly
- Run cleanup: `lab-cleanup`
- Check disk space: `df -h`

### Monthly
- Full maintenance: `maintenance.sh`
- Backup databases: `lab-backup`
- Update images (if needed)

---

## 📝 License

Private - Personal Use Only

---

## 👤 Author

**Your Name**
- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)

---

**Last Updated**: October 28, 2025

---
title: "Home Lab Infrastructure - Master Reference"
version: "1.0.0"
last_updated: "2025-10-28"
status: "Production Ready"
---

# 🏠 HOME LAB INFRASTRUCTURE - COMPLETE REFERENCE

> **Critical**: This document is the SINGLE SOURCE OF TRUTH for the entire home lab setup.
> Always check this document first before making any changes.

---

## 📋 TABLE OF CONTENTS

1. [Quick Start](#quick-start)
2. [Hardware Specifications](#hardware-specifications)
3. [Software Stack](#software-stack)
4. [Directory Structure](#directory-structure)
5. [Service Profiles](#service-profiles)
6. [Scripts & Aliases](#scripts--aliases)
7. [Port Allocation](#port-allocation)
8. [Daily Workflows](#daily-workflows)
9. [Troubleshooting](#troubleshooting)
10. [Maintenance Schedule](#maintenance-schedule)

---

## 🚀 QUICK START

### Start Services
```bash
# From anywhere (aliases setup in ~/.bashrc)
start-minimal        # PostgreSQL + Redis (4GB RAM)
start-backend        # + MongoDB + Kafka (8GB RAM)
start-fullstack      # + Elasticsearch + Nginx (14GB RAM)
```

### Check Status
```bash
lab-status          # Quick overview
lab-health          # Detailed health check
```

### Stop Services
```bash
stop-lab            # Complete cleanup (0 containers remaining)
```

---

## 💻 HARDWARE SPECIFICATIONS

### Laptop
- **Model**: Lenovo ThinkPad T14 Gen 2 (2021)
- **CPU**: AMD Ryzen 7 PRO 5850U (8c/16t, Zen 3)
  - Base: 1.9 GHz | Boost: 4.4 GHz
  - TDP: 15W nominal (10-25W configurable)
  - Thermal throttle: ~85-88°C
- **RAM**: 32GB DDR4-3200 (SOLDERED - non-upgradeable)
  - WSL2 allocation: 20GB (via .wslconfig)
  - Windows baseline: 8-10GB
  - Reserve: 2GB minimum
- **Storage**: 1TB NVMe PCIe 3.0
  - C: 238GB (Windows + System)
  - D: 400GB (WSL2 + Docker)
  - E: 315GB (Projects + Data)
- **Age**: Purchased Oct 2025 (4 years old)
- **Target Lifespan**: 5 years (until 2030)

### Critical Constraints
- ❌ **Cannot add more RAM** (soldered)
- ❌ **Max sustained load**: 50-70% for 2-4 hours
- ❌ **Thermal limit**: 85-88°C (throttles above)
- ✅ **Optimal**: Resource-aware profiles (minimal/backend/fullstack)

---

## 🗂️ SOFTWARE STACK

### Host OS
- **OS**: Windows 11 Pro 64-bit (Build 22631+)
- **Purpose**: Native Microsoft 365, Power BI Desktop
- **Optimization**: Startup bloatware removed, services optimized

### WSL2
- **Distribution**: Ubuntu 22.04.5 LTS
- **Kernel**: 6.6.87.2-microsoft-standard-WSL2
- **Architecture**: x86_64
- **Installation Date**: 2025-10-24

### WSL2 Configuration (.wslconfig)
```ini
[wsl2]
memory=20GB
processors=6
swap=8GB
swapFile=C:\\temp\\wsl-swap.vhdx
localhostForwarding=true
nestedVirtualization=true
pageReporting=false

[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
hostAddressLoopback=true
```

### Docker
- **Type**: Docker Engine (native in WSL2)
- **Version**: 27.3.1
- **Compose**: v2.27.1
- **Installation Date**: 2025-10-24
- **Storage Driver**: overlay2
- **Data Root**: /var/lib/docker
- **Networks**: dev-network, kafka-network, monitoring-network

---

## 📁 DIRECTORY STRUCTURE
```
~/development/                          # /mnt/e/development
├── README.md
├── MASTER.md                          # This file
├── QUICKREF.md
├── CREDENTIALS.md
├── CHANGELOG.md
│
├── infrastructure/
│   ├── docker/
│   │   ├── compose/
│   │   │   └── docker-compose.yml     # Main compose file (NO version line)
│   │   ├── images/                    # Custom Dockerfiles
│   │   └── volumes/                   # Volume mount points (gitignored)
│   │
│   ├── kubernetes/                    # K8s manifests (future)
│   │
│   ├── scripts/                       # Automation scripts
│   │   ├── start-lab.sh              # Start services by profile
│   │   ├── stop-lab.sh               # Stop & cleanup (100% reliable)
│   │   ├── status-lab.sh             # Quick status
│   │   ├── health-check.sh           # Detailed health check
│   │   ├── db-helper.sh              # Database utilities
│   │   ├── logs.sh                   # Log management
│   │   ├── backup-databases.sh       # Backup automation
│   │   ├── cleanup.sh                # Resource cleanup
│   │   ├── maintenance.sh            # Weekly maintenance
│   │   └── test-all.sh               # Comprehensive testing
│   │
│   ├── configs/                      # Service configurations
│   │   ├── nginx/
│   │   ├── prometheus/
│   │   └── grafana/
│   │
│   └── secrets/                      # Secrets (GITIGNORED!)
│       ├── .env.databases
│       └── .env.services
│
├── projects/                         # Source code
│   ├── go/
│   ├── rust/
│   ├── typescript/
│   ├── python/
│   └── php/
│
├── data/                             # Persistent data (GITIGNORED!)
│   ├── postgres/
│   ├── mongo/
│   ├── redis/
│   └── backups/
│
├── docs/                             # Documentation
│   ├── setup/
│   ├── maintenance/
│   ├── guides/
│   └── learnings/
│
└── templates/                        # Project templates
```

---

## 🎯 SERVICE PROFILES

### Minimal Profile (4GB WSL2)
**Services**:
- PostgreSQL 16 (port 5432)
- Redis 7 (port 6379)
- pgAdmin (port 5050)
- Redis Commander (port 8082)

**Use Cases**:
- Simple CRUD development
- SQL learning
- Basic backend work
- Office work + light coding

**Command**: `start-minimal`

---

### Backend Profile (8GB WSL2)
**Services**: Minimal +
- MongoDB 7 (port 27017)
- Kafka (port 9092)
- Zookeeper (port 2181)
- Mongo Express (port 8081)
- Kafka UI (port 8090)

**Use Cases**:
- API development
- Microservices practice
- Event-driven architecture
- Full backend development

**Command**: `start-backend`

---

### Fullstack Profile (14GB WSL2)
**Services**: Backend +
- Elasticsearch (port 9200)
- Kibana (port 5601)
- Nginx (port 80/443)

**Use Cases**:
- Full application development
- Production-like testing
- Search & analytics
- Complete stack learning

**Command**: `start-fullstack`

---

## 🔧 SCRIPTS & ALIASES

### Aliases (defined in ~/.bashrc)

#### Navigation
```bash
alias dev='cd /mnt/e/development'
alias scripts='cd /mnt/e/development/infrastructure/scripts'
alias compose='cd /mnt/e/development/infrastructure/docker/compose'
```

#### Service Management
```bash
alias start-minimal='/mnt/e/development/infrastructure/scripts/start-lab.sh minimal'
alias start-backend='/mnt/e/development/infrastructure/scripts/start-lab.sh backend'
alias start-fullstack='/mnt/e/development/infrastructure/scripts/start-lab.sh fullstack'
alias stop-lab='/mnt/e/development/infrastructure/scripts/stop-lab.sh'
alias lab-status='/mnt/e/development/infrastructure/scripts/status-lab.sh'
alias lab-health='/mnt/e/development/infrastructure/scripts/health-check.sh'
```

#### Database Shortcuts
```bash
alias pg-shell='/mnt/e/development/infrastructure/scripts/db-helper.sh postgres shell'
alias redis-shell='/mnt/e/development/infrastructure/scripts/db-helper.sh redis shell'
alias mongo-shell='/mnt/e/development/infrastructure/scripts/db-helper.sh mongo shell'
```

#### Logs
```bash
alias lab-logs='/mnt/e/development/infrastructure/scripts/logs.sh view'
alias lab-errors='/mnt/e/development/infrastructure/scripts/logs.sh errors'
```

#### Maintenance
```bash
alias lab-cleanup='/mnt/e/development/infrastructure/scripts/cleanup.sh'
alias lab-backup='/mnt/e/development/infrastructure/scripts/backup-databases.sh'
```

### Script Behaviors

#### start-lab.sh
- Auto-stops existing containers
- Starts selected profile
- Shows service URLs
- Returns status

#### stop-lab.sh (100% Reliable)
1. Attempts `docker compose kill + down`
2. Force stops remaining containers
3. Force removes all containers
4. Verifies 0 containers remaining
5. Preserves data volumes

#### health-check.sh
- Checks Docker daemon
- Lists container status
- Tests service connectivity (PostgreSQL, Redis, MongoDB)
- Shows resource usage (memory, disk)
- Shows active ports

---

## 🔌 PORT ALLOCATION

### Databases
- PostgreSQL: 5432
- Redis: 6379
- MongoDB: 27017
- MySQL: 3306 (optional)

### Message Queues
- Kafka Broker 1: 9092
- Kafka Broker 2: 9093 (cluster)
- Kafka Broker 3: 9094 (cluster)
- Zookeeper: 2181
- Kafka UI: 8090

### Search & Analytics
- Elasticsearch: 9200
- Elasticsearch Transport: 9300
- Kibana: 5601

### Web Servers
- Nginx HTTP: 80
- Nginx HTTPS: 443
- Apache: 8080 (alternative)

### Admin UIs
- pgAdmin: 5050
- Redis Commander: 8082
- Mongo Express: 8081

### Development Ports
- Go API: 8000
- Rust Service: 8001
- Python API: 8002
- Node.js: 3000
- React/Vite: 5173
- Vue/Vite: 5174
- Next.js: 3001
- Angular: 4200

### Kubernetes
- K3s API: 6443
- K3s Ingress HTTP: 30080
- K3s Ingress HTTPS: 30443

### Monitoring
- Prometheus: 9090
- Grafana: 3002
- Node Exporter: 9100
- cAdvisor: 8085

**Reserved Ranges**:
- Custom services: 8100-8199
- Testing: 9000-9099
- Temporary: 10000-10099
- Microservices: 8200-8299

---

## 📅 DAILY WORKFLOWS

### Morning Routine
```bash
# Start work
start-minimal

# Optional: Check health after 10 seconds
sleep 10 && lab-health

# Open browser UIs
# - pgAdmin: http://localhost:5050
# - Redis Commander: http://localhost:8082
```

### During Work
```bash
# Check status anytime
lab-status

# View logs if needed
lab-logs

# Switch profile if needed
stop-lab
start-backend
```

### Evening Routine
```bash
# Stop everything
stop-lab

# Optional: Shutdown WSL2 (frees all memory)
# In PowerShell: wsl --shutdown
```

---

## 🔧 TROUBLESHOOTING

### Services Not Accessible After Stop
**Cause**: Browser cache  
**Solution**: Hard refresh (Ctrl+Shift+R) or Incognito mode

### Containers Still Running After Stop
**Cause**: stop-lab.sh handles this automatically now  
**Solution**: Script has 3-step cleanup (compose down → force stop → force remove)

### Port Already in Use
**Check**: `sudo lsof -i :<port>`  
**Solution**: `sudo kill -9 <PID>` or `stop-lab`

### Memory Not Freed
**Solution**: `wsl --shutdown` (PowerShell as Admin)

### Health Check Errors
**Wait**: Containers need 10-15 seconds to be fully ready  
**Solution**: `sleep 10` after start before health check

---

## 🗓️ MAINTENANCE SCHEDULE

### Daily
- Start/stop services as needed
- Check `lab-status` occasionally

### Weekly
- Run `lab-cleanup` (removes unused images/volumes)
- Check disk space: `df -h`
- Review `lab-health` output

### Monthly
- Run full `maintenance.sh`
- Backup databases: `lab-backup`
- Update Docker images (if needed)
- Check SSD health (CrystalDiskInfo)

### Every 6 Months
- Clean laptop cooling system
- Check thermal paste condition
- Review and update documentation

---

## 🔐 CREDENTIALS

See `CREDENTIALS.md` for all passwords and access details.

**Default Credentials**:
- PostgreSQL: postgres / postgres
- Redis: homelab_redis_2025
- MongoDB: admin / homelab_mongo_2025
- pgAdmin: admin@homelab.local / admin

---

## 📊 CURRENT STATUS

**Last Verified**: 2025-10-28  
**System**: Operational ✅  
**Scripts**: All working (100% reliability) ✅  
**Memory**: Optimal (740Mi idle / 19Gi total) ✅  
**Containers**: Clean stop/start cycle verified ✅  

---

## 🚀 NEXT STEPS (Optional)

- [ ] Phase 9: Kubernetes (K3d) setup
- [ ] CI/CD pipeline
- [ ] Advanced monitoring (Prometheus + Grafana)
- [ ] Service mesh (Istio)
- [ ] First project development

---

**END OF MASTER DOCUMENT**

For questions, refer to:
- Quick commands: `QUICKREF.md`
- Troubleshooting: `TROUBLESHOOTING.md`
- Project docs: `/mnt/e/development/docs/`

# 🏠 Home Lab Infrastructure

> Personal development environment — Docker + WSL2 + automation scripts

[![Platform](https://img.shields.io/badge/platform-WSL2%20Ubuntu%2022.04-blue)]()
[![Docker](https://img.shields.io/badge/docker-27.3.1-blue)]()
[![Compose](https://img.shields.io/badge/compose-v2.27.1-blue)]()
[![Status](https://img.shields.io/badge/status-active-green)]()

---

## 📋 Overview

Infrastructure personal home lab yang berjalan di atas:

- **Hardware**: Lenovo ThinkPad T14 Gen 2 — AMD Ryzen 7 PRO 5850U, 32GB RAM, 1TB NVMe
- **Host OS**: Windows 11 Pro (corporate tools only)
- **Dev env**: WSL2 Ubuntu 22.04 LTS + Docker Engine 27.3.1 (native, bukan Docker Desktop)
- **Pendekatan**: Single `docker-compose.yml` dengan profile-based loading — start only what you need

---

## ⚡ Quick Start

```bash
# Clone
git clone git@github.com:aliphamjah/homelab-infrastructure.git
cd homelab-infrastructure

# Copy dan isi credentials
cp infrastructure/secrets/.env.databases.example infrastructure/docker/compose/.env
# Edit .env sesuai kebutuhan

# Start profile minimal (PostgreSQL + Redis)
docker compose -f infrastructure/docker/compose/docker-compose.yml --profile minimal up -d

# Cek status
docker compose -f infrastructure/docker/compose/docker-compose.yml ps
```

> **Tip:** Tambahkan alias di `~/.bashrc` agar tidak perlu ketik path panjang setiap saat.
> ```bash
> alias dc='docker compose -f /mnt/e/development/infrastructure/docker/compose/docker-compose.yml'
> ```

---

## 🚀 Service Profiles

Semua service dikelola via satu file compose dengan profiles. Prinsip: **mulai dari minimal, scale up sesuai kebutuhan.**

| Profile | Services | RAM | Command |
|---------|----------|-----|---------|
| `minimal` | PostgreSQL, Redis, pgAdmin, Redis Commander | ~4GB | `dc --profile minimal up -d` |
| `backend` | + MongoDB, Kafka (KRaft), Mongo Express, Kafka UI | ~8GB | `dc --profile backend up -d` |
| `fullstack` | + Elasticsearch, Kibana, Nginx | ~14GB | `dc --profile fullstack up -d` |
| `monitoring` | Prometheus, Grafana, Node Exporter, cAdvisor | ~3GB | `dc --profile monitoring up -d` |
| `kubernetes` | K3d cluster (2-3 nodes) + registry | ~12GB | `k3d cluster create dev-cluster --agents 2` |

> ⚠️ **RAM limit WSL2 = 20GB.** Jangan jalankan `fullstack` + `monitoring` + `kubernetes` sekaligus.

---

## 🔌 Port Reference

### Databases
| Service | Port |
|---------|------|
| PostgreSQL | 5432 |
| MongoDB | 27017 |
| Redis | 6379 |
| MySQL | 3306 |

### Message Queue
| Service | Port |
|---------|------|
| Kafka (KRaft) | 9092 |
| Kafka UI | 8090 |

> Kafka berjalan dalam **KRaft mode** (tanpa Zookeeper) sejak 2026-03-01.

### Web & Admin UI
| Service | Port |
|---------|------|
| pgAdmin | 5050 |
| Mongo Express | 8081 |
| Redis Commander | 8082 |
| Kibana | 5601 |
| Grafana | 3002 |
| Prometheus | 9090 |

### Projects
| Service | Port |
|---------|------|
| QR PDF Service | 8250 |
| Plane (project mgmt) | 8300 |

---

## 📖 Use Cases & Manual Guide

### 1. Backend API Development (Go / Node.js / Python)

Setup yang dibutuhkan: PostgreSQL + Redis.

```bash
# Start minimal profile
dc --profile minimal up -d

# Verifikasi koneksi
docker exec dev-postgres psql -U $POSTGRES_USER -c "\l"
docker exec dev-redis redis-cli ping

# Stop setelah selesai
dc --profile minimal down
```

**Connection strings:**
```
PostgreSQL : postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/$POSTGRES_DB
Redis      : redis://localhost:6379
```

---

### 2. Event-Driven / Microservices Development

Setup yang dibutuhkan: PostgreSQL + Redis + MongoDB + Kafka.

```bash
# Start backend profile
dc --profile backend up -d

# Cek Kafka siap
docker exec dev-kafka kafka-topics --bootstrap-server localhost:9092 --list

# Buat topic baru
docker exec dev-kafka kafka-topics \
  --bootstrap-server localhost:9092 \
  --create --topic my-topic \
  --partitions 3 --replication-factor 1

# Monitor via Kafka UI
open http://localhost:8090

# Stop setelah selesai
dc --profile backend down
```

---

### 3. Full Stack Development (dengan Search)

Setup yang dibutuhkan: semua backend + Elasticsearch + Kibana + Nginx.

```bash
# Start fullstack profile
dc --profile fullstack up -d

# Verifikasi Elasticsearch
curl http://localhost:9200/_cluster/health?pretty

# Buat index
curl -X PUT http://localhost:9200/my-index \
  -H 'Content-Type: application/json' \
  -d '{"settings": {"number_of_shards": 1}}'

# Monitor via Kibana
open http://localhost:5601

# Stop setelah selesai
dc --profile fullstack down
```

---

### 4. Monitoring & Observability

Bisa dijalankan bersama profile lain (standalone ~3GB).

```bash
# Start monitoring (bisa bersamaan dengan minimal/backend)
dc --profile minimal up -d
dc --profile monitoring up -d

# Dashboard tersedia di:
# Grafana   → http://localhost:3002  (admin / lihat .env)
# Prometheus → http://localhost:9090

# Cek metrics terkumpul
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[].health'

# Stop monitoring saja
dc --profile monitoring down
```

---

### 5. Database Admin via Web UI

```bash
# pgAdmin (PostgreSQL)
open http://localhost:5050
# Login: lihat .env → PGADMIN_EMAIL, PGADMIN_PASSWORD

# Mongo Express (MongoDB)
open http://localhost:8081
# Basic auth: lihat .env → ME_BASICAUTH_USERNAME, ME_BASICAUTH_PASSWORD

# Redis Commander
open http://localhost:8082
```

---

### 6. Database Backup

```bash
# Backup semua database sekaligus
bash infrastructure/scripts/backup-databases.sh

# Backup tersimpan di: data/backups/YYYY-MM-DD/
```

---

### 7. Kubernetes Development (K3d)

```bash
# Buat cluster (butuh ~12GB RAM, jangan bersamaan dengan fullstack)
k3d cluster create dev-cluster --agents 2 \
  --port "30080:80@loadbalancer" \
  --port "30443:443@loadbalancer"

# Verifikasi
kubectl get nodes
kubectl get pods -A

# Deploy aplikasi
kubectl apply -f projects/go/k8s/

# Hapus cluster setelah selesai
k3d cluster delete dev-cluster
```

---

### 8. Health Check & Troubleshooting

```bash
# Cek status semua container
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Health check lengkap
bash infrastructure/scripts/health-check.sh

# Lihat logs service tertentu
docker logs dev-postgres --tail 50 -f
docker logs dev-kafka --tail 50 -f

# Restart service yang bermasalah
docker restart dev-postgres

# Cek resource usage
docker stats --no-stream
```

---

### 9. Cleanup & Maintenance

```bash
# Stop semua service (data tetap aman di volumes)
dc down

# Bersihkan resource tidak terpakai (images, networks, build cache)
bash infrastructure/scripts/cleanup.sh

# Maintenance rutin (cek disk, prune, report)
bash infrastructure/scripts/maintenance.sh

# Lihat ukuran volumes
docker system df -v
```

---

## 📁 Project Structure

```
/mnt/e/development/
├── CLAUDE.md                        # Context untuk Claude AI
├── README.md                        # File ini
├── infrastructure/
│   ├── docker/
│   │   ├── compose/
│   │   │   ├── docker-compose.yml   # Single file, semua profiles
│   │   │   ├── .env                 # GITIGNORED — credentials
│   │   │   └── plane/               # Plane project management
│   │   └── images/                  # Custom Dockerfiles
│   ├── scripts/                     # 11 automation scripts
│   │   ├── start-lab.sh
│   │   ├── stop-lab.sh
│   │   ├── status-lab.sh
│   │   ├── health-check.sh
│   │   ├── backup-databases.sh
│   │   ├── maintenance.sh
│   │   ├── cleanup.sh
│   │   ├── logs.sh
│   │   ├── setup-cron.sh
│   │   ├── test-all.sh
│   │   └── test-workflow.sh
│   ├── configs/
│   │   └── prometheus/
│   │       └── prometheus.yml
│   └── secrets/                     # GITIGNORED
│       ├── .env.databases.example
│       └── .env.monitoring.example
├── projects/
│   ├── go/
│   ├── rust/
│   ├── typescript/
│   ├── php/
│   │   └── laravel-company-employee-management/
│   ├── python/
│   └── qr-pdf-service/
├── data/                            # GITIGNORED — backups & dumps
├── docs/
└── templates/
```

---

## 🗂️ Project Submodules

Setiap project di-manage sebagai git submodule — repo terpisah, history terpisah, tapi terintegrasi di infra repo ini.

### Registered Submodules

| Project | Path | Remote |
|---------|------|--------|
| Laravel Company Employee Management | `projects/php/laravel-company-employee-management` | [gitlab.com/aliphamjah](https://gitlab.com/aliphamjah/laravel-company-employee-management) |
| QR PDF Service | `projects/qr-pdf-service` | [github.com/aliphamjah](https://github.com/aliphamjah/visitor-id-pdf-service) |

### Clone dengan Semua Submodules

```bash
# Clone + init semua submodule sekaligus
git clone --recurse-submodules git@github.com:aliphamjah/homelab-infrastructure.git

# Atau jika sudah clone tanpa submodule
git submodule update --init --recursive
```

### Update Submodule ke Commit Terbaru

```bash
# Update satu submodule
git submodule update --remote projects/qr-pdf-service

# Update semua submodule sekaligus
git submodule update --remote --merge

# Commit pointer update di infra repo
git add projects/qr-pdf-service
git commit -m "chore: update qr-pdf-service submodule"
git push
```

### Kerja di dalam Submodule

```bash
# Masuk ke direktori project
cd projects/qr-pdf-service

# Cek branch (submodule default: detached HEAD)
git checkout main

# Kerja seperti biasa — commit, push ke repo masing-masing
git add .
git commit -m "feat: ..."
git push

# Kembali ke infra repo dan update pointer
cd ../..
git add projects/qr-pdf-service
git commit -m "chore: update qr-pdf-service submodule"
git push
```

### Tambah Project Baru sebagai Submodule

```bash
git submodule add <remote-url> projects/<language>/<project-name>
git commit -m "feat: add <project-name> as submodule"
git push
```

### Hapus Submodule

```bash
git submodule deinit projects/<project-name>
git rm projects/<project-name>
git commit -m "chore: remove <project-name> submodule"
```

---

## 🔐 Security

- Semua credentials di `.env` — **tidak pernah di-hardcode** di compose file
- `.env` dan `secrets/` masuk `.gitignore`
- SSH keys di `~/.ssh/`, bukan di dalam repo
- Mongo Express dilindungi basic auth
- Container berjalan sebagai non-root user (Dockerfile hardened)

---

## 📊 System Status

**Last Updated**: 2026-03-02

| Component | Status | Notes |
|-----------|--------|-------|
| PostgreSQL | ✅ | Port 5432, profile: minimal |
| Redis | ✅ | Port 6379, profile: minimal |
| MongoDB | ✅ | Port 27017, profile: backend |
| Kafka | ✅ | Port 9092, **KRaft mode** (no Zookeeper) |
| Elasticsearch | ✅ | Port 9200, profile: fullstack |
| Monitoring stack | ✅ | Prometheus + Grafana + exporters |
| Scripts | ✅ | 11/11 scripts, portable (BASH_SOURCE) |

---

## 👤 Author

**Alip Hamjah**
- GitHub: [@aliphamjah](https://github.com/aliphamjah)

---

*Private — Personal Use Only*

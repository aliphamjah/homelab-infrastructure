# 🏠 Home Lab - Claude Context

> **Model:** Lenovo ThinkPad T14 Gen 2 | **WSL2 Ubuntu 22.04** | **Docker Engine 27.3.1**
> **Source of truth:** https://www.notion.so/3164e3efc9fb81f3a0b3e45a0adbe847
> **Last synced from Notion:** 2026-03-02

---

## ⚠️ NON-NEGOTIABLE RULES

1. **RAM WSL2 MAX = 20GB** — jangan pernah rekomendasikan melebihi ini
2. **CEK PORT TABLE** sebelum assign port baru — zero tolerance conflict
3. **SCOPE BOUNDARY** — Corporate tools (Power Apps, Power BI, Teams) = Windows ONLY. Home lab = WSL2 ONLY. Jangan campur.
4. **THERMAL LIMIT** — Max 85-88°C. Heavy workload max 2-4 jam, lalu cooldown 15-30 menit
5. **JANGAN SUGGEST** "tambah RAM" atau "upgrade hardware" — RAM soldered, tidak bisa upgrade
6. **PROFILE-BASED** — Mulai dari `minimal`, scale up sesuai kebutuhan, stop heavy services setelah selesai

---

## 💻 Hardware

| Spec | Detail |
|------|--------|
| Model | Lenovo ThinkPad T14 Gen 2 (AMD), 20XK/20XL |
| CPU | AMD Ryzen 7 PRO 5850U — Zen 3, 8c/16t, boost 4.4GHz |
| RAM | 32GB DDR4-3200 **SOLDERED** (non-upgradeable) |
| Storage | 1TB NVMe SSD PCIe 3.0 x4 |
| Thermal throttle | ~85-88°C (starts reducing clocks) |
| Sustained TDP | ~20-22W under continuous load |
| Target lifespan | Oktober 2030 (5 tahun dari beli) |

---

## 🗂️ Disk Layout

| Drive | Size | Purpose |
|-------|------|---------|
| `C:\` | 237.64 GB | Windows 11 Pro + System Apps |
| `D:\` | 400 GB | WSL2 VHDX + Docker volumes |
| `E:\` | 315 GB | Projects + Databases + Backups |

**Dev directory:** `/mnt/e/development`

---

## 🪟 OS Stack

- **Host:** Windows 11 Pro 23H2 — corporate tools only
- **Dev:** WSL2 Ubuntu 22.04.5 LTS, kernel 6.6.87.2-microsoft-standard-WSL2
- **WSL2 config:** 20GB RAM, 6 cores, 8GB swap
- **Filesystem rule:** Selalu kerja di Linux FS (`~/` atau `/mnt/e/`) — 3x lebih cepat dari `/mnt/c/`

---

## 🐳 Docker

| Spec | Detail |
|------|--------|
| Type | Docker Engine native WSL2 (bukan Docker Desktop) |
| Version | 27.3.1, Compose v2.27.1 |
| Storage driver | overlay2 |
| Data root | /var/lib/docker |
| Idle memory | ~1.2GB |
| Volume strategy | Named volumes untuk data persisten |
| Credentials | Semua dari `.env` — JANGAN hardcode di compose/scripts |

**Docker Networks:**
| Network | Subnet | Purpose |
|---------|--------|---------|
| dev-network | 172.20.0.0/16 | General dev services |
| kafka-network | 172.21.0.0/16 | Kafka cluster isolation |
| k8s-network | 172.22.0.0/16 | Kubernetes services |
| monitoring-network | 172.23.0.0/16 | Prometheus, Grafana |

**Bash Aliases:** `dc`, `dcu`, `dcd`, `dcl`, `dcp`, `dev`, `docker-status`, `docker-restart`, `docker-clean`

---

## 🚀 Service Profiles

| Profile | Services | RAM | Command |
|---------|----------|-----|---------|
| **minimal** | PostgreSQL, Redis, pgAdmin, Redis Commander | ~4GB | `docker compose --profile minimal up -d` |
| **backend** | + MongoDB, Kafka (KRaft), Mongo Express, Kafka UI | ~8GB | `docker compose --profile backend up -d` |
| **fullstack** | + Elasticsearch, Kibana, Nginx | ~14GB | `docker compose --profile fullstack up -d` |
| **monitoring** | Prometheus, Grafana, Node Exporter, cAdvisor | ~3GB | `docker compose --profile monitoring up -d` |
| **kubernetes** | K3d (2-3 nodes) + registry + monitoring | ~12GB | `k3d cluster create dev-cluster --agents 2` |

> **Kafka**: Berjalan dalam **KRaft mode** (combined broker+controller, tanpa Zookeeper) sejak 2026-03-02.

---

## 🔌 Port Allocation

> ⚠️ **Cek tabel ini SEBELUM assign port baru. Tanyakan ke user jika tidak yakin.**

### Databases
| Service | Port | Container |
|---------|------|-----------|
| PostgreSQL (main) | **5432** | dev-postgres |
| PostgreSQL (Plane) | **5433** | plane-postgres |
| MongoDB | **27017** | dev-mongo |
| Redis (main) | **6379** | dev-redis |
| Redis (Plane) | **6380** | plane-redis |
| MySQL | **3306** | dev-mysql |

### Message Queues
| Service | Port | Container |
|---------|------|-----------|
| Kafka (KRaft broker) | **9092** | dev-kafka |
| Kafka UI | **8090** | dev-kafka-ui |

> **Catatan:** Zookeeper (port 2181) sudah dihapus. Kafka kini pakai KRaft mode.

### Search & Analytics
| Service | Port | Container |
|---------|------|-----------|
| Elasticsearch | **9200** | dev-elasticsearch |
| Elasticsearch transport | **9300** | dev-elasticsearch |
| Kibana | **5601** | dev-kibana |

### Web & Proxy
| Service | Port | Container |
|---------|------|-----------|
| Nginx HTTP | **80** | dev-nginx |
| Nginx HTTPS | **443** | dev-nginx |
| Apache | **8080** | apache |

### Monitoring
| Service | Port | Container |
|---------|------|-----------|
| Prometheus | **9090** | dev-prometheus |
| Grafana | **3002** | dev-grafana |
| Node Exporter | **9100** | dev-node-exporter |
| cAdvisor | **8085** | dev-cadvisor |

### Dev Tools
| Service | Port | Container |
|---------|------|-----------|
| pgAdmin | **5050** | dev-pgadmin |
| Mongo Express | **8081** | dev-mongo-express |
| Redis Commander | **8082** | dev-redis-commander |
| Jupyter | **8888** | jupyter |

### Projects
| Service | Port | Container |
|---------|------|-----------|
| QR PDF Service | **8250** | qr-pdf-service |

### Backend Services
| Service | Port |
|---------|------|
| Go API | **8000** |
| Rust service | **8001** |
| Node.js API | **3000** |
| Python API | **8002** |
| PHP-FPM | **9000** |

### Frontend Dev
| Service | Port |
|---------|------|
| React/Vite | **5173** |
| Vue/Vite | **5174** |
| Next.js | **3001** |
| Angular | **4200** |

### Kubernetes
| Service | Port |
|---------|------|
| K3s API | **6443** |
| K3s Kubelet | **10250** |
| K3s Ingress HTTP | **30080** |
| K3s Ingress HTTPS | **30443** |

### Plane (Project Management)
| Service | Port | Container |
|---------|------|-----------|
| Plane Web | **8300** | plane-web |
| MinIO API | **9001** | plane-minio |
| MinIO Console | **9002** | plane-minio |

### Reserved Ranges
| Range | Purpose |
|-------|---------|
| 8100-8199 | Custom services |
| 8200-8299 | Microservices |
| 9000-9099 | Testing services |
| 10000-10099 | Temporary services |

---

## 📁 Project Structure (Aktual)

```
/mnt/e/development/
├── CLAUDE.md                        # ← File ini
├── README.md
├── MASTER.md
├── QUICKREF.md
├── CHANGELOG.md
├── .gitignore
├── infrastructure/
│   ├── docker/
│   │   ├── compose/
│   │   │   ├── docker-compose.yml   # Single file, semua profiles
│   │   │   ├── .env                 # GITIGNORED — credentials
│   │   │   └── plane/               # Plane project management
│   │   └── images/                  # Custom Dockerfiles (future)
│   ├── scripts/                     # 11 scripts, semua portable (BASH_SOURCE)
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
│   │       └── prometheus.yml       # Prometheus scrape config
│   └── secrets/                     # GITIGNORED
│       ├── .env.databases.example
│       ├── .env.monitoring.example
│       └── .env.qr-pdf-service
├── projects/
│   ├── go/
│   ├── rust/
│   ├── typescript/
│   ├── php/
│   │   └── laravel-company-employee-management/
│   ├── python/
│   └── qr-pdf-service/              # Cloudflare Workers — repo terpisah
│                                    # GitHub: aliphamjah/visitor-id-pdf-service
├── data/                            # GITIGNORED — backups & DB dumps
├── docs/
└── templates/
```

---

## 📦 Image Versions (Pinned — jangan ganti ke latest)

| Service | Image | Version |
|---------|-------|---------|
| PostgreSQL | postgres | 16-alpine |
| Redis | redis | 7-alpine |
| pgAdmin | dpage/pgadmin4 | 8.14 |
| Redis Commander | rediscommander/redis-commander | 0.8.0 |
| MongoDB | mongo | 7.0 |
| Mongo Express | mongo-express | 1.0.2 |
| Kafka | confluentinc/cp-kafka | 7.7.0 |
| Kafka UI | provectuslabs/kafka-ui | v0.7.2 |
| Elasticsearch | elasticsearch | 8.11.0 |
| Kibana | kibana | 8.11.0 |
| Nginx | nginx | 1.27-alpine |
| Prometheus | prom/prometheus | v2.53.0 |
| Grafana | grafana/grafana | 11.1.0 |
| Node Exporter | prom/node-exporter | v1.8.1 |
| cAdvisor | gcr.io/cadvisor/cadvisor | v0.49.1 |

---

## 🔐 DevOps Standards (Berlaku di repo ini)

Aturan ini wajib diikuti saat menambah atau mengubah konfigurasi:

1. **Credentials** — Semua dari `${ENV_VAR}` via `.env`. Tidak boleh hardcode di compose file, scripts, atau Dockerfile.
2. **Image tags** — Selalu pin ke versi spesifik. Dilarang pakai `:latest`.
3. **Resource limits** — Setiap container WAJIB punya `deploy.resources.limits` (memory + cpus).
4. **Healthcheck** — Setiap stateful service (DB, broker) WAJIB punya healthcheck.
5. **depends_on** — Gunakan `condition: service_healthy` bukan hanya nama service.
6. **Scripts paths** — Gunakan `SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`. Dilarang hardcode `/mnt/e/...`.
7. **Credentials di scripts** — Source `.env` di awal script (`set -a; source "$ENV_FILE"; set +a`).
8. **SSH keys** — Simpan di `~/.ssh/`, bukan di dalam direktori repo.
9. **Dockerfile** — Wajib: `.dockerignore`, `npm ci` (bukan install), non-root user, `HEALTHCHECK`.
10. **Network** — Assign service ke network yang sesuai. Dev services → `dev-network`, Kafka → `kafka-network`, monitoring → `monitoring-network`.

---

## 💡 Workload Reference

| Scenario | RAM | CPU Temp | Max Duration |
|----------|-----|----------|--------------|
| Light office | ~8GB | 40-50°C | Full day |
| Daily development | ~17GB | 50-65°C | 8 jam |
| Full home lab | ~27GB | 78-88°C | **2-4 jam** |
| Extreme stress | ~30GB | 85-90°C | **<1 jam** |

---

## 🔄 Sync Protocol

File ini diupdate langsung saat ada perubahan infrastruktur, tidak lagi menunggu sync dari Notion.

**Kapan update file ini:**
- Setelah install service baru (tambah ke port table + image versions)
- Setelah ubah port atau image version
- Setelah perubahan project structure signifikan
- Setelah DevOps standards baru ditetapkan

**Notion URL:** https://www.notion.so/3164e3efc9fb81f3a0b3e45a0adbe847

---

## 📝 Changelog

| Date | Change | By |
|------|--------|----|
| 2026-03-02 | Notion synced: Kafka KRaft direfleksikan di port table, Projects section (QR PDF Service 8250) ditambahkan, Project Structure diupdate ke single docker-compose.yml, duplicate sections dibersihkan | Claude via MCP |
| 2026-03-02 | Notion instruksi fetch diupdate — CLAUDE.md auto-loaded, tidak perlu fetch Notion setiap sesi | Claude via MCP |
| 2026-03-02 | Initial CLAUDE.md created — DevOps review & hardening session | Claude Code |

*Last updated: 2026-03-02 | Updated by: Claude Code*

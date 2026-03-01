# 🏠 Home Lab - Claude Context

> **Model:** Lenovo ThinkPad T14 Gen 2 | **WSL2 Ubuntu 22.04** | **Docker Engine 27.3.1**
> **Source of truth:** https://www.notion.so/3164e3efc9fb81f3a0b3e45a0adbe847
> **Last synced from Notion:** 2026-03-01

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
| Volume strategy | Named volumes (bukan bind mounts) |
| Default container RAM | 2GB |

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
| **minimal** | PostgreSQL, Redis | ~4GB | `docker compose --profile minimal up -d` |
| **backend** | + MongoDB, Kafka (1 broker) | ~8GB | `docker compose --profile backend up -d` |
| **fullstack** | + Elasticsearch, Nginx, Kafka (2 broker) | ~14GB | `docker compose --profile fullstack up -d` |
| **kubernetes** | K3d (2-3 nodes) + registry + monitoring | ~12GB | `k3d cluster create dev-cluster --agents 2` |
| **monitoring** | Prometheus, Grafana, exporters | ~3GB | `docker compose --profile monitoring up -d` |

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
| Kafka broker 1 | **9092** | kafka-1 |
| Kafka broker 2 | **9093** | kafka-2 |
| Kafka broker 3 | **9094** | kafka-3 |
| Zookeeper | **2181** | zookeeper |
| Kafka UI | **8090** | kafka-ui |

### Search & Analytics
| Service | Port | Container |
|---------|------|-----------|
| Elasticsearch | **9200** | elasticsearch |
| Elasticsearch transport | **9300** | elasticsearch |
| Kibana | **5601** | kibana |

### Web & Proxy
| Service | Port | Container |
|---------|------|-----------|
| Nginx HTTP | **80** | nginx |
| Nginx HTTPS | **443** | nginx |
| Apache | **8080** | apache |

### Monitoring
| Service | Port | Container |
|---------|------|-----------|
| Prometheus | **9090** | prometheus |
| Grafana | **3002** | grafana |
| Node Exporter | **9100** | node-exporter |
| cAdvisor | **8085** | cadvisor |

### Dev Tools
| Service | Port | Container |
|---------|------|-----------|
| pgAdmin | **5050** | pgadmin |
| Mongo Express | **8081** | mongo-express |
| Redis Commander | **8082** | redis-commander |
| Jupyter | **8888** | jupyter |

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

## 📁 Project Structure

```
/mnt/e/development/
├── CLAUDE.md                    # ← File ini
├── README.md
├── ARCHITECTURE.md
├── CHANGELOG.md
├── infrastructure/
│   ├── docker/
│   │   ├── compose/             # databases.yml, kafka.yml, elasticsearch.yml,
│   │   │                        # monitoring.yml, nginx.yml, dev-tools.yml
│   │   ├── images/              # go-dev/, rust-dev/, node-dev/ Dockerfiles
│   │   └── volumes/
│   ├── kubernetes/
│   │   ├── manifests/           # namespaces/, deployments/, services/,
│   │   │                        # configmaps/, secrets/, ingress/
│   │   └── helm/
│   ├── scripts/
│   │   ├── start-lab.sh
│   │   ├── stop-lab.sh
│   │   ├── restart-lab.sh
│   │   ├── status-lab.sh
│   │   ├── backup.sh
│   │   ├── restore.sh
│   │   ├── cleanup.sh
│   │   └── health-check.sh
│   ├── configs/                 # nginx/, prometheus/, grafana/, kafka/
│   └── secrets/                 # GITIGNORED
├── projects/
│   ├── go/
│   ├── rust/
│   ├── typescript/
│   ├── php/
│   └── python/
├── data/                        # GITIGNORED
├── docs/
└── templates/
```

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

File ini adalah **local mirror** dari Notion (single source of truth).

**Kapan update file ini:**
- Setelah install service baru
- Setelah ubah port atau config
- Setelah perubahan project structure signifikan
- Minimal setiap 2 minggu untuk menjaga konsistensi

**Cara update:**
1. Beritahu perubahan ke Claude di claude.ai
2. Claude update Notion via MCP
3. Jalankan command berikut untuk re-sync CLAUDE.md:

```bash
# Cara mudah: minta Claude generate ulang CLAUDE.md yang updated
# lalu replace file ini
```

**Notion URL:** https://www.notion.so/3164e3efc9fb81f3a0b3e45a0adbe847

---

*Last synced: 2026-03-01 | Source: Notion via Claude MCP*

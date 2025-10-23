# Home Lab Development Environment

Complete development infrastructure for learning and experimentation.

## 🖥️ Hardware
- **Laptop**: Lenovo ThinkPad T14 Gen 2
- **CPU**: AMD Ryzen 7 PRO 5850U (8c/16t)
- **RAM**: 32GB DDR4-3200
- **Storage**: 1TB NVMe SSD

## 🐧 Software Stack
- **Host OS**: Windows 11 Pro
- **WSL2**: Ubuntu 22.04.5 LTS (20GB RAM, 6 cores)
- **Docker**: 28.5.1 (native engine, not Desktop)
- **Docker Compose**: 2.40.2

## 📁 Project Structure
```
development/
├── infrastructure/     # Docker, K8s, configs, scripts
├── projects/          # Source code (Go, Rust, TypeScript, Python, PHP)
├── data/              # Persistent volumes & backups (gitignored)
├── docs/              # Documentation & learning logs
└── templates/         # Project quick-start templates
```

## 🌐 Docker Networks
- `dev-network` (172.20.0.0/16) - General development
- `kafka-network` (172.21.0.0/16) - Message brokers
- `k8s-network` (172.22.0.0/16) - Kubernetes services
- `monitoring-network` (172.23.0.0/16) - Observability

## 🚀 Quick Start

### Start Minimal Profile (PostgreSQL + Redis)
```bash
cd infrastructure/docker/compose
docker compose --profile minimal up -d
```

### Check Status
```bash
docker compose ps
docker network ls
```

### Access Development Directory
```bash
dev  # alias for: cd /mnt/e/development
```

## 📚 Documentation
- [Setup Guides](docs/setup/) - Installation & configuration
- [Maintenance](docs/maintenance/) - Weekly/monthly tasks
- [Troubleshooting](docs/troubleshooting/) - Common issues & solutions
- [Learning Logs](docs/learnings/) - Experiments & insights

## 🛠️ Available Aliases
```bash
dev                 # Jump to development directory
docker-status       # Check Docker daemon
docker-restart      # Restart Docker
docker-clean        # Prune unused resources

dc                  # docker compose
dcu                 # docker compose up -d
dcd                 # docker compose down
dcl                 # docker compose logs -f
dcp                 # docker compose ps
```

## 🎯 Service Profiles

### Minimal (4GB WSL2)
- PostgreSQL, Redis
- Daily development

### Backend Dev (8GB WSL2)
- + MongoDB, Kafka (1 broker)
- API development

### Full Stack (14GB WSL2)
- + Elasticsearch, Nginx, Kafka cluster
- Production-like testing

### Kubernetes (12GB WSL2)
- K3d cluster (2-3 nodes)
- Container orchestration learning

### Monitoring (3GB WSL2)
- Prometheus, Grafana
- Observability stack

## 📊 Resource Monitoring
```bash
# WSL2 memory usage
free -h

# Docker resource usage
docker stats

# Disk usage
df -h
docker system df
```

## 🔒 Security Notes
- `data/` directory is gitignored (contains database files)
- `secrets/` directory is gitignored (contains .env files)
- Never commit real credentials
- Use `.env.example` templates for documentation

## 🎓 Learning Goals
- Docker & containerization
- Kubernetes orchestration
- Microservices architecture
- CI/CD pipelines
- Infrastructure as Code
- Monitoring & observability

## 📝 Setup Completed
- ✅ Phase 1: Windows Optimization
- ✅ Phase 2: WSL2 Installation
- ✅ Phase 3: Docker Engine Setup
- ✅ Phase 4: Project Structure Creation
- ⏭️ Phase 5: Base Services Deployment
- ⏭️ Phase 6: Automation Scripts
- ⏭️ Phase 7: Verification & Testing

## 📅 Maintenance Schedule
- **Weekly**: Backup databases, check disk usage
- **Monthly**: Update images, clean resources, review learnings
- **Quarterly**: Thermal maintenance, full system backup

---

**Created**: 2025-10-24
**Last Updated**: 2025-10-24
**Status**: Active Development

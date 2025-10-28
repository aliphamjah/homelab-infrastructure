# 🏠 Home Lab Infrastructure

> Personal Development Environment on Lenovo ThinkPad T14 Gen 2

**Status**: 🟢 Production Ready  
**Version**: 1.0.0  
**Last Updated**: October 28, 2025

---

## 📋 Overview

Complete containerized development environment featuring:
- ✅ Docker Engine (native in WSL2)
- ✅ PostgreSQL 16 + pgAdmin
- ✅ Redis 7 + Redis Commander
- ✅ MongoDB 7 + Mongo Express (Backend Profile)
- ✅ Apache Kafka + Kafka UI (Backend Profile)
- ✅ Elasticsearch + Kibana (Fullstack Profile)
- ✅ Nginx (Fullstack Profile)
- ✅ Automated backup & monitoring
- ✅ 11 management scripts

---

## 🚀 Quick Start

### Start Services
```bash
# Minimal profile (4GB)
cd /mnt/e/development/infrastructure/docker/compose
docker compose --profile minimal up -d

# Access services
# PostgreSQL:  localhost:5432
# Redis:       localhost:6379
# pgAdmin:     http://localhost:5050
# Redis Commander: http://localhost:8082
```

### Stop Services
```bash
docker compose down
```

### Check Status
```bash
docker compose ps
# or
./infrastructure/scripts/health-check.sh
```

---

## 📚 Documentation

- **[Quick Reference Guide](QUICKREF.md)** - Daily commands & common tasks
- **[Credentials Reference](CREDENTIALS.md)** - All passwords & connection strings
- **[Project Structure](docs/PROJECT_STRUCTURE.md)** - Directory organization
- **[Port Allocation](infrastructure/PORT_ALLOCATION.md)** - Port mappings

---

## 🎯 Service Profiles

### Minimal (4GB WSL2)
Daily development with PostgreSQL + Redis
```bash
docker compose --profile minimal up -d
```

### Backend (8GB WSL2)
API development with databases + Kafka + MongoDB
```bash
docker compose --profile backend up -d
```

### Fullstack (14GB WSL2)
Complete stack with Elasticsearch + Nginx
```bash
docker compose --profile fullstack up -d
```

---

## 🛠️ Management Scripts

Located in `infrastructure/scripts/`:

### Core Operations
- `start-lab.sh` - Start services by profile
- `stop-lab.sh` - Stop all services
- `status-lab.sh` - Check service status
- `health-check.sh` - Comprehensive health monitoring

### Database Management
- `db-helper.sh` - Database shell, info, backup
- `backup-databases.sh` - Automated backup (daily/weekly/monthly)

### Maintenance
- `cleanup.sh` - Remove unused Docker resources
- `maintenance.sh` - Weekly maintenance routine
- `logs.sh` - Container log management

### Automation
- `setup-cron.sh` - Setup automated tasks (optional)
- `test-all.sh` - Comprehensive system test

---

## 📊 System Status
```
Hardware:      Lenovo ThinkPad T14 Gen 2
Processor:     AMD Ryzen 7 PRO 5850U (8c/16t)
Memory:        32GB DDR4-3200
Storage:       1TB NVMe SSD
OS:            Windows 11 Pro + WSL2 (Ubuntu 22.04)

Current Usage:
- WSL2 Memory:  ~700Mi / 19Gi (3.6%)
- Disk Usage:   106M / 316G (1%)
- Containers:   4 running (all healthy)

Networks:      3 active (dev, kafka, monitoring)
Volumes:       3 persistent (postgres, redis, pgadmin)
Backup Status: Tested & working
```

---

## 🔧 Maintenance Schedule

### Daily (Automated via Cron - Optional)
- Database backups at 2 AM

### Weekly
- Run maintenance.sh (health check + backup + updates)
- Review logs for errors

### Monthly
- Cleanup unused Docker resources
- Check disk space
- Review security updates

### Every 6 Months
- Laptop cooling system inspection
- Performance baseline review

---

## 🎓 Learning Resources

This home lab is designed for learning:
- Docker & containerization
- Database administration
- Microservices architecture
- DevOps practices
- System administration
- Infrastructure as Code

---

## ⚠️ Important Notes

### Development Only
Current configuration is for **local development**:
- Default passwords (simple & easy)
- No external network access
- Localhost-only services
- No SSL/TLS encryption

**DO NOT use these configurations in production!**

### Resource Management
- Start with **minimal profile** for daily work
- Use **backend/fullstack** profiles for intensive tasks only
- Take cooldown breaks during heavy workloads (every 2-3 hours)
- Monitor resource usage with `free -h` and `docker stats`

### Data Safety
- Backups saved to `/mnt/e/development/data/backups/`
- Daily backups kept for 7 days
- Weekly backups kept for 4 weeks
- Monthly backups kept for 12 months
- All data persisted in Docker volumes

---

## 🎯 Next Steps

1. **Explore the Quick Reference** - Learn daily commands
2. **Test all profiles** - minimal → backend → fullstack
3. **Setup cron automation** (optional) - Automated maintenance
4. **Start building projects** - Create your first microservice!
5. **Learn Kubernetes** - K3d setup coming in Phase 8

---

## 📞 Troubleshooting

### Services won't start?
```bash
./infrastructure/scripts/health-check.sh
docker logs [container_name]
```

### Out of memory?
```bash
docker compose --profile minimal down
docker compose --profile minimal up -d
```

### Need help?
Check documentation in `docs/` directory or run:
```bash
./infrastructure/scripts/[script-name].sh help
```

---

## 🏆 Project Completion

**Phase 1**: ✅ Windows Optimization  
**Phase 2**: ✅ WSL2 Installation  
**Phase 3**: ✅ Docker Engine Setup  
**Phase 4**: ✅ Project Structure  
**Phase 5**: ✅ Base Services Deployment  
**Phase 6**: ✅ Automation & Scripts  
**Phase 7**: ✅ Final Verification & Docs  

**Status**: 🎉 **100% COMPLETE!**

---

**Built with ❤️ for learning and experimentation**

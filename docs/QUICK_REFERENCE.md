# 🚀 Home Lab Quick Reference Guide

> Last Updated: October 28, 2025  
> Version: 1.0.0

---

## 📋 Table of Contents

1. [Daily Commands](#daily-commands)
2. [Service Profiles](#service-profiles)
3. [Database Access](#database-access)
4. [Common Tasks](#common-tasks)
5. [Troubleshooting](#troubleshooting)
6. [Port Reference](#port-reference)

---

## 🎯 Daily Commands

### Starting Services
```bash
# Start minimal profile (PostgreSQL + Redis)
cd /mnt/e/development/infrastructure/docker/compose
docker compose --profile minimal up -d

# Or use helper script
/mnt/e/development/infrastructure/scripts/start-lab.sh minimal
```

### Stopping Services
```bash
# Stop all services
docker compose down

# Or use helper script
/mnt/e/development/infrastructure/scripts/stop-lab.sh
```

### Check Status
```bash
# Quick status
docker compose ps

# Detailed health check
/mnt/e/development/infrastructure/scripts/health-check.sh

# Check logs
/mnt/e/development/infrastructure/scripts/logs.sh view
```

---

## 🎨 Service Profiles

### Minimal Profile (4GB WSL2)
**Use for**: Daily development, light coding
```bash
docker compose --profile minimal up -d
```

**Services**:
- PostgreSQL (5432)
- Redis (6379)
- pgAdmin (5050)
- Redis Commander (8082)

**Memory**: ~4GB in WSL2

---

### Backend Profile (8GB WSL2)
**Use for**: API development, microservices
```bash
docker compose --profile backend up -d
```

**Services**:
- Everything in Minimal +
- MongoDB (27017)
- Mongo Express (8081)
- Kafka (9092)
- Kafka UI (8090)

**Memory**: ~8GB in WSL2

---

### Fullstack Profile (14GB WSL2)
**Use for**: Complete application testing
```bash
docker compose --profile fullstack up -d
```

**Services**:
- Everything in Backend +
- Elasticsearch (9200)
- Kibana (5601)
- Nginx (80, 443)

**Memory**: ~14GB in WSL2

---

## 🗄️ Database Access

### PostgreSQL
```bash
# Open psql shell
/mnt/e/development/infrastructure/scripts/db-helper.sh postgres shell

# Quick commands
\l              # List databases
\c homelab      # Connect to homelab database
\dt             # List tables
\d table_name   # Describe table
\q              # Quit

# Get database info
/mnt/e/development/infrastructure/scripts/db-helper.sh postgres info

# Quick backup
/mnt/e/development/infrastructure/scripts/db-helper.sh postgres backup
```

**Connection Details**:
- Host: localhost
- Port: 5432
- User: postgres
- Password: postgres
- Database: homelab

---

### Redis
```bash
# Open redis-cli
/mnt/e/development/infrastructure/scripts/db-helper.sh redis shell

# Quick commands
PING            # Test connection
KEYS *          # List all keys
GET key         # Get value
SET key value   # Set value
DEL key         # Delete key
FLUSHALL        # Clear all data (DANGER!)
INFO            # Server info
exit            # Quit

# Get Redis info
/mnt/e/development/infrastructure/scripts/db-helper.sh redis info

# Quick backup
/mnt/e/development/infrastructure/scripts/db-helper.sh redis backup
```

**Connection Details**:
- Host: localhost
- Port: 6379
- Password: homelab_redis_2025

---

### MongoDB (Backend Profile)
```bash
# Open mongosh
/mnt/e/development/infrastructure/scripts/db-helper.sh mongo shell

# Quick commands
show dbs        # List databases
use mydb        # Switch database
show collections # List collections
db.users.find() # Query collection
exit            # Quit

# Get MongoDB info
/mnt/e/development/infrastructure/scripts/db-helper.sh mongo info
```

**Connection Details**:
- Host: localhost
- Port: 27017
- User: admin
- Password: homelab_mongo_2025

---

## ⚡ Common Tasks

### View Logs
```bash
# View all logs
/mnt/e/development/infrastructure/scripts/logs.sh view

# View specific service
/mnt/e/development/infrastructure/scripts/logs.sh view postgres

# Follow logs (real-time)
/mnt/e/development/infrastructure/scripts/logs.sh follow redis

# Last 100 lines
/mnt/e/development/infrastructure/scripts/logs.sh tail postgres 100

# Show only errors
/mnt/e/development/infrastructure/scripts/logs.sh errors

# Check log sizes
/mnt/e/development/infrastructure/scripts/logs.sh size
```

---

### Backup & Restore
```bash
# Manual backup (all databases)
/mnt/e/development/infrastructure/scripts/backup-databases.sh

# Quick backup (single database)
/mnt/e/development/infrastructure/scripts/db-helper.sh postgres backup
/mnt/e/development/infrastructure/scripts/db-helper.sh redis backup

# Backup location
/mnt/e/development/data/backups/daily/
```

---

### Cleanup
```bash
# Remove unused Docker resources
/mnt/e/development/infrastructure/scripts/cleanup.sh

# Check what can be cleaned
docker system df
```

---

### Weekly Maintenance
```bash
# Run full maintenance routine
/mnt/e/development/infrastructure/scripts/maintenance.sh

# This will:
# 1. Run health check
# 2. Backup databases
# 3. Update Docker images
```

---

## 🔧 Troubleshooting

### Container Won't Start
```bash
# Check logs
docker logs dev-postgres

# Check resource usage
docker stats

# Restart specific container
docker restart dev-postgres
```

---

### Database Connection Issues
```bash
# PostgreSQL
docker exec dev-postgres pg_isready -U postgres

# Redis
docker exec dev-redis redis-cli -a homelab_redis_2025 PING

# Check if port is listening
netstat -tuln | grep 5432
```

---

### Out of Memory
```bash
# Check WSL2 memory usage
free -h

# Stop unnecessary services
docker compose --profile minimal down
docker compose --profile minimal up -d

# Restart WSL2 (in PowerShell)
wsl --shutdown
```

---

### Disk Space Full
```bash
# Check disk usage
df -h /mnt/e/development

# Clean Docker resources
/mnt/e/development/infrastructure/scripts/cleanup.sh

# Check Docker disk usage
docker system df
```

---

## 🔌 Port Reference

| Port | Service | Profile |
|------|---------|---------|
| 5432 | PostgreSQL | minimal |
| 6379 | Redis | minimal |
| 5050 | pgAdmin | minimal |
| 8082 | Redis Commander | minimal |
| 27017 | MongoDB | backend |
| 8081 | Mongo Express | backend |
| 9092 | Kafka | backend |
| 8090 | Kafka UI | backend |
| 9200 | Elasticsearch | fullstack |
| 5601 | Kibana | fullstack |
| 80 | Nginx HTTP | fullstack |
| 443 | Nginx HTTPS | fullstack |

---

## 🎓 Best Practices

1. **Start with minimal profile** for daily work
2. **Run health checks** before intensive tasks
3. **Backup weekly** (or enable cron automation)
4. **Monitor resource usage** with `free -h` and `docker stats`
5. **Take cooldown breaks** during heavy workloads (every 2-3 hours)
6. **Clean up regularly** with cleanup.sh (monthly)
7. **Update images** occasionally with maintenance.sh

---

## 📞 Quick Help
```bash
# All scripts have help
/mnt/e/development/infrastructure/scripts/logs.sh help
/mnt/e/development/infrastructure/scripts/db-helper.sh help
```

---

## 🔗 Important Paths
```bash
# Jump to development directory
cd /mnt/e/development

# Or use alias
dev

# Scripts directory
cd /mnt/e/development/infrastructure/scripts

# Compose files
cd /mnt/e/development/infrastructure/docker/compose

# Backups
cd /mnt/e/development/data/backups
```

---

**Need more help?** Check the full documentation in `/mnt/e/development/docs/`

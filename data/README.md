# Data Directory

⚠️ **CRITICAL**: This directory is gitignored and contains sensitive data!

## Structure
- `postgres/` - PostgreSQL data files
- `mongo/` - MongoDB data files
- `redis/` - Redis persistence files
- `mysql/` - MySQL data files (if used)
- `elasticsearch/` - Elasticsearch indices
- `kafka/` - Kafka logs and data
- `grafana/` - Grafana dashboards and configs
- `prometheus/` - Prometheus time-series data
- `backups/` - Database backups (daily/weekly/monthly)

## Backup Strategy
- **Daily**: Last 7 days (auto-cleanup)
- **Weekly**: Last 4 weeks
- **Monthly**: Last 12 months

## Size Monitoring
Check data directory size regularly:
```bash
du -sh /mnt/e/development/data/*
```

## Backup Commands
```bash
# PostgreSQL backup
docker exec dev-postgres pg_dumpall -U postgres > backups/daily/postgres_$(date +%Y%m%d).sql

# MongoDB backup
docker exec dev-mongo mongodump --out=/data/backups/daily/mongo_$(date +%Y%m%d)

# Redis backup
docker exec dev-redis redis-cli SAVE
cp data/redis/dump.rdb backups/daily/redis_$(date +%Y%m%d).rdb
```

## Data Retention Policy
- Development data: No strict retention (can be recreated)
- Backups: Follow daily/weekly/monthly schedule
- Test data: Clean up monthly

## Security Notes
- **NEVER commit this directory to git**
- **NEVER share database dumps publicly**
- Use `.gitignore` to exclude all data files
- Encrypt backups if storing externally

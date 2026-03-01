#!/bin/bash
# Database Backup Script
# Backs up PostgreSQL, Redis, and MongoDB (if running)

set -e

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPTS_DIR/../docker/compose"

# Load credentials dari .env
ENV_FILE="$COMPOSE_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    set -a
    # shellcheck source=/dev/null
    source "$ENV_FILE"
    set +a
else
    echo "ERROR: .env file not found at $ENV_FILE"
    exit 1
fi

BACKUP_DIR="$SCRIPTS_DIR/../../data/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DAILY_DIR="$BACKUP_DIR/daily"
WEEKLY_DIR="$BACKUP_DIR/weekly"
MONTHLY_DIR="$BACKUP_DIR/monthly"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🗄️  Database Backup Script${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Create backup directories if they don't exist
mkdir -p "$DAILY_DIR" "$WEEKLY_DIR" "$MONTHLY_DIR"

# Check if containers are running
check_container() {
    docker ps --format '{{.Names}}' | grep -q "^$1$"
}

# Backup PostgreSQL
backup_postgresql() {
    if check_container "dev-postgres"; then
        echo -e "${YELLOW}📊 Backing up PostgreSQL...${NC}"
        
        BACKUP_FILE="$DAILY_DIR/postgres_${DATE}.sql"
        
        docker exec dev-postgres pg_dumpall -U "${POSTGRES_USER}" > "$BACKUP_FILE"
        
        # Compress the backup
        gzip "$BACKUP_FILE"
        
        SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
        echo -e "${GREEN}   ✓ PostgreSQL backup complete: ${SIZE}${NC}"
        echo -e "     Location: ${BACKUP_FILE}.gz"
    else
        echo -e "${YELLOW}   ⊘ PostgreSQL not running - skipping${NC}"
    fi
}

# Backup Redis
backup_redis() {
    if check_container "dev-redis"; then
        echo -e "${YELLOW}📊 Backing up Redis...${NC}"
        
        # Trigger Redis SAVE
        docker exec dev-redis redis-cli -a "${REDIS_PASSWORD}" SAVE > /dev/null 2>&1
        
        BACKUP_FILE="$DAILY_DIR/redis_${DATE}.rdb"
        
        # Copy the RDB file
        docker cp dev-redis:/data/dump.rdb "$BACKUP_FILE"
        
        # Compress the backup
        gzip "$BACKUP_FILE"
        
        SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
        echo -e "${GREEN}   ✓ Redis backup complete: ${SIZE}${NC}"
        echo -e "     Location: ${BACKUP_FILE}.gz"
    else
        echo -e "${YELLOW}   ⊘ Redis not running - skipping${NC}"
    fi
}

# Backup MongoDB
backup_mongodb() {
    if check_container "dev-mongo"; then
        echo -e "${YELLOW}📊 Backing up MongoDB...${NC}"
        
        BACKUP_DIR_MONGO="$DAILY_DIR/mongo_${DATE}"
        
        docker exec dev-mongo mongodump \
            --username "${MONGO_INITDB_ROOT_USERNAME}" \
            --password "${MONGO_INITDB_ROOT_PASSWORD}" \
            --authenticationDatabase admin \
            --out /tmp/backup > /dev/null 2>&1
        
        docker cp dev-mongo:/tmp/backup "$BACKUP_DIR_MONGO"
        
        # Compress the backup
        tar -czf "${BACKUP_DIR_MONGO}.tar.gz" -C "$DAILY_DIR" "mongo_${DATE}"
        rm -rf "$BACKUP_DIR_MONGO"
        
        SIZE=$(du -h "${BACKUP_DIR_MONGO}.tar.gz" | cut -f1)
        echo -e "${GREEN}   ✓ MongoDB backup complete: ${SIZE}${NC}"
        echo -e "     Location: ${BACKUP_DIR_MONGO}.tar.gz"
    else
        echo -e "${YELLOW}   ⊘ MongoDB not running - skipping${NC}"
    fi
}

# Cleanup old backups (keep last 7 days)
cleanup_old_backups() {
    echo ""
    echo -e "${YELLOW}🧹 Cleaning up old backups (keeping last 7 days)...${NC}"
    
    find "$DAILY_DIR" -name "*.gz" -mtime +7 -delete
    find "$DAILY_DIR" -name "*.tar.gz" -mtime +7 -delete
    
    echo -e "${GREEN}   ✓ Cleanup complete${NC}"
}

# Weekly backup (copy to weekly directory on Sundays)
weekly_backup() {
    if [ "$(date +%u)" -eq 7 ]; then
        echo ""
        echo -e "${YELLOW}📅 Creating weekly backup copy...${NC}"
        
        cp "$DAILY_DIR"/postgres_${DATE}.sql.gz "$WEEKLY_DIR/" 2>/dev/null || true
        cp "$DAILY_DIR"/redis_${DATE}.rdb.gz "$WEEKLY_DIR/" 2>/dev/null || true
        cp "$DAILY_DIR"/mongo_${DATE}.tar.gz "$WEEKLY_DIR/" 2>/dev/null || true
        
        # Keep last 4 weeks
        find "$WEEKLY_DIR" -name "*.gz" -mtime +28 -delete
        find "$WEEKLY_DIR" -name "*.tar.gz" -mtime +28 -delete
        
        echo -e "${GREEN}   ✓ Weekly backup created${NC}"
    fi
}

# Monthly backup (copy to monthly directory on 1st of month)
monthly_backup() {
    if [ "$(date +%d)" -eq 01 ]; then
        echo ""
        echo -e "${YELLOW}📆 Creating monthly backup copy...${NC}"
        
        cp "$DAILY_DIR"/postgres_${DATE}.sql.gz "$MONTHLY_DIR/" 2>/dev/null || true
        cp "$DAILY_DIR"/redis_${DATE}.rdb.gz "$MONTHLY_DIR/" 2>/dev/null || true
        cp "$DAILY_DIR"/mongo_${DATE}.tar.gz "$MONTHLY_DIR/" 2>/dev/null || true
        
        # Keep last 12 months
        find "$MONTHLY_DIR" -name "*.gz" -mtime +365 -delete
        find "$MONTHLY_DIR" -name "*.tar.gz" -mtime +365 -delete
        
        echo -e "${GREEN}   ✓ Monthly backup created${NC}"
    fi
}

# Run backups
backup_postgresql
backup_redis
backup_mongodb

cleanup_old_backups
weekly_backup
monthly_backup

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Backup complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Show backup directory size
echo ""
echo "📊 Backup Directory Summary:"
du -sh "$BACKUP_DIR"/* 2>/dev/null || echo "   No backups yet"

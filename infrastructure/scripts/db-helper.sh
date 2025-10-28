#!/bin/bash
# Database Management Helper Script

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Show usage
show_usage() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🗄️  Database Management Helper${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Usage: $0 [database] [command]"
    echo ""
    echo "Databases:"
    echo "  postgres    - PostgreSQL operations"
    echo "  redis       - Redis operations"
    echo "  mongo       - MongoDB operations"
    echo ""
    echo "Commands:"
    echo "  shell       - Open database shell/CLI"
    echo "  info        - Show database info"
    echo "  backup      - Quick backup (saved to /tmp)"
    echo "  restore     - Restore from backup"
    echo "  reset       - Reset database (WARNING: deletes all data!)"
    echo ""
    echo "Examples:"
    echo "  $0 postgres shell         # Open psql"
    echo "  $0 redis shell            # Open redis-cli"
    echo "  $0 postgres info          # Show PostgreSQL info"
    echo "  $0 postgres backup        # Quick backup"
    echo ""
}

# PostgreSQL commands
postgres_shell() {
    echo -e "${YELLOW}🐘 Opening PostgreSQL shell...${NC}"
    echo -e "${BLUE}💡 Connected to database: homelab${NC}"
    echo -e "${BLUE}💡 User: postgres${NC}"
    echo -e "${BLUE}💡 Type \\q to exit${NC}"
    echo ""
    docker exec -it dev-postgres psql -U postgres -d homelab
}

postgres_info() {
    echo -e "${YELLOW}🐘 PostgreSQL Information:${NC}"
    echo ""
    echo "Version:"
    docker exec dev-postgres psql -U postgres -c "SELECT version();" | head -3
    echo ""
    echo "Databases:"
    docker exec dev-postgres psql -U postgres -c "SELECT datname, pg_size_pretty(pg_database_size(datname)) as size FROM pg_database ORDER BY pg_database_size(datname) DESC;"
    echo ""
    echo "Tables in 'homelab' database:"
    docker exec dev-postgres psql -U postgres -d homelab -c "\dt"
}

postgres_backup() {
    BACKUP_FILE="/tmp/postgres_quickbackup_$(date +%Y%m%d_%H%M%S).sql"
    echo -e "${YELLOW}🐘 Backing up PostgreSQL...${NC}"
    docker exec dev-postgres pg_dumpall -U postgres > "$BACKUP_FILE"
    gzip "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backup saved: ${BACKUP_FILE}.gz${NC}"
    ls -lh "${BACKUP_FILE}.gz"
}

postgres_reset() {
    echo -e "${RED}⚠️  WARNING: This will delete ALL data in PostgreSQL!${NC}"
    echo ""
    read -p "Type 'DELETE ALL DATA' to confirm: " CONFIRM
    
    if [ "$CONFIRM" != "DELETE ALL DATA" ]; then
        echo -e "${YELLOW}Operation cancelled.${NC}"
        return
    fi
    
    echo -e "${YELLOW}🐘 Resetting PostgreSQL...${NC}"
    docker exec dev-postgres psql -U postgres -d homelab -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
    echo -e "${GREEN}✓ PostgreSQL reset complete${NC}"
}

# Redis commands
redis_shell() {
    echo -e "${YELLOW}🔴 Opening Redis CLI...${NC}"
    echo -e "${BLUE}💡 Type 'exit' or Ctrl+D to quit${NC}"
    echo ""
    docker exec -it dev-redis redis-cli -a homelab_redis_2025
}

redis_info() {
    echo -e "${YELLOW}🔴 Redis Information:${NC}"
    echo ""
    echo "Server Info:"
    docker exec dev-redis redis-cli -a homelab_redis_2025 INFO server 2>/dev/null | grep -E "redis_version|uptime_in_days|os"
    echo ""
    echo "Memory:"
    docker exec dev-redis redis-cli -a homelab_redis_2025 INFO memory 2>/dev/null | grep -E "used_memory_human|used_memory_peak_human"
    echo ""
    echo "Keyspace:"
    docker exec dev-redis redis-cli -a homelab_redis_2025 INFO keyspace 2>/dev/null
    echo ""
    echo "Total Keys:"
    docker exec dev-redis redis-cli -a homelab_redis_2025 DBSIZE 2>/dev/null
}

redis_backup() {
    echo -e "${YELLOW}🔴 Backing up Redis...${NC}"
    docker exec dev-redis redis-cli -a homelab_redis_2025 SAVE > /dev/null 2>&1
    BACKUP_FILE="/tmp/redis_quickbackup_$(date +%Y%m%d_%H%M%S).rdb"
    docker cp dev-redis:/data/dump.rdb "$BACKUP_FILE"
    gzip "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backup saved: ${BACKUP_FILE}.gz${NC}"
    ls -lh "${BACKUP_FILE}.gz"
}

redis_reset() {
    echo -e "${RED}⚠️  WARNING: This will delete ALL keys in Redis!${NC}"
    echo ""
    read -p "Type 'DELETE ALL KEYS' to confirm: " CONFIRM
    
    if [ "$CONFIRM" != "DELETE ALL KEYS" ]; then
        echo -e "${YELLOW}Operation cancelled.${NC}"
        return
    fi
    
    echo -e "${YELLOW}🔴 Resetting Redis...${NC}"
    docker exec dev-redis redis-cli -a homelab_redis_2025 FLUSHALL 2>/dev/null
    echo -e "${GREEN}✓ Redis reset complete (all keys deleted)${NC}"
}

# MongoDB commands
mongo_shell() {
    if ! docker ps --format '{{.Names}}' | grep -q "^dev-mongo$"; then
        echo -e "${RED}✗ MongoDB is not running${NC}"
        echo -e "${YELLOW}💡 Start backend profile to use MongoDB${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}🍃 Opening MongoDB shell...${NC}"
    echo -e "${BLUE}💡 Type 'exit' or Ctrl+D to quit${NC}"
    echo ""
    docker exec -it dev-mongo mongosh -u admin -p homelab_mongo_2025 --authenticationDatabase admin
}

mongo_info() {
    if ! docker ps --format '{{.Names}}' | grep -q "^dev-mongo$"; then
        echo -e "${RED}✗ MongoDB is not running${NC}"
        echo -e "${YELLOW}💡 Start backend profile to use MongoDB${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}🍃 MongoDB Information:${NC}"
    echo ""
    docker exec dev-mongo mongosh --quiet -u admin -p homelab_mongo_2025 --authenticationDatabase admin --eval "
        print('Version: ' + version());
        print('');
        print('Databases:');
        db.adminCommand('listDatabases').databases.forEach(function(db) {
            print('  - ' + db.name + ': ' + (db.sizeOnDisk / 1024 / 1024).toFixed(2) + ' MB');
        });
    "
}

mongo_backup() {
    if ! docker ps --format '{{.Names}}' | grep -q "^dev-mongo$"; then
        echo -e "${RED}✗ MongoDB is not running${NC}"
        return 1
    fi
    
    BACKUP_DIR="/tmp/mongo_quickbackup_$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}🍃 Backing up MongoDB...${NC}"
    docker exec dev-mongo mongodump -u admin -p homelab_mongo_2025 --authenticationDatabase admin --out /tmp/backup > /dev/null 2>&1
    docker cp dev-mongo:/tmp/backup "$BACKUP_DIR"
    tar -czf "${BACKUP_DIR}.tar.gz" -C /tmp "$(basename $BACKUP_DIR)"
    rm -rf "$BACKUP_DIR"
    echo -e "${GREEN}✓ Backup saved: ${BACKUP_DIR}.tar.gz${NC}"
    ls -lh "${BACKUP_DIR}.tar.gz"
}

# Main script
DATABASE=$1
COMMAND=$2

if [ -z "$DATABASE" ] || [ -z "$COMMAND" ]; then
    show_usage
    exit 0
fi

case $DATABASE in
    postgres|postgresql|pg)
        case $COMMAND in
            shell|cli) postgres_shell ;;
            info|status) postgres_info ;;
            backup) postgres_backup ;;
            reset) postgres_reset ;;
            *) echo -e "${RED}Unknown command: $COMMAND${NC}"; show_usage; exit 1 ;;
        esac
        ;;
    redis)
        case $COMMAND in
            shell|cli) redis_shell ;;
            info|status) redis_info ;;
            backup) redis_backup ;;
            reset) redis_reset ;;
            *) echo -e "${RED}Unknown command: $COMMAND${NC}"; show_usage; exit 1 ;;
        esac
        ;;
    mongo|mongodb)
        case $COMMAND in
            shell|cli) mongo_shell ;;
            info|status) mongo_info ;;
            backup) mongo_backup ;;
            *) echo -e "${RED}Unknown command: $COMMAND${NC}"; show_usage; exit 1 ;;
        esac
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown database: $DATABASE${NC}"
        show_usage
        exit 1
        ;;
esac

#!/bin/bash
# Service Health Monitoring Script (Production Ready)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

COMPOSE_DIR="/mnt/e/development/infrastructure/docker/compose"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🏥 Home Lab Health Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Check Docker daemon
echo -e "${YELLOW}🐳 Docker Daemon Status:${NC}"
if sudo service docker status > /dev/null 2>&1; then
    echo -e "${GREEN}   ✓ Docker is running${NC}"
else
    echo -e "${RED}   ✗ Docker is not running${NC}"
    exit 1
fi

# Check container health
echo ""
echo -e "${YELLOW}📦 Container Health Status:${NC}"

cd "$COMPOSE_DIR"

RUNNING_CONTAINERS=$(docker ps --format '{{.Names}}' 2>/dev/null)

if [ -z "$RUNNING_CONTAINERS" ]; then
    echo -e "${YELLOW}   ⊘ No containers running${NC}"
else
    echo "$RUNNING_CONTAINERS" | while read -r container; do
        STATUS=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null)
        HEALTH=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$container" 2>/dev/null)
        
        if [ "$HEALTH" = "healthy" ]; then
            echo -e "${GREEN}   ✓ $container: $STATUS (healthy)${NC}"
        elif [ "$HEALTH" = "unhealthy" ]; then
            echo -e "${RED}   ✗ $container: $STATUS (unhealthy)${NC}"
        else
            echo -e "${GREEN}   ✓ $container: $STATUS${NC}"
        fi
    done
fi

# Check service connectivity
echo ""
echo -e "${YELLOW}🌐 Service Connectivity:${NC}"

# PostgreSQL
if docker ps --format '{{.Names}}' | grep -q "^dev-postgres$"; then
    if docker exec dev-postgres pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}   ✓ PostgreSQL: accepting connections${NC}"
    else
        echo -e "${RED}   ✗ PostgreSQL: not accepting connections${NC}"
    fi
fi

# Redis
if docker ps --format '{{.Names}}' | grep -q "^dev-redis$"; then
    if docker exec dev-redis redis-cli -a homelab_redis_2025 PING 2>/dev/null | grep -q "PONG"; then
        echo -e "${GREEN}   ✓ Redis: responding to PING${NC}"
    else
        echo -e "${RED}   ✗ Redis: not responding${NC}"
    fi
fi

# MongoDB
if docker ps --format '{{.Names}}' | grep -q "^dev-mongo$"; then
    echo -e "${GREEN}   ✓ MongoDB: container running${NC}"
fi

# Check resource usage
echo ""
echo -e "${YELLOW}💾 Resource Usage:${NC}"

# WSL2 Memory
MEM_INFO=$(free -h | grep Mem)
MEM_USED=$(echo "$MEM_INFO" | awk '{print $3}')
MEM_TOTAL=$(echo "$MEM_INFO" | awk '{print $2}')
echo "   WSL2 Memory: $MEM_USED / $MEM_TOTAL"

# Disk usage
DISK_INFO=$(df -h /mnt/e/development | tail -1)
DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')
DISK_TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
DISK_PERCENT=$(echo "$DISK_INFO" | awk '{print $5}')
echo "   Disk Usage: $DISK_USED / $DISK_TOTAL ($DISK_PERCENT)"

# Docker disk usage
echo ""
echo "   Docker Storage:"
docker system df --format "   {{.Type}}: {{.Size}} ({{.Reclaimable}} reclaimable)"

# Check active ports
echo ""
echo -e "${YELLOW}🔌 Active Service Ports:${NC}"

# Get all exposed ports from running containers
ACTIVE_PORTS=$(docker ps --format '{{.Ports}}' 2>/dev/null)

check_port() {
    local PORT=$1
    local SERVICE=$2
    
    if echo "$ACTIVE_PORTS" | grep -q "0.0.0.0:$PORT->"; then
        echo -e "${GREEN}   ✓ Port $PORT: $SERVICE (listening)${NC}"
    fi
}

check_port "5432" "PostgreSQL"
check_port "6379" "Redis"
check_port "5050" "pgAdmin"
check_port "8082" "Redis Commander"
check_port "27017" "MongoDB"
check_port "8081" "Mongo Express"
check_port "9092" "Kafka"
check_port "8090" "Kafka UI"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Health check complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

exit 0

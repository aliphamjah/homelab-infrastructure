#!/bin/bash
# Home Lab Health Check (Simplified & Reliable)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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
    echo -e "${RED}ERROR: .env file not found at $ENV_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🏥 Home Lab Health Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

cd "$COMPOSE_DIR" || exit 1

# Check 1: Docker Daemon
echo -e "${BLUE}🐳 Docker Daemon Status:${NC}"
if docker info > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓ Docker is running${NC}"
else
    echo -e "  ${RED}✗ Docker is not running${NC}"
    exit 1
fi

echo ""

# Check 2: Container Status
echo -e "${YELLOW}📦 Container Health Status:${NC}"
RUNNING=$(docker ps -q | wc -l)

if [ "$RUNNING" -eq 0 ]; then
    echo -e "  ${YELLOW}⊘ No containers running${NC}"
else
    echo "  Found $RUNNING running containers"
    echo ""
    
    # List all running containers with status
    docker ps --format "table {{.Names}}\t{{.Status}}" | tail -n +2 | while IFS=$'\t' read -r name status; do
        if [[ "$status" == *"healthy"* ]]; then
            echo -e "  ${GREEN}✓ $name (healthy)${NC}"
        elif [[ "$status" == *"starting"* ]]; then
            echo -e "  ${YELLOW}⟳ $name (starting)${NC}"
        elif [[ "$status" == *"Up"* ]]; then
            echo -e "  ${GREEN}✓ $name (running)${NC}"
        else
            echo -e "  ${RED}✗ $name ($status)${NC}"
        fi
    done
fi

echo ""

# Check 3: Service Connectivity (only if containers running)
if [ "$RUNNING" -gt 0 ]; then
    echo -e "${BLUE}🌐 Service Connectivity:${NC}"
    
    # PostgreSQL
    if docker ps --format '{{.Names}}' | grep -q "dev-postgres"; then
        if timeout 3 docker exec dev-postgres pg_isready -U "${POSTGRES_USER}" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓ PostgreSQL responding${NC}"
        else
            echo -e "  ${YELLOW}⟳ PostgreSQL not ready yet${NC}"
        fi
    fi
    
    # Redis
    if docker ps --format '{{.Names}}' | grep -q "dev-redis"; then
        if timeout 3 docker exec dev-redis redis-cli -a "${REDIS_PASSWORD}" ping > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓ Redis responding${NC}"
        else
            echo -e "  ${YELLOW}⟳ Redis not ready yet${NC}"
        fi
    fi
    
    # MongoDB
    if docker ps --format '{{.Names}}' | grep -q "dev-mongo"; then
        if timeout 3 docker exec dev-mongo mongosh --quiet --eval "db.adminCommand('ping').ok" -u "${MONGO_INITDB_ROOT_USERNAME}" -p "${MONGO_INITDB_ROOT_PASSWORD}" --authenticationDatabase admin > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓ MongoDB responding${NC}"
        else
            echo -e "  ${YELLOW}⟳ MongoDB not ready yet${NC}"
        fi
    fi
    
    echo ""
fi

# Check 4: Resource Usage
echo -e "${BLUE}💾 Resource Usage:${NC}"
MEM_INFO=$(free -h | grep Mem)
MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
MEM_FREE=$(echo $MEM_INFO | awk '{print $4}')
echo "  WSL2 Memory: $MEM_USED / $MEM_TOTAL (Free: $MEM_FREE)"

DISK_INFO=$(df -h /mnt/e | tail -1)
DISK_TOTAL=$(echo $DISK_INFO | awk '{print $2}')
DISK_USED=$(echo $DISK_INFO | awk '{print $3}')
DISK_PERCENT=$(echo $DISK_INFO | awk '{print $5}')
echo "  Disk Usage: $DISK_USED / $DISK_TOTAL ($DISK_PERCENT)"

echo ""
echo "  Docker Storage:"
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{Size}}" 2>/dev/null || docker system df

echo ""

# Check 5: Active Ports
echo -e "${BLUE}📡 Active Service Ports:${NC}"
if [ "$RUNNING" -gt 0 ]; then
    docker ps --format "  {{.Names}}: {{.Ports}}" | sed 's/0.0.0.0://g' | sed 's/->/→/g'
else
    echo "  No services running"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$RUNNING" -eq 0 ]; then
    echo -e "${YELLOW}⊘ No services running${NC}"
else
    echo -e "${GREEN}✅ Health check complete!${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

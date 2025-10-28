#!/bin/bash
# Comprehensive System Test Script (Fixed)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
FAIL=0

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧪 HOME LAB COMPREHENSIVE TEST${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

test_pass() {
    echo -e "${GREEN}   ✓ $1${NC}"
    ((PASS++))
}

test_fail() {
    echo -e "${RED}   ✗ $1${NC}"
    ((FAIL++))
}

# Test 1: Docker Daemon
echo -e "${YELLOW}1️⃣  Testing Docker Daemon...${NC}"
if sudo service docker status > /dev/null 2>&1; then
    test_pass "Docker daemon is running"
else
    test_fail "Docker daemon is not running"
fi

# Test 2: Docker Compose
echo ""
echo -e "${YELLOW}2️⃣  Testing Docker Compose...${NC}"
if docker compose version > /dev/null 2>&1; then
    VERSION=$(docker compose version --short)
    test_pass "Docker Compose installed (v$VERSION)"
else
    test_fail "Docker Compose not working"
fi

# Test 3: Networks (check if they exist, any name)
echo ""
echo -e "${YELLOW}3️⃣  Testing Docker Networks...${NC}"
NETWORKS=("dev-network" "kafka-network" "monitoring-network")
for net in "${NETWORKS[@]}"; do
    if docker network ls | grep -q "$net"; then
        test_pass "Network exists: $net"
    else
        test_fail "Network missing: $net"
    fi
done

# Test 4: Running Containers
echo ""
echo -e "${YELLOW}4️⃣  Testing Running Containers...${NC}"
EXPECTED_CONTAINERS=("dev-postgres" "dev-redis" "dev-pgadmin" "dev-redis-commander")
for container in "${EXPECTED_CONTAINERS[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^$container$"; then
        STATUS=$(docker inspect --format='{{.State.Status}}' "$container")
        if [ "$STATUS" = "running" ]; then
            test_pass "Container running: $container"
        else
            test_fail "Container not running: $container (status: $STATUS)"
        fi
    else
        test_fail "Container not found: $container"
    fi
done

# Test 5: Container Health
echo ""
echo -e "${YELLOW}5️⃣  Testing Container Health Checks...${NC}"
for container in "dev-postgres" "dev-redis"; do
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null)
    if [ "$HEALTH" = "healthy" ]; then
        test_pass "Health check passed: $container"
    else
        test_fail "Health check failed: $container (status: $HEALTH)"
    fi
done

# Test 6: Service Connectivity
echo ""
echo -e "${YELLOW}6️⃣  Testing Service Connectivity...${NC}"

# PostgreSQL
if docker exec dev-postgres pg_isready -U postgres > /dev/null 2>&1; then
    test_pass "PostgreSQL accepting connections"
else
    test_fail "PostgreSQL not accepting connections"
fi

# Redis
if docker exec dev-redis redis-cli -a homelab_redis_2025 PING 2>/dev/null | grep -q "PONG"; then
    test_pass "Redis responding to commands"
else
    test_fail "Redis not responding"
fi

# Test 7: Port Accessibility
echo ""
echo -e "${YELLOW}7️⃣  Testing Port Accessibility...${NC}"
PORTS=("5432:PostgreSQL" "6379:Redis" "5050:pgAdmin" "8082:Redis Commander")
for port_info in "${PORTS[@]}"; do
    PORT="${port_info%%:*}"
    SERVICE="${port_info##*:}"
    if docker ps --format '{{.Ports}}' | grep -q "0.0.0.0:$PORT->"; then
        test_pass "Port $PORT accessible ($SERVICE)"
    else
        test_fail "Port $PORT not accessible ($SERVICE)"
    fi
done

# Test 8: Data Persistence
echo ""
echo -e "${YELLOW}8️⃣  Testing Data Persistence...${NC}"

# Check PostgreSQL data
TABLE_COUNT=$(docker exec dev-postgres psql -U postgres -d homelab -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null | xargs)
if [ "$TABLE_COUNT" -gt 0 ]; then
    test_pass "PostgreSQL data persisted ($TABLE_COUNT tables)"
else
    test_fail "PostgreSQL data not persisted"
fi

# Check Redis data
KEY_COUNT=$(docker exec dev-redis redis-cli -a homelab_redis_2025 DBSIZE 2>/dev/null | xargs)
if [ "$KEY_COUNT" -gt 0 ]; then
    test_pass "Redis data persisted ($KEY_COUNT keys)"
else
    test_fail "Redis data not persisted"
fi

# Test 9: Docker Volumes (check actual volumes used by containers)
echo ""
echo -e "${YELLOW}9️⃣  Testing Docker Volumes...${NC}"

# Get actual volume names from running containers
POSTGRES_VOL=$(docker inspect dev-postgres --format='{{range .Mounts}}{{if eq .Type "volume"}}{{.Name}}{{end}}{{end}}' 2>/dev/null)
REDIS_VOL=$(docker inspect dev-redis --format='{{range .Mounts}}{{if eq .Type "volume"}}{{.Name}}{{end}}{{end}}' 2>/dev/null)
PGADMIN_VOL=$(docker inspect dev-pgadmin --format='{{range .Mounts}}{{if eq .Type "volume"}}{{.Name}}{{end}}{{end}}' 2>/dev/null)

if [ -n "$POSTGRES_VOL" ]; then
    test_pass "PostgreSQL volume: $POSTGRES_VOL"
else
    test_fail "PostgreSQL volume not found"
fi

if [ -n "$REDIS_VOL" ]; then
    test_pass "Redis volume: $REDIS_VOL"
else
    test_fail "Redis volume not found"
fi

if [ -n "$PGADMIN_VOL" ]; then
    test_pass "pgAdmin volume: $PGADMIN_VOL"
else
    test_fail "pgAdmin volume not found"
fi

# Test 10: Scripts Availability
echo ""
echo -e "${YELLOW}🔟 Testing Automation Scripts...${NC}"
SCRIPTS=(
    "start-lab.sh"
    "stop-lab.sh"
    "status-lab.sh"
    "backup-databases.sh"
    "health-check.sh"
    "cleanup.sh"
    "maintenance.sh"
    "db-helper.sh"
    "logs.sh"
    "setup-cron.sh"
    "test-all.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -x "/mnt/e/development/infrastructure/scripts/$script" ]; then
        test_pass "Script available: $script"
    else
        test_fail "Script missing or not executable: $script"
    fi
done

# Test 11: Backup Directory
echo ""
echo -e "${YELLOW}1️⃣1️⃣  Testing Backup System...${NC}"
BACKUP_DIRS=("daily" "weekly" "monthly")
for dir in "${BACKUP_DIRS[@]}"; do
    if [ -d "/mnt/e/development/data/backups/$dir" ]; then
        test_pass "Backup directory exists: $dir"
    else
        test_fail "Backup directory missing: $dir"
    fi
done

# Test 12: Resource Usage
echo ""
echo -e "${YELLOW}1️⃣2️⃣  Testing Resource Usage...${NC}"

MEM_USED=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
if [ "$MEM_USED" -lt 80 ]; then
    test_pass "Memory usage healthy (${MEM_USED}%)"
else
    test_fail "Memory usage high (${MEM_USED}%)"
fi

DISK_USED=$(df /mnt/e/development | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USED" -lt 80 ]; then
    test_pass "Disk usage healthy (${DISK_USED}%)"
else
    test_fail "Disk usage high (${DISK_USED}%)"
fi

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📊 TEST RESULTS SUMMARY${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Tests Passed:  ${GREEN}$PASS${NC}"
echo -e "Tests Failed:  ${RED}$FAIL${NC}"
echo -e "Total Tests:   $((PASS + FAIL))"
echo ""

if [ $((PASS + FAIL)) -gt 0 ]; then
    PASS_RATE=$(awk "BEGIN {printf \"%.1f\", $PASS * 100 / ($PASS + $FAIL)}")
    echo -e "Pass Rate:     ${PASS_RATE}%"
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED - SYSTEM READY!${NC}"
    EXIT_CODE=0
else
    echo -e "${YELLOW}⚠️  SOME TESTS FAILED - REVIEW NEEDED${NC}"
    EXIT_CODE=1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Finished: $(date '+%Y-%m-%d %H:%M:%S')"

exit $EXIT_CODE

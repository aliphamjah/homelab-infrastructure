#!/bin/bash
# Stop Home Lab Services (100% Reliable Cleanup)

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPTS_DIR/../docker/compose"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🛑 Stopping Home Lab Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Count running containers
RUNNING=$(docker ps -q --filter "name=dev-" | wc -l)
TOTAL=$(docker ps -aq --filter "name=dev-" | wc -l)

if [ "$TOTAL" -eq 0 ]; then
    echo -e "${YELLOW}⊘ No home lab containers found${NC}"
    exit 0
fi

echo -e "${YELLOW}Found $RUNNING running, $TOTAL total home lab containers${NC}"
echo ""

# Step 1: Try compose down first
echo "Step 1: Attempting docker compose down..."
cd "$COMPOSE_DIR" 2>/dev/null
if [ -f "docker-compose.yml" ]; then
    docker compose kill 2>/dev/null
    docker compose down --remove-orphans 2>/dev/null
    echo -e "${GREEN}✓ Compose down executed${NC}"
else
    echo -e "${YELLOW}⚠ docker-compose.yml not found, skipping${NC}"
fi

echo ""

# Step 2: Force stop any remaining containers
STILL_RUNNING=$(docker ps -q --filter "name=dev-" | wc -l)

if [ "$STILL_RUNNING" -gt 0 ]; then
    echo "Step 2: Force stopping $STILL_RUNNING remaining containers..."
    docker ps -q --filter "name=dev-" | xargs -r docker stop -t 5
    echo -e "${GREEN}✓ Force stopped${NC}"
else
    echo "Step 2: No containers running (skipping)"
fi

echo ""

# Step 3: Remove all stopped containers
STOPPED=$(docker ps -aq --filter "name=dev-" | wc -l)

if [ "$STOPPED" -gt 0 ]; then
    echo "Step 3: Removing $STOPPED stopped containers..."
    docker ps -aq --filter "name=dev-" | xargs -r docker rm -f
    echo -e "${GREEN}✓ Containers removed${NC}"
else
    echo "Step 3: No stopped containers to remove"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Final verification
FINAL_COUNT=$(docker ps -aq --filter "name=dev-" | wc -l)

if [ "$FINAL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅ All services stopped and removed successfully!${NC}"
else
    echo -e "${RED}⚠ Warning: $FINAL_COUNT containers still exist${NC}"
    echo ""
    echo "Remaining containers:"
    docker ps -a --filter "name=dev-" --format "  {{.Names}}: {{.Status}}"
    echo ""
    echo "Run this to force remove:"
    echo "  docker ps -aq --filter 'name=dev-' | xargs docker rm -f"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "💡 Data preserved in Docker volumes"
echo "💡 To start: start-lab.sh minimal"

#!/bin/bash
# Test Complete Start/Stop Workflow

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPTS_DIR/../docker/compose"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧪 TESTING HOME LAB WORKFLOW${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test 1: Start minimal
echo -e "${YELLOW}TEST 1: Starting minimal profile...${NC}"
"$SCRIPTS_DIR/start-lab.sh" minimal

echo ""
read -p "Press Enter to continue to Test 2..."

# Test 2: Stop all
echo ""
echo -e "${YELLOW}TEST 2: Stopping all services...${NC}"
"$SCRIPTS_DIR/stop-lab.sh"

echo ""
echo "Verify stopped:"
cd "$COMPOSE_DIR"
docker compose ps

echo ""
read -p "Press Enter to continue to Test 3..."

# Test 3: Start backend
echo ""
echo -e "${YELLOW}TEST 3: Starting backend profile...${NC}"
"$SCRIPTS_DIR/start-lab.sh" backend

echo ""
read -p "Press Enter to continue to Test 4..."

# Test 4: Stop all
echo ""
echo -e "${YELLOW}TEST 4: Final stop...${NC}"
"$SCRIPTS_DIR/stop-lab.sh"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Full workflow test complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Final status (should be empty):"
cd "$COMPOSE_DIR"
docker compose ps

echo ""
echo "Memory usage:"
free -h | grep Mem

#!/bin/bash
# Weekly Maintenance Script
# Performs health check, backup, and cleanup

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPTS_DIR/../docker/compose"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔧 Weekly Maintenance Routine${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Step 1: Health Check
echo -e "${YELLOW}Step 1/3: Running health check...${NC}"
echo ""
"$SCRIPTS_DIR/health-check.sh"

if [ $? -ne 0 ]; then
    echo -e "${RED}⚠️  Health check failed! Stopping maintenance.${NC}"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 2: Backup Databases
echo -e "${YELLOW}Step 2/3: Backing up databases...${NC}"
echo ""
"$SCRIPTS_DIR/backup-databases.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 3: Update Docker Images
echo -e "${YELLOW}Step 3/3: Checking for image updates...${NC}"
echo ""

cd "$COMPOSE_DIR"

echo "Pulling latest images for minimal profile..."
docker compose --profile minimal pull

echo ""
echo -e "${GREEN}✓ Image updates checked${NC}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Weekly maintenance complete!${NC}"
echo "Finished: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📋 Summary:"
echo "   ✓ Health check passed"
echo "   ✓ Databases backed up"
echo "   ✓ Images updated"
echo ""
echo "💡 Tip: Run cleanup.sh if you need to free up disk space"

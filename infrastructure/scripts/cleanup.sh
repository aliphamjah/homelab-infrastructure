#!/bin/bash
# Docker Cleanup Script
# Removes unused containers, images, volumes, and networks

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧹 Docker Cleanup Script${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Show current usage before cleanup
echo -e "${YELLOW}📊 Current Docker Storage Usage:${NC}"
docker system df
echo ""

# Ask for confirmation
echo -e "${YELLOW}⚠️  This will remove:${NC}"
echo "   • Stopped containers"
echo "   • Unused images"
echo "   • Unused volumes"
echo "   • Unused networks"
echo "   • Build cache"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cleanup cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}🗑️  Removing stopped containers...${NC}"
STOPPED=$(docker container prune -f 2>&1 | grep "Total reclaimed space" | awk '{print $4 " " $5}')
echo -e "${GREEN}   ✓ Reclaimed: $STOPPED${NC}"

echo ""
echo -e "${YELLOW}🗑️  Removing unused images...${NC}"
IMAGES=$(docker image prune -a -f 2>&1 | grep "Total reclaimed space" | awk '{print $4 " " $5}')
echo -e "${GREEN}   ✓ Reclaimed: $IMAGES${NC}"

echo ""
echo -e "${YELLOW}🗑️  Removing unused volumes...${NC}"
VOLUMES=$(docker volume prune -f 2>&1 | grep "Total reclaimed space" | awk '{print $4 " " $5}')
echo -e "${GREEN}   ✓ Reclaimed: $VOLUMES${NC}"

echo ""
echo -e "${YELLOW}🗑️  Removing unused networks...${NC}"
docker network prune -f > /dev/null 2>&1
echo -e "${GREEN}   ✓ Networks cleaned${NC}"

echo ""
echo -e "${YELLOW}🗑️  Removing build cache...${NC}"
CACHE=$(docker builder prune -a -f 2>&1 | grep "Total" | awk '{print $3 " " $4}')
echo -e "${GREEN}   ✓ Reclaimed: $CACHE${NC}"

echo ""
echo -e "${YELLOW}📊 Docker Storage After Cleanup:${NC}"
docker system df

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

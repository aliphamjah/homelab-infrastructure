#!/bin/bash
# Setup Cron Jobs for Automated Maintenance

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}⏰ Cron Jobs Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}📋 Recommended Cron Schedule:${NC}"
echo ""
echo "1. Daily Backup (2 AM)"
echo "   Runs: backup-databases.sh"
echo "   Frequency: Every day at 2:00 AM"
echo ""
echo "2. Weekly Maintenance (Sunday 3 AM)"
echo "   Runs: maintenance.sh"
echo "   Frequency: Every Sunday at 3:00 AM"
echo ""
echo "3. Hourly Health Check"
echo "   Runs: health-check.sh"
echo "   Frequency: Every hour"
echo ""

read -p "Do you want to setup these cron jobs? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cron setup skipped.${NC}"
    echo ""
    echo -e "${BLUE}💡 Manual Cron Setup:${NC}"
    echo "Run: crontab -e"
    echo "Then add these lines:"
    echo ""
    echo "# Home Lab Automated Tasks"
    echo "0 2 * * * $SCRIPTS_DIR/backup-databases.sh >> $SCRIPTS_DIR/../logs/backup.log 2>&1"
    echo "0 3 * * 0 $SCRIPTS_DIR/maintenance.sh >> $SCRIPTS_DIR/../logs/maintenance.log 2>&1"
    echo "0 * * * * $SCRIPTS_DIR/health-check.sh >> $SCRIPTS_DIR/../logs/health.log 2>&1"
    exit 0
fi

# Create logs directory
mkdir -p "$SCRIPTS_DIR/../logs"

# Create temporary crontab file
TEMP_CRON=$(mktemp)

# Get existing crontab (if any)
crontab -l > "$TEMP_CRON" 2>/dev/null || true

# Check if our jobs already exist
if grep -q "Home Lab Automated Tasks" "$TEMP_CRON"; then
    echo -e "${YELLOW}⚠️  Cron jobs already configured!${NC}"
    echo ""
    read -p "Replace existing jobs? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Keeping existing configuration.${NC}"
        rm "$TEMP_CRON"
        exit 0
    fi
    
    # Remove old jobs
    sed -i '/# Home Lab Automated Tasks/,+3d' "$TEMP_CRON"
fi

# Add our cron jobs
cat >> "$TEMP_CRON" << CRON

# Home Lab Automated Tasks
0 2 * * * $SCRIPTS_DIR/backup-databases.sh >> $SCRIPTS_DIR/../logs/backup.log 2>&1
0 3 * * 0 $SCRIPTS_DIR/maintenance.sh >> $SCRIPTS_DIR/../logs/maintenance.log 2>&1
0 * * * * $SCRIPTS_DIR/health-check.sh >> $SCRIPTS_DIR/../logs/health.log 2>&1
CRON

# Install the new crontab
crontab "$TEMP_CRON"
rm "$TEMP_CRON"

echo ""
echo -e "${GREEN}✅ Cron jobs installed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Scheduled Tasks:${NC}"
crontab -l | grep -A 3 "Home Lab Automated Tasks"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}⏰ Automation Setup Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📊 View Logs:"
echo "  Backup:      tail -f $SCRIPTS_DIR/../logs/backup.log"
echo "  Maintenance: tail -f $SCRIPTS_DIR/../logs/maintenance.log"
echo "  Health:      tail -f $SCRIPTS_DIR/../logs/health.log"
echo ""
echo "🔧 Manage Cron:"
echo "  View:   crontab -l"
echo "  Edit:   crontab -e"
echo "  Remove: crontab -r"

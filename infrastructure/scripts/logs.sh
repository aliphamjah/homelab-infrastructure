#!/bin/bash
# Container Logs Management Script

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPTS_DIR/../docker/compose"

# Show usage
show_usage() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📋 Container Logs Management${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  view [service]       - View logs (default: all services)"
    echo "  follow [service]     - Follow logs in real-time"
    echo "  tail [service] [n]   - Show last n lines (default: 50)"
    echo "  errors [service]     - Show only errors"
    echo "  clear [service]      - Clear logs (WARNING: destructive!)"
    echo "  size                 - Show log file sizes"
    echo ""
    echo "Examples:"
    echo "  $0 view postgres           # View postgres logs"
    echo "  $0 follow redis            # Follow redis logs"
    echo "  $0 tail postgres 100       # Last 100 lines of postgres"
    echo "  $0 errors                  # Show all errors"
    echo "  $0 size                    # Check log sizes"
    echo ""
}

# Get running containers
get_containers() {
    cd "$COMPOSE_DIR"
    docker compose ps --format '{{.Name}}' 2>/dev/null
}

# View logs
view_logs() {
    local SERVICE=$1
    cd "$COMPOSE_DIR"
    
    if [ -z "$SERVICE" ]; then
        echo -e "${YELLOW}📋 Viewing all container logs...${NC}"
        echo ""
        docker compose logs
    else
        echo -e "${YELLOW}📋 Viewing logs for: $SERVICE${NC}"
        echo ""
        docker compose logs "$SERVICE"
    fi
}

# Follow logs
follow_logs() {
    local SERVICE=$1
    cd "$COMPOSE_DIR"
    
    if [ -z "$SERVICE" ]; then
        echo -e "${YELLOW}📋 Following all container logs (Ctrl+C to stop)...${NC}"
        echo ""
        docker compose logs -f
    else
        echo -e "${YELLOW}📋 Following logs for: $SERVICE (Ctrl+C to stop)${NC}"
        echo ""
        docker compose logs -f "$SERVICE"
    fi
}

# Tail logs
tail_logs() {
    local SERVICE=$1
    local LINES=${2:-50}
    cd "$COMPOSE_DIR"
    
    if [ -z "$SERVICE" ]; then
        echo -e "${YELLOW}📋 Last $LINES lines from all containers...${NC}"
        echo ""
        docker compose logs --tail="$LINES"
    else
        echo -e "${YELLOW}📋 Last $LINES lines from: $SERVICE${NC}"
        echo ""
        docker compose logs --tail="$LINES" "$SERVICE"
    fi
}

# Show errors only
show_errors() {
    local SERVICE=$1
    cd "$COMPOSE_DIR"
    
    if [ -z "$SERVICE" ]; then
        echo -e "${YELLOW}🔍 Searching for errors in all containers...${NC}"
        echo ""
        docker compose logs 2>&1 | grep -iE "error|exception|fatal|fail" | head -50
    else
        echo -e "${YELLOW}🔍 Searching for errors in: $SERVICE${NC}"
        echo ""
        docker compose logs "$SERVICE" 2>&1 | grep -iE "error|exception|fatal|fail" | head -50
    fi
    
    echo ""
    echo -e "${BLUE}(Showing max 50 lines)${NC}"
}

# Show log sizes
show_sizes() {
    echo -e "${YELLOW}📊 Container Log Sizes:${NC}"
    echo ""
    
    CONTAINERS=$(get_containers)
    
    if [ -z "$CONTAINERS" ]; then
        echo -e "${YELLOW}   ⊘ No running containers${NC}"
        return
    fi
    
    echo "$CONTAINERS" | while read -r container; do
        # Get container log file path
        LOG_PATH=$(docker inspect --format='{{.LogPath}}' "$container" 2>/dev/null)
        
        if [ -n "$LOG_PATH" ] && [ -f "$LOG_PATH" ]; then
            SIZE=$(sudo du -h "$LOG_PATH" | cut -f1)
            echo -e "${GREEN}   $container: $SIZE${NC}"
        fi
    done
    
    echo ""
    echo -e "${BLUE}💡 Tip: Logs are auto-rotated at 10MB (max 3 files per container)${NC}"
}

# Clear logs (dangerous!)
clear_logs() {
    local SERVICE=$1
    
    echo -e "${RED}⚠️  WARNING: This will permanently delete log data!${NC}"
    echo ""
    
    if [ -z "$SERVICE" ]; then
        echo "This will clear logs for ALL containers."
    else
        echo "This will clear logs for: $SERVICE"
    fi
    
    echo ""
    read -p "Are you sure? Type 'yes' to confirm: " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${YELLOW}Operation cancelled.${NC}"
        return
    fi
    
    echo ""
    echo -e "${YELLOW}🗑️  Clearing logs...${NC}"
    
    CONTAINERS=$(get_containers)
    
    if [ -z "$SERVICE" ]; then
        # Clear all
        echo "$CONTAINERS" | while read -r container; do
            LOG_PATH=$(docker inspect --format='{{.LogPath}}' "$container" 2>/dev/null)
            if [ -n "$LOG_PATH" ] && [ -f "$LOG_PATH" ]; then
                sudo truncate -s 0 "$LOG_PATH"
                echo -e "${GREEN}   ✓ Cleared: $container${NC}"
            fi
        done
    else
        # Clear specific service
        LOG_PATH=$(docker inspect --format='{{.LogPath}}' "dev-$SERVICE" 2>/dev/null)
        if [ -n "$LOG_PATH" ] && [ -f "$LOG_PATH" ]; then
            sudo truncate -s 0 "$LOG_PATH"
            echo -e "${GREEN}   ✓ Cleared: $SERVICE${NC}"
        else
            echo -e "${RED}   ✗ Container not found: $SERVICE${NC}"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}✅ Logs cleared!${NC}"
}

# Main script logic
COMMAND=${1:-view}
SERVICE=$2
LINES=$3

case $COMMAND in
    view)
        view_logs "$SERVICE"
        ;;
    follow|f)
        follow_logs "$SERVICE"
        ;;
    tail|t)
        tail_logs "$SERVICE" "$LINES"
        ;;
    errors|e)
        show_errors "$SERVICE"
        ;;
    size|s)
        show_sizes
        ;;
    clear)
        clear_logs "$SERVICE"
        ;;
    help|h|--help|-h)
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac

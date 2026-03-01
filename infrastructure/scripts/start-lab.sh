#!/bin/bash
# Start Home Lab Services

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPTS_DIR/../docker/compose"

show_usage() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🚀 Start Home Lab Services${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Usage: $0 [profile]"
    echo ""
    echo "Profiles:"
    echo "  minimal    - PostgreSQL + Redis + UIs (4GB)"
    echo "  backend    - minimal + MongoDB + Kafka (8GB)"
    echo "  fullstack  - backend + Elasticsearch + Nginx (14GB)"
    echo ""
    echo "Examples:"
    echo "  $0              # Start minimal (default)"
    echo "  $0 backend      # Start backend profile"
    echo "  $0 fullstack    # Start fullstack profile"
    echo ""
}

start_profile() {
    PROFILE=${1:-minimal}
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🚀 Starting $PROFILE profile${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    cd "$COMPOSE_DIR" || exit 1
    
    # Stop any existing containers first
    RUNNING=$(docker compose ps -q | wc -l)
    if [ "$RUNNING" -gt 0 ]; then
        echo -e "${YELLOW}Stopping existing containers...${NC}"
        docker compose kill
        docker compose down --remove-orphans
        echo ""
    fi
    
    # Start selected profile
    docker compose --profile "$PROFILE" up -d
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ $PROFILE profile started!${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Show status
    docker compose ps
    
    echo ""
    echo "🌐 Services available at:"
    case $PROFILE in
        minimal)
            echo "  PostgreSQL:       localhost:5432"
            echo "  Redis:            localhost:6379"
            echo "  pgAdmin:          http://localhost:5050"
            echo "  Redis Commander:  http://localhost:8082"
            ;;
        backend)
            echo "  PostgreSQL:       localhost:5432"
            echo "  Redis:            localhost:6379"
            echo "  MongoDB:          localhost:27017"
            echo "  Kafka:            localhost:9092"
            echo "  pgAdmin:          http://localhost:5050"
            echo "  Redis Commander:  http://localhost:8082"
            echo "  Mongo Express:    http://localhost:8081"
            echo "  Kafka UI:         http://localhost:8090"
            ;;
        fullstack)
            echo "  All backend services +"
            echo "  Elasticsearch:    localhost:9200"
            echo "  Kibana:           http://localhost:5601"
            echo "  Nginx:            http://localhost:80"
            ;;
    esac
}

# Main
case ${1:-minimal} in
    help|--help|-h)
        show_usage
        ;;
    minimal|backend|fullstack)
        start_profile "$1"
        ;;
    *)
        echo -e "${RED}Unknown profile: $1${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac

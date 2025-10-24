#!/bin/bash
# Home Lab Startup Script

COMPOSE_DIR="/mnt/e/development/infrastructure/docker/compose"
cd "$COMPOSE_DIR"

PROFILE=${1:-minimal}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Starting Home Lab - Profile: $PROFILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

case $PROFILE in
    minimal)
        echo "Starting Minimal profile (PostgreSQL, Redis)..."
        docker compose --profile minimal up -d
        ;;
    backend)
        echo "Starting Backend profile (+ MongoDB, Kafka)..."
        docker compose --profile backend up -d
        ;;
    fullstack)
        echo "Starting Fullstack profile (+ Nginx)..."
        docker compose --profile fullstack up -d
        ;;
    *)
        echo "❌ Invalid profile: $PROFILE"
        echo "Usage: ./start-lab.sh [minimal|backend|fullstack]"
        exit 1
        ;;
esac

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

echo ""
echo "✅ Services started successfully!"
docker compose ps

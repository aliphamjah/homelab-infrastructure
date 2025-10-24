#!/bin/bash
# Home Lab Stop Script

COMPOSE_DIR="/mnt/e/development/infrastructure/docker/compose"
cd "$COMPOSE_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛑 Stopping Home Lab Services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker compose down

echo ""
echo "✅ All services stopped"

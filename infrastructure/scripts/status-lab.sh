#!/bin/bash
# Home Lab Status Script

COMPOSE_DIR="/mnt/e/development/infrastructure/docker/compose"
cd "$COMPOSE_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Home Lab Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🏥 Service Health:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "💾 Resource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}"

echo ""
echo "🌐 Network Info:"
docker network ls | grep -E "dev-network|kafka-network|k8s-network|monitoring-network"

echo ""
echo "💽 Disk Usage:"
docker system df

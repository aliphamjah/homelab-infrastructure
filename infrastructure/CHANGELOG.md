
## [0.2.0] - 2025-10-24

### Added - Phase 5: Base Services Deployment
- Docker Compose configuration with 9 services
- 3 service profiles (minimal, backend, fullstack)
- PostgreSQL 16 + pgAdmin 4
- Redis 7 + Redis Commander
- MongoDB 7 + Mongo Express (backend profile)
- Kafka + Kafka UI (backend profile)
- Nginx reverse proxy (fullstack profile)

### Scripts
- start-lab.sh - Profile-based startup
- stop-lab.sh - Graceful shutdown
- status-lab.sh - Health monitoring

### Documentation
- Services deployment guide
- Credentials reference
- Quick command reference

### Testing
- PostgreSQL: Table creation and queries ✅
- Redis: Key-value operations ✅
- Admin UIs: Accessible via browser ✅

### Performance
- Minimal profile: ~250MB RAM (4 containers)
- All services: Health checks passing
- WSL2 usage: <5% of allocated memory


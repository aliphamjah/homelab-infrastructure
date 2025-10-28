# ⚡ QUICK REFERENCE

## Daily Commands
```bash
start-minimal    # Start minimal profile
start-backend    # Start backend profile
stop-lab         # Stop everything
lab-health       # Health check
dev              # Jump to dev dir
```

## Browser URLs
- pgAdmin: http://localhost:5050 (admin@homelab.local / admin)
- Redis Commander: http://localhost:8082
- Mongo Express: http://localhost:8081 (backend profile)
- Kafka UI: http://localhost:8090 (backend profile)

## Emergency
```bash
# Force stop everything
stop-lab

# Nuclear option
docker stop $(docker ps -q)
docker rm $(docker ps -aq)

# Restart WSL2 (PowerShell)
wsl --shutdown
```

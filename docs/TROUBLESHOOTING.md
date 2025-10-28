# 🔧 Home Lab Troubleshooting Guide

> Common issues and solutions

---

## 🛑 Container Stop Issues

### Problem: `docker compose down` doesn't stop containers

**Symptoms**:
- Containers still running after `docker compose down`
- Services still accessible in browser
- Memory not freed

**Root Cause**:
Docker Compose may not track containers properly if:
- Containers started with `docker run` instead of compose
- Timing issue (down executed too quickly after up)
- Restart policy preventing clean shutdown

**Solution** (RELIABLE METHOD):
```bash
cd /mnt/e/development/infrastructure/docker/compose

# Method 1: Kill + Down (100% reliable)
docker compose kill
docker compose down --remove-orphans

# Verify
docker ps  # Should be empty
```

**Alternative** (Using scripts):
```bash
# Auto-handles all edge cases
/mnt/e/development/infrastructure/scripts/stop-lab.sh
```

**Verification**:
```bash
# Check no containers running
docker ps

# Test service unreachable
curl http://localhost:5050
# Expected: curl: (7) Failed to connect

# Check memory freed
free -h
# WSL2 should show low usage (~500Mi)
```

---

## 🌐 Browser Cache Issues

### Problem: Services still accessible after stop

**Symptom**:
- `docker ps` shows no containers
- But browser still loads pgAdmin/Redis Commander

**Root Cause**: Browser cache

**Solution**:
1. Hard refresh: `Ctrl + Shift + R` (Windows) / `Cmd + Shift + R` (Mac)
2. Clear browser cache
3. Open Incognito/Private mode
4. Close all tabs and restart browser

**Test from terminal** (bypasses cache):
```bash
curl http://localhost:5050
# Should get: Connection refused
```

---

## 💾 Memory Not Freed

### Problem: WSL2 still using high memory after stop

**Check current usage**:
```bash
free -h
```

**If high** (>2GB used after stop):

**Solution 1**: Restart WSL2 (PowerShell as Admin)
```powershell
wsl --shutdown
# Wait 10 seconds
wsl
```

**Solution 2**: Compact WSL2 disk (PowerShell as Admin)
```powershell
wsl --shutdown
diskpart
# In diskpart:
select vdisk file="C:\Users\<YourName>\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu22.04LTS_...\LocalState\ext4.vhdx"
compact vdisk
exit
```

---

## 🔌 Port Already in Use

### Problem: Cannot start service - port in use

**Symptom**:
```
Error: bind: address already in use
```

**Find what's using the port**:
```bash
# Check port 5432 (PostgreSQL)
sudo lsof -i :5432

# Or
sudo netstat -tulnp | grep :5432
```

**Solution**:
```bash
# Kill process using port
sudo kill -9 <PID>

# Or stop all Docker containers
docker stop $(docker ps -q)
```

---

## 🗄️ Database Connection Refused

### Problem: Cannot connect to database

**Check service is running**:
```bash
docker ps | grep dev-postgres
```

**If running, check health**:
```bash
docker exec dev-postgres pg_isready -U postgres
```

**If not healthy, check logs**:
```bash
docker logs dev-postgres
```

**Solution**:
```bash
# Restart container
docker restart dev-postgres

# Or restart entire profile
/mnt/e/development/infrastructure/scripts/stop-lab.sh
/mnt/e/development/infrastructure/scripts/start-lab.sh minimal
```

---

## 📦 Image Pull Failures

### Problem: Cannot pull images

**Symptom**:
```
Error response from daemon: Get https://registry-1.docker.io/v2/: net/http: TLS handshake timeout
```

**Solution 1**: Check internet connection
```bash
ping 8.8.8.8
```

**Solution 2**: Restart Docker daemon
```bash
sudo service docker restart
```

**Solution 3**: Clear Docker cache
```bash
docker system prune -a
```

---

## 🔄 Containers Keep Restarting

### Problem: Containers in restart loop

**Check restart policy**:
```bash
docker inspect dev-postgres --format='{{.HostConfig.RestartPolicy.Name}}'
```

**If "unless-stopped", change to "no"**:
```bash
cd /mnt/e/development/infrastructure/docker/compose
# Edit docker-compose.yml
sed -i 's/restart: unless-stopped/restart: "no"/g' docker-compose.yml
```

---

## 💡 Best Practices Learned

### ✅ Always Use Kill + Down
```bash
# Don't just use "down"
docker compose down  # May not work

# Use kill + down
docker compose kill && docker compose down --remove-orphans  # Always works
```

### ✅ Verify Stop Worked
```bash
# After stop, always verify
docker ps  # Should be empty
curl http://localhost:5050  # Should refuse connection
free -h  # Should show low memory
```

### ✅ Use Scripts for Reliability
```bash
# Scripts handle edge cases automatically
/mnt/e/development/infrastructure/scripts/stop-lab.sh
/mnt/e/development/infrastructure/scripts/start-lab.sh minimal
```

### ✅ Browser Hard Refresh
```bash
# After stop, hard refresh browser
Ctrl + Shift + R  # Windows
Cmd + Shift + R   # Mac
```

---

## 🆘 Emergency Procedures

### Nuclear Option: Stop Everything
```bash
# Force stop ALL containers
docker stop $(docker ps -q)
docker rm $(docker ps -aq)

# Restart Docker daemon
sudo service docker restart

# Restart WSL2 (PowerShell)
wsl --shutdown
```

### Fresh Start: Remove All Data
```bash
# ⚠️ WARNING: Deletes all data!
cd /mnt/e/development/infrastructure/docker/compose
docker compose down -v  # Removes volumes too
```

---

**Last Updated**: October 28, 2025  
**Status**: All issues resolved ✅

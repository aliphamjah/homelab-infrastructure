# Maintenance Tasks

## Weekly Tasks
- [ ] Check Docker disk usage: `docker system df`
- [ ] Review container logs: `docker compose logs`
- [ ] Backup databases to `data/backups/weekly/`
- [ ] Update documentation with learnings

## Monthly Tasks
- [ ] Update Docker images: `docker compose pull`
- [ ] Clean unused resources: `docker system prune -a`
- [ ] Review and archive old backups
- [ ] Check SSD health (CrystalDiskInfo on Windows)
- [ ] Update Ubuntu packages: `sudo apt update && sudo apt upgrade`

## Quarterly Tasks
- [ ] Review thermal performance (temps, throttling)
- [ ] Clean laptop fans and vents
- [ ] Review project goals and priorities
- [ ] Backup entire development directory

## References
- Maintenance schedule in hardware spec
- Troubleshooting playbook

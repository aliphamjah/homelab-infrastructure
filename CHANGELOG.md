# Changelog

All notable changes to this home lab environment will be documented here.

## [0.1.0] - 2025-10-24

### Added
- Initial project structure
- WSL2 Ubuntu 22.04.5 LTS installation
- Docker Engine 28.5.1 setup
- Docker Compose 2.40.2 configuration
- 4 isolated Docker networks (dev, kafka, k8s, monitoring)
- Complete directory structure (infrastructure, projects, data, docs, templates)
- Comprehensive .gitignore files
- Documentation framework
- Security templates (.env.example files)
- Project README and quick start guide

### Infrastructure
- Docker daemon configuration (overlay2, json-file logging)
- Auto-start script for Docker in WSL2
- Passwordless sudo for Docker commands
- Development aliases (dev, dc, dcu, dcd, dcl, dcp)

### Documentation
- Setup guides (WSL2, Docker, Project Structure)
- Maintenance checklists
- Troubleshooting playbook templates
- Learning log templates

### Security
- Secrets directory with .gitignore
- Data directory protection
- .env.example templates for credentials

## [Upcoming]

### Phase 5: Base Services Deployment
- [ ] PostgreSQL 16
- [ ] Redis 7
- [ ] pgAdmin 4
- [ ] Redis Commander

### Phase 6: Automation Scripts
- [ ] start-lab.sh
- [ ] stop-lab.sh
- [ ] status-lab.sh
- [ ] backup.sh

### Phase 7: Verification
- [ ] Performance baseline testing
- [ ] Service health checks
- [ ] Documentation review

# Project Templates

Quick-start templates for common project types.

## Available Templates
- `docker-compose-template/` - Standard Docker Compose setup
- `go-microservice/` - Go service with cmd/internal/pkg structure
- `react-vite-app/` - React + Vite + TypeScript
- `nestjs-api/` - NestJS backend template
- `fastapi-service/` - Python FastAPI template

## Usage
```bash
# Copy template to projects directory
cp -r templates/go-microservice projects/go/my-new-service
cd projects/go/my-new-service
# Initialize and start development
```

## Creating New Templates
1. Build a working project
2. Remove generated files (node_modules, target, etc)
3. Add placeholder configs
4. Document setup steps in README
5. Copy to templates directory

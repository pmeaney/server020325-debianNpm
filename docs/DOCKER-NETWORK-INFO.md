## Docker Cross-Service Networking

### Primary Network Configuration

In your NPM Docker Compose file, define the shared network:

```yaml
networks:
  main-network--nginxproxymgr:
    name: main-network--nginxproxymgr
```

### Connecting Additional Services

For other Docker Compose files in different directories, connect to the shared network:

```yaml
services:
  your-application:
    image: your-image:tag
    networks:
      - main-network--nginxproxymgr

networks:
  main-network--nginxproxymgr:
    external: true
    name: main-network--nginxproxymgr
```

### Verifying Network Configuration

Check network connections using Docker commands:

```bash
# List all networks
docker network ls

# Inspect network connections
docker network inspect main-network--nginxproxymgr

# View connected containers
docker network inspect main-network--nginxproxymgr -f '{{range .Containers}}{{.Name}} {{end}}'
```

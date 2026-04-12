# Planetary Agents Deployment Package

## Overview

This package deploys 8 FastAPI planetary agents, containerized via Docker and orchestrated by Docker Compose. Includes NGINX proxy and a live health check dashboard.

---

## Setup & Deployment

1. Build and deploy agents:
    ```bash
    ./deploy-agents.sh
    ```

2. Start NGINX with the provided config:
    ```bash
    sudo nginx -c $(pwd)/nginx.agents.conf
    ```

3. Serve documentation and health dashboard locally:
    ```bash
    ./serve-docs.sh
    ```

4. Access agents and docs:
    - Agent root: http://mars.yourplatform.com/
    - Health check: http://mars.yourplatform.com/healthz
    - Docs: http://mars.yourplatform.com/docs
    - Dashboard: http://localhost:8000/health-dashboard.html

---

## Troubleshooting

Check container logs:

```bash
docker logs mars-agent
Logo of Planetary Agents, a stylized planet with orbiting satellites
Planetary Agents

Deployment Package Script
Below is the full setup_planetary_agents.sh script that creates the folder structure and README.md for the Planetary Agents deployment package.

#!/bin/bash
set -e

BASE_DIR="PlanetaryAgentsDeployment"
AGENTS=(mars venus jupiter saturn mercury neptune uranus earth)

echo "Creating folder structure..."
mkdir -p "$BASE_DIR"/{agents/{${AGENTS[*]}},docs,scripts,logs}

echo "Writing README.md..."
cat > "$BASE_DIR/README.md" <<'EOF'
# Planetary Agents Deployment Package

## Overview

This package deploys 8 FastAPI planetary agents, containerized via Docker and orchestrated by Docker Compose. Includes NGINX proxy and a live health check dashboard.

---

## Setup & Deployment

1. Build and deploy agents:
    ```bash
    ./deploy-agents.sh
    ```

2. Start NGINX with the provided config:
    ```bash
    sudo nginx -c $(pwd)/nginx.agents.conf
    ```

3. Serve documentation and health dashboard locally:
    ```bash
    ./serve-docs.sh
    ```

4. Access agents and docs:
    - Agent root: http://mars.yourplatform.com/
    - Health check: http://mars.yourplatform.com/healthz
    - Docs: http://mars.yourplatform.com/docs
    - Dashboard: http://localhost:8000/health-dashboard.html

---

## Troubleshooting

Check container logs:

```bash
docker logs mars-agent
docker logs venus-agent
docker logs jupiter-agent
docker logs saturn-agent
docker logs mercury-agent
docker logs neptune-agent
docker logs uranus-agent
docker logs earth-agent
```

Check NGINX logs:

```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

---

## Contact

For support, reach out to the Planetary Agents team at support@planetaryagents.com


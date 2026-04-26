# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains Docker-based deployment scripts for a QQ bot stack consisting of:
- **NapCat**: NTQQ protocol implementation container (port 6099)
- **AstrBot**: Bot framework (port 6185)
- **Gsuid-Core**: Genshin/Star Rail game bot core (port 8765)

All services communicate via a shared Docker bridge network `astrbot_network`. The project is optimized for deployment in mainland China with mirror configurations for Docker, PyPI, and git repositories.

## Repository Structure

```
qqbot/
├── 1_dockerInstall/      # Docker installation scripts for Ubuntu
│   ├── install_docker.sh # Install Docker with Aliyun mirrors
│   └── README.md
└── 2_napcat_docker/      # Main bot deployment directory
    ├── docker-compose.yml
    ├── run_napcat.sh     # Primary deployment script
    ├── fix_docker_mirror.sh
    └── README.md
```

## Common Commands

All commands should be run from the `2_napcat_docker/` directory unless otherwise specified.

### Deployment Workflow

1. **Install Docker** (run from `1_dockerInstall/` on a fresh Ubuntu server):
   ```bash
   chmod +x install_docker.sh
   ./install_docker.sh
   ```

2. **Fix Docker mirror issues** (if encountering timeout/403 errors):
   ```bash
   chmod +x fix_docker_mirror.sh
   ./fix_docker_mirror.sh
   ```

3. **Start all bot services**:
   ```bash
   chmod +x run_napcat.sh
   ./run_napcat.sh
   ```

### Docker Management

- View running containers: `docker ps`
- View container logs: `docker logs <container_name>`
- Follow logs: `docker logs -f <container_name>`
- Stop services: `docker compose down`
- Restart services: `docker compose restart`

## Architecture Notes

### Container Interconnection

- NapCat runs in `MODE=astrbot` to connect with the AstrBot container
- All three services share the `astrbot_network` bridge network
- File permissions are managed via `NAPCAT_UID`/`NAPCAT_GID` environment variables to avoid root ownership issues

### Persistent Volumes

- `./data` - AstrBot data (shared with NapCat container)
- `./napcat/config` - NapCat configuration
- `./ntqq` - QQ login session data (persists across container restarts)
- `./gsuid_core` - Gsuid-Core source code (auto-cloned)
- `./gsuid_data` - Gsuid-Core data
- `./gsuid_plugins` - Gsuid-Core plugins

### China-Specific Optimizations

- Docker mirrors configured via `daemon.json`
- PyPI uses TUNA mirror via `UV_INDEX_URL`
- Gsuid-Core clones from `https://cnb.cool/gscore-mirror/gsuid_core.git` with GitHub fallback
- Node.js installed from NodeSource during container startup

## Key Files

### `2_napcat_docker/docker-compose.yml`
Defines the three services with their port mappings, volumes, and network configuration. The `gsuid-core` service uses a custom mirror registry `docker.cnb.cool/gscore-mirror/gsuid_core:latest`.

### `2_napcat_docker/run_napcat.sh`
Automates the full deployment:
- Detects current user UID/GID for correct file permissions
- Creates all required mount directories with proper ownership
- Generates the Gsuid-Core startup script (gsuid_start/gsuid_start.sh)
- Clones the gsuid_core repository if not present
- Writes `.env` file with UID/GID
- Starts the docker-compose stack

### `1_dockerInstall/install_docker.sh`
Ubuntu Docker installation using Aliyun mirrors to avoid network issues in China. Creates a `docker-compose` wrapper script that delegates to `docker compose`.

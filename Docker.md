# Docker Deep-Dive Documentation

---

## Table of Contents

1. [The Problem Docker Solves](#-the-problem-docker-solves)
2. [Virtual Machines vs Docker](#-virtual-machines-vs-docker)
3. [Docker Architecture](#-docker-architecture)
4. [What Gets Installed with Docker?](#-what-gets-installed-with-docker)
5. [Dockerfile Deep Dive](#-dockerfile-deep-dive)
6. [Key Docker Commands](#-key-docker-commands)
7. [Docker Networking](#-docker-networking)
8. [Volumes & Persistence](#-volumes--persistence)
9. [Docker Compose](#-docker-compose)

---

## The Problem Docker Solves

### The "It Works on My Machine" Problem

Before Docker, developers faced a common nightmare:

```
Developer: "The app works perfectly on my laptop"
Operations: "it's crashing on the server
```

### Key Problems Docker Addresses:

| Problem | Description | Docker Solution |
|---------|-------------|-----------------|
| **Environment Inconsistency** | Different OS, libraries, dependencies across dev/staging/prod | Containers package everything needed to run |
| **Dependency Conflicts** | App A needs Python 3.8, App B needs Python 3.11 | Each container has its own isolated dependencies |
| **Complex Setup** | Hours spent installing and configuring environments | `docker run` and you're ready in seconds |
| **Resource Waste** | Running multiple VMs consumes huge resources | Containers share the host OS kernel, lightweight |
| **Slow Deployment** | Traditional deployment takes hours/days | Container deployment takes seconds |
| **Scaling Difficulties** | Hard to scale applications horizontally | Easy to spin up multiple container instances |

---

## Virtual Machines vs Docker

### Architecture Comparison

```
┌─────────────────────────────────────┐    ┌─────────────────────────────────────┐
│         VIRTUAL MACHINES            │    │            DOCKER                   │
├─────────────────────────────────────┤    ├─────────────────────────────────────┤
│  ┌─────┐  ┌─────┐  ┌─────┐         │    │  ┌─────┐  ┌─────┐  ┌─────┐         │
│  │App A│  │App B│  │App C│         │    │  │App A│  │App B│  │App C│         │
│  ├─────┤  ├─────┤  ├─────┤         │    │  ├─────┤  ├─────┤  ├─────┤         │
│  │Bins/│  │Bins/│  │Bins/│         │    │  │Bins/│  │Bins/│  │Bins/│         │
│  │Libs │  │Libs │  │Libs │         │    │  │Libs │  │Libs │  │Libs │         │
│  ├─────┤  ├─────┤  ├─────┤         │    │  └──┬──┘  └──┬──┘  └──┬──┘         │
│  │Guest│  │Guest│  │Guest│         │    │     └────────┼────────┘            │
│  │ OS  │  │ OS  │  │ OS  │         │    │              ▼                     │
│  └──┬──┘  └──┬──┘  └──┬──┘         │    │     ┌──────────────┐               │
│     └────────┼────────┘            │    │     │Docker Engine │               │
│              ▼                     │    │     └──────┬───────┘               │
│     ┌──────────────┐               │    │            ▼                       │
│     │  Hypervisor  │               │    │     ┌──────────────┐               │
│     └──────┬───────┘               │    │     │   Host OS    │               │
│            ▼                       │    │     └──────┬───────┘               │
│     ┌──────────────┐               │    │            ▼                       │
│     │   Host OS    │               │    │     ┌──────────────┐               │
│     └──────┬───────┘               │    │     │Infrastructure│               │
│            ▼                       │    │     └──────────────┘               │
│     ┌──────────────┐               │    │                                    │
│     │Infrastructure│               │    │                                    │
│     └──────────────┘               │    │                                    │
└─────────────────────────────────────┘    └─────────────────────────────────────┘
```

### Detailed Comparison

| Aspect | Virtual Machines | Docker Containers |
|--------|------------------|-------------------|
| **Boot Time** | Minutes | Seconds |
| **Size** | GBs (full OS) | MBs (only app + dependencies) |
| **Performance** | ~5-10% overhead | Near-native performance |
| **Isolation** | Complete (hardware level) | Process-level isolation |
| **OS Support** | Any OS on any host | Shares host kernel |
| **Resource Usage** | Heavy (each VM runs full OS) | Lightweight (shared kernel) |
| **Portability** | Limited by hypervisor | Run anywhere Docker is installed |
| **Density** | 10-20 VMs per host | 100s of containers per host |

### When to Use What?

| Use Virtual Machines When... | Use Docker When... |
|------------------------------|-------------------|
| Need different OS (Windows on Linux) | Running same OS applications |
| Strong security isolation required | Fast deployment needed |
| Running legacy applications | Microservices architecture |
| Need persistent, long-running servers | CI/CD pipelines |

---

## Docker Architecture

### Overview

Docker uses a **client-server architecture**:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              DOCKER ARCHITECTURE                              │
└──────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────┐         REST API          ┌─────────────────────────────────┐
  │   DOCKER    │ ◄────────────────────────►│         DOCKER DAEMON           │
  │   CLIENT    │                           │          (dockerd)              │
  │             │                           │                                 │
  │ docker build│                           │  ┌─────────────────────────┐    │
  │ docker pull │                           │  │     CONTAINER RUNTIME   │    │
  │ docker run  │                           │  │      (containerd)       │    │
  └─────────────┘                           │  └───────────┬─────────────┘    │
                                            │              │                  │
                                            │              ▼                  │
                                            │  ┌─────────────────────────┐    │
                                            │  │    IMAGES & CONTAINERS  │    │
                                            │  │  ┌─────┐ ┌─────┐ ┌─────┐│    │
                                            │  │  │ 📦 │ │ 📦 │ │ 📦 ││    │
                                            │  │  └─────┘ └─────┘ └─────┘│    │
                                            │  └─────────────────────────┘    │
                                            └─────────────────────────────────┘
                                                           │
                                                           ▼
                                            ┌─────────────────────────────────┐
                                            │        DOCKER REGISTRY          │
                                            │     (Docker Hub / Private)      │
                                            │                                 │
                                            │   node  nginx  postgres  redis  │
                                            └─────────────────────────────────┘
```

### Core Components

#### 1. Docker Client (`docker`)
- Command-line interface (CLI) users interact with
- Sends commands to Docker Daemon via REST API
- Can communicate with remote daemons

#### 2. Docker Daemon (`dockerd`)
- Background service running on host machine
- Manages Docker objects (images, containers, networks, volumes)
- Listens for Docker API requests

#### 3. Docker Registry
- Stores Docker images
- **Docker Hub** - Public registry (default)
- Can host private registries

#### 4. Docker Objects

| Object | Description |
|--------|-------------|
| **Image** | Read-only template with instructions for creating a container |
| **Container** | Runnable instance of an image |
| **Network** | Allows containers to communicate |
| **Volume** | Persistent data storage |

---

## What Gets Installed with Docker?

When you install Docker Desktop (or Docker Engine), you get:

### Core Components

```
Docker Installation
├── Docker Engine (dockerd)
│   ├── Docker Daemon - Core background service
│   ├── containerd - Container runtime
│   └── runc - Low-level container runtime
│
├──  Docker CLI (docker)
│   └── Command-line tool for Docker commands
│
├── Docker Compose (docker-compose)
│   └── Multi-container orchestration tool
│
├── ️ Docker Desktop (GUI - Mac/Windows)
│   ├── System tray application
│   ├── Kubernetes cluster (optional)
│   ├── VM for running Linux containers
│   └── Dashboard for container management
│
└──  Docker Networking
    ├── bridge - Default network driver
    ├── host - Remove network isolation
    └── overlay - Multi-host networking
```

### Verification Commands

```bash
# Check Docker version
docker --version

# Check all components
docker version

# Check system-wide information
docker info

# Check Docker Compose version
docker compose version
```

---

##  Dockerfile Deep Dive

### Our Project's Dockerfile Explained

```dockerfile
# ---------------------------------------------
# BASE IMAGE
# ---------------------------------------------
FROM node:20-alpine
# FROM: Specifies the base image to build upon
# node:20-alpine: 
#   - node: Official Node.js image
#   - 20: Node.js version 20 (LTS)
#   - alpine: Minimal Linux distribution (~5MB vs ~900MB for full)
# Why Alpine? Smaller image size, faster downloads, reduced attack surface

# ---------------------------------------------
# SYSTEM DEPENDENCIES
# ---------------------------------------------
RUN apk add --no-cache python3 make g++
# RUN: Executes commands in a new layer
# apk: Alpine Package Keeper (Alpine's package manager)
# add: Install packages
# --no-cache: Don't cache the package index (smaller image)
# python3 make g++: Required for building native Node.js modules
#   - Some npm packages need compilation (node-gyp)
#   - These tools enable building from source

# ---------------------------------------------
# WORKING DIRECTORY
# ---------------------------------------------
WORKDIR /myStrapi
# WORKDIR: Sets the working directory for subsequent instructions
# All following commands run from this directory
# Creates the directory if it doesn't exist
# Similar to: mkdir -p /myStrapi && cd /myStrapi

# ---------------------------------------------
# DEPENDENCY INSTALLATION (Optimized)
# ---------------------------------------------
COPY package.json package-lock.json* ./
# COPY: Copies files from host to container
# package.json package-lock.json*: Copy dependency files
# The * makes package-lock.json optional
# ./: Copy to current WORKDIR (/myStrapi)
# WHY SEPARATE? Docker layer caching optimization:
#   - Dependencies change less frequently than code
#   - This layer gets cached and reused

RUN npm install && npm install pg
# npm install: Install all dependencies from package.json
# npm install pg: Install PostgreSQL driver for database connection
# Combined with && to create single layer

# ---------------------------------------------
# APPLICATION CODE
# ---------------------------------------------
COPY . .
# COPY . .: Copy everything from current directory to WORKDIR
# This includes all source code, configs, etc.
# Happens AFTER npm install for better caching

# ---------------------------------------------
# PORT EXPOSURE
# ---------------------------------------------
EXPOSE 1337
# EXPOSE: Documents which port the container listens on
# Does NOT actually publish the port
# Strapi default port is 1337
# Actual port mapping done with: docker run -p 80:1337

# ---------------------------------------------
# STARTUP COMMAND
# ---------------------------------------------
CMD ["npm", "run", "develop"]
# CMD: Default command to run when container starts
# ["npm", "run", "develop"]: Run Strapi in development mode
# Exec form (array) preferred over shell form
# Can be overridden at runtime: docker run <image> npm run start
```

### Dockerfile Best Practices

| Practice | Description |
|----------|-------------|
| **Use specific base image tags** | `node:20-alpine` not `node:latest` |
| **Minimize layers** | Combine RUN commands with `&&` |
| **Order matters** | Put frequently changing instructions last |
| **Use .dockerignore** | Exclude unnecessary files |
| **Don't run as root** | Add `USER node` for security |
| **Multi-stage builds** | Smaller production images |

### Common Dockerfile Instructions

| Instruction | Purpose | Example |
|-------------|---------|---------|
| `FROM` | Base image | `FROM node:20-alpine` |
| `RUN` | Execute commands | `RUN npm install` |
| `COPY` | Copy files/dirs | `COPY . .` |
| `ADD` | Copy + extract archives | `ADD app.tar.gz /app` |
| `WORKDIR` | Set working directory | `WORKDIR /app` |
| `ENV` | Set environment variable | `ENV NODE_ENV=production` |
| `EXPOSE` | Document port | `EXPOSE 3000` |
| `CMD` | Default command | `CMD ["npm", "start"]` |
| `ENTRYPOINT` | Configure executable | `ENTRYPOINT ["node"]` |
| `ARG` | Build-time variable | `ARG VERSION=1.0` |
| `VOLUME` | Create mount point | `VOLUME /data` |
| `USER` | Set user | `USER node` |

---

## Key Docker Commands

### Image Commands

```bash
# ╔════════════════════════════════════════════════════════════════╗
# ║                      IMAGE MANAGEMENT                          ║
# ╚════════════════════════════════════════════════════════════════╝

# Build an image from Dockerfile
docker build -t my-app:1.0 .
# -t: Tag the image with name:version
# .: Build context (current directory)

# List all images
docker images
# or
docker image ls

# Pull image from registry
docker pull nginx:latest

# Push image to registry
docker push username/my-app:1.0

# Remove an image
docker rmi my-app:1.0
# or
docker image rm my-app:1.0

# Remove all unused images
docker image prune -a

# Inspect image details
docker image inspect nginx:latest

# View image history (layers)
docker history nginx:latest
```

### Container Commands

```bash
# ╔════════════════════════════════════════════════════════════════╗
# ║                    CONTAINER MANAGEMENT                        ║
# ╚════════════════════════════════════════════════════════════════╝

# Run a container
docker run nginx
# Run in detached mode (background)
docker run -d nginx
# Run with port mapping
docker run -d -p 8080:80 nginx
# Run with name
docker run -d --name my-nginx nginx
# Run with environment variables
docker run -d -e NODE_ENV=production my-app
# Run with volume mount
docker run -d -v /host/path:/container/path nginx
# Run and remove after exit
docker run --rm nginx

# List running containers
docker ps
# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop my-nginx
# Stop with timeout
docker stop -t 30 my-nginx

# Start a stopped container
docker start my-nginx

# Restart a container
docker restart my-nginx

# Remove a container
docker rm my-nginx
# Force remove running container
docker rm -f my-nginx

# Remove all stopped containers
docker container prune

# View container logs
docker logs my-nginx
# Follow logs in real-time
docker logs -f my-nginx
# Show last 100 lines
docker logs --tail 100 my-nginx

# Execute command in running container
docker exec -it my-nginx bash
# -i: Interactive
# -t: Allocate pseudo-TTY
# bash: Command to run

# Copy files to/from container
docker cp file.txt my-nginx:/app/
docker cp my-nginx:/app/file.txt ./

# View container resource usage
docker stats

# Inspect container details
docker inspect my-nginx
```

### System Commands

```bash
# ╔════════════════════════════════════════════════════════════════╗
# ║                      SYSTEM COMMANDS                           ║
# ╚════════════════════════════════════════════════════════════════╝

# View Docker system info
docker info

# View disk usage
docker system df

# Clean up everything unused
docker system prune -a --volumes
# WARNING: Removes all unused images, containers, networks, volumes

# View Docker events in real-time
docker events
```


---

## Docker Networking

### Network Types

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           DOCKER NETWORK TYPES                               │
└──────────────────────────────────────────────────────────────────────────────┘

1. BRIDGE (Default)
   ┌─────────────────────────────────────────┐
   │              HOST MACHINE               │
   │  ┌─────────────────────────────────┐   │
   │  │       docker0 (bridge)          │   │
   │  │         172.17.0.1              │   │
   │  └──────┬──────────────┬───────────┘   │
   │         │              │               │
   │    ┌────▼────┐    ┌────▼────┐          │
   │    │Container│    │Container│          │
   │    │172.17.0.2│   │172.17.0.3│         │
   │    └─────────┘    └─────────┘          │
   └─────────────────────────────────────────┘
   • Default network for containers
   • Containers can communicate via IP
   • Isolated from host network

2. HOST
   ┌─────────────────────────────────────────┐
   │              HOST MACHINE               │
   │           Network: 192.168.1.x         │
   │                    │                    │
   │    ┌───────────────┼───────────────┐   │
   │    │               │               │   │
   │    │  Container    │  Container    │   │
   │    │  (port 80)    │  (port 3000)  │   │
   │    └───────────────┴───────────────┘   │
   └─────────────────────────────────────────┘
   • No network isolation
   • Container uses host's network directly
   • Better performance, less isolation

3. OVERLAY
   ┌─────────────┐         ┌─────────────┐
   │   HOST 1    │◄───────►│   HOST 2    │
   │  ┌───────┐  │ Overlay │  ┌───────┐  │
   │  │Contain│  │ Network │  │Contain│  │
   │  │  er   │◄─┼─────────┼─►│  er   │  │
   │  └───────┘  │         │  └───────┘  │
   └─────────────┘         └─────────────┘
   • Multi-host networking
   • Used with Docker Swarm
   • Containers across hosts can communicate

4. NONE
   ┌─────────────────────────────────────────┐
   │              HOST MACHINE               │
   │                                         │
   │    ┌─────────┐                          │
   │    │Container│  ← No network access     │
   │    │ (none)  │                          │
   │    └─────────┘                          │
   └─────────────────────────────────────────┘
   • Complete network isolation
   • No external connectivity
```

### Network Commands

```bash
# List networks
docker network ls

# Create a custom network
docker network create my-network

# Create with specific driver
docker network create --driver bridge my-bridge

# Run container on specific network
docker run -d --network my-network --name app nginx

# Connect running container to network
docker network connect my-network my-container

# Disconnect from network
docker network disconnect my-network my-container

# Inspect network
docker network inspect my-network

# Remove network
docker network rm my-network
```

### Container Communication

```yaml
# In docker-compose.yml - containers on same network can communicate by service name
services:
  app:
    build: .
    networks:
      - my-network
    # Can reach db at hostname "db"
    
  db:
    image: postgres
    networks:
      - my-network
    # Can reach app at hostname "app"

networks:
  my-network:
    driver: bridge
```

### Our Project's Network

```
┌────────────────────────────────────────────────────────────────┐
│                    myStrapiNetwork (bridge)                    │
│                                                                │
│   ┌─────────┐      ┌─────────┐      ┌─────────┐               │
│   │  nginx  │─────►│   app   │─────►│   db    │               │
│   │  :80    │      │  :1337  │      │  :5432  │               │
│   └─────────┘      └─────────┘      └─────────┘               │
│        │                                                       │
└────────┼───────────────────────────────────────────────────────┘
         │
         ▼
    External Access
    (port 80)
```

---

## Volumes & Persistence

### The Problem

```
Without Volumes:
┌─────────────────────────────────────────┐
│           Container                      │
│  ┌─────────────────────────────────┐    │
│  │         Application Data         │    │
│  │   (Lost when container stops!)   │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘

With Volumes:
┌─────────────────────────────────────────┐
│           Container                      │
│  ┌─────────────────────────────────┐    │
│  │         Application              │    │
│  │              │                   │    │
│  └──────────────┼───────────────────┘    │
└─────────────────┼───────────────────────┘
                  │ (mount)
                  ▼
┌─────────────────────────────────────────┐
│        Volume (Persistent Storage)       │
│   Data survives container lifecycle!     │
└─────────────────────────────────────────┘
```

### Volume Types

| Type | Description | Use Case |
|------|-------------|----------|
| **Named Volumes** | Docker-managed volumes | Production databases |
| **Bind Mounts** | Host path mounted in container | Development, config files |
| **tmpfs Mounts** | Memory-only storage | Sensitive data, temp files |

### Volume Commands

```bash
# Create a volume
docker volume create my-data

# List volumes
docker volume ls

# Inspect volume
docker volume inspect my-data

# Remove volume
docker volume rm my-data

# Remove all unused volumes
docker volume prune
```

### Using Volumes

```bash
# Named Volume
docker run -d -v my-data:/var/lib/postgresql/data postgres

# Bind Mount (host path)
docker run -d -v /host/path:/container/path nginx

# Read-only mount
docker run -d -v /host/path:/container/path:ro nginx

# tmpfs mount
docker run -d --tmpfs /tmp nginx
```

### Our Project's Volume Configuration

```yaml
# docker-compose.yml
volumes:
  postgres_data:  # Named volume definition

services:
  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql  # Mount named volume
    # Database data persists even if container is removed
```

---

## Docker Compose

### What is Docker Compose?

Docker Compose is a tool for defining and running **multi-container** Docker applications.

```
Without Compose:                    With Compose:
                                    
$ docker network create net         $ docker compose up
$ docker run -d --network net \     
    --name db postgres              # That's it! 🎉
$ docker run -d --network net \     
    --name app -p 3000:3000 \       
    my-app                          
$ docker run -d --network net \     
    --name nginx -p 80:80 \         
    nginx                           
```

### docker-compose.yml Explained

```yaml
# Docker Compose file format version
version: '3.1'

# ╔════════════════════════════════════════════════════════════════╗
# ║                         SERVICES                               ║
# ╚════════════════════════════════════════════════════════════════╝
services:

  # ─────────────────────────────────────────────────────────────────
  # DATABASE SERVICE (PostgreSQL)
  # ─────────────────────────────────────────────────────────────────
  db:
    image: postgres:15-alpine
    # image: Pre-built image from Docker Hub
    # postgres: Official PostgreSQL image
    # 15-alpine: Version 15 on Alpine Linux (smaller size)
    
    environment:
      - POSTGRES_USER=myuser
      - POSTGRES_PASSWORD=mypassword
      - POSTGRES_DB=mydatabase
    # environment: Set environment variables in container
    # These configure the PostgreSQL instance
    
    ports:
      - "5432:5432"
    # ports: Map host:container ports
    # Allows direct database access from host (optional)
    
    volumes:
      - postgres_data:/var/lib/postgresql
    # volumes: Persist data beyond container lifecycle
    # postgres_data: Named volume (defined below)
    # /var/lib/postgresql: PostgreSQL data directory
    
    networks:
      - myStrapiNetwork
    # networks: Connect to custom network

  # ─────────────────────────────────────────────────────────────────
  # APPLICATION SERVICE (Strapi)
  # ─────────────────────────────────────────────────────────────────
  app:
    build: .
    # build: Build image from Dockerfile in current directory
    # Uses the Dockerfile we created earlier
    
    networks:
      - myStrapiNetwork
    # Same network as db - can access db by hostname "db"
    
    depends_on:
      - db
    # depends_on: Start db before app
    # Ensures database is running before Strapi tries to connect
    # NOTE: Doesn't wait for db to be "ready", just "started"

  # ─────────────────────────────────────────────────────────────────
  # REVERSE PROXY SERVICE (Nginx)
  # ─────────────────────────────────────────────────────────────────
  nginx:
    image: nginx:latest
    # Using latest nginx image
    
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    # Bind mount: Replace default nginx config with our custom config
    # ./nginx.conf: Our local config file
    # /etc/nginx/nginx.conf: Where nginx looks for config
    
    ports:
      - "80:80"
    # Expose port 80 to host
    # Users access the app via port 80
    
    depends_on:
      - app
    # Wait for app to start before nginx
    
    networks:
      - myStrapiNetwork
    # Same network - can reach app by hostname "app"

# ╔════════════════════════════════════════════════════════════════╗
# ║                         VOLUMES                                ║
# ╚════════════════════════════════════════════════════════════════╝
volumes:
  postgres_data:
  # Define named volume for database persistence
  # Docker manages the storage location

# ╔════════════════════════════════════════════════════════════════╗
# ║                         NETWORKS                               ║
# ╚════════════════════════════════════════════════════════════════╝
networks:
  myStrapiNetwork:
    driver: bridge
  # Custom bridge network for container communication
  # All services can communicate using service names as hostnames
```

### Docker Compose Commands

```bash
# ╔════════════════════════════════════════════════════════════════╗
# ║                   DOCKER COMPOSE COMMANDS                      ║
# ╚════════════════════════════════════════════════════════════════╝

# Start all services
docker compose up

# Start in detached mode (background)
docker compose up -d

# Build and start
docker compose up --build

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v

# View running services
docker compose ps

# View logs
docker compose logs

# Follow logs
docker compose logs -f

# Logs for specific service
docker compose logs app

# Execute command in service
docker compose exec app sh

# Restart services
docker compose restart

# Stop services (keep containers)
docker compose stop

# Start stopped services
docker compose start

# Rebuild specific service
docker compose build app

# Scale services
docker compose up -d --scale app=3
```






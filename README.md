# Documentation for Strapi Daily Work Logs CMS

A Strapi v5.31.2 headless CMS built with TypeScript for managing daily work logs.

## 📋 Project Overview

This Strapi application is a headless CMS designed for tracking daily work activities and productivity. It provides:

- **Intuitive Admin Panel** - User-friendly interface for content creation and management
- **RESTful API** - Auto-generated API endpoints for all content types
- **SQLite Database** - Lightweight database for local development (easily configurable for PostgreSQL/MySQL)
- **Media Library** - Advanced media management with support for images, videos, audio files, and documents
- **Custom Content Types** - Pre-configured Daily Work Log collection with rich text editing
- **User Authentication** - Built-in user management and permissions system

## 📁 Project Structure

```
myStrapi/
├── config/                    # Application configuration
│   ├── admin.ts
│   ├── api.ts
│   ├── database.ts
│   ├── middlewares.ts
│   ├── plugins.ts
│   └── server.ts
├── src/
│   ├── admin/                 # Admin panel customization
│   │   ├── app.example.tsx
│   │   ├── tsconfig.json
│   │   └── vite.config.example.ts
│   ├── api/
│   │   └── daily-work-log/    # Daily Work Logs API
│   │       ├── content-types/
│   │       │   └── daily-work-log/
│   │       │       └── schema.json
│   │       ├── controllers/
│   │       │   └── daily-work-log.ts
│   │       ├── routes/
│   │       │   └── daily-work-log.ts
│   │       └── services/
│   │           └── daily-work-log.ts
│   ├── extensions/            # Strapi extensions
│   └── index.ts
├── .tmp/                      # SQLite database location
│   └── data.db
├── public/                    # Static files & uploads
├── .env.example
├── package.json
└── tsconfig.json
```

## 🚀 Installation & Setup

### 1. Install Dependencies

```bash
npm install
```

Update `.env` with your secrets (generate new keys for production).

### 2. Build the Application

```bash
npm run build
```

## 🎨 Starting the Admin Panel

### Development Mode

```bash
npm run develop
```

Admin panel: **http://localhost:1337/admin**

### Production Mode

```bash
npm run start
```

### First Login

1. Visit `http://localhost:1337/admin`
2. Create your admin account
3. Complete registration

## 📝 Content Types

### Daily Work Logs

**API Endpoint:** `/api/daily-work-logs`

**Schema Details:**
- **Collection Type:** `daily_work_logs`
- **Draft & Publish:** Enabled

**Fields:**
- `date` (DateTime) - Date and time of the work log entry
- `tasks_completed` (Blocks/Rich Text) - Detailed description of completed tasks with rich formatting
- `pending_tasks` (Blocks/Rich Text) - List of pending or upcoming tasks
- `mood` (Blocks/Rich Text) - Notes about mood, productivity, or general reflections
- `screenshot` (Media, Multiple) - Upload multiple files (images, videos, audio, documents)

**Creating a Work Log:**

1. Navigate to **Content Manager → Daily Work Logs**
2. Click **"Create new entry"**
3. Select the date and time
4. Add completed and pending tasks using the rich text editor
5. Document your mood or notes
6. Upload relevant screenshots or files
7. Click **Save** (draft) or **Save & Publish** (live)

### Comic

**API Endpoint:** `/api/comics`

**Schema Details:**
- **Collection Type:** `comics`
- **Draft & Publish:** Enabled

**Fields:**
- `comicName` (String) - Name of the comic
- `comicnumber` (UID) - Unique identifier for the comic
- `comicCharacter` (String) - Main character of the comic


## ⚙️ Configuration

- **Database:** SQLite (`.tmp/data.db`)
- **Port:** 1337
- **Host:** 0.0.0.0
- **Admin Path:** `/admin`

## 🛠️ NPM Scripts

```bash
npm run develop    # Development with auto-reload
npm run start      # Production mode
npm run build      # Build admin panel
```

## 🐳 Docker Setup

This project includes a complete Docker setup for containerized deployment with PostgreSQL and Nginx reverse proxy.

### Docker Files

| File | Description |
|------|-------------|
| `Dockerfile` | Multi-stage build for Strapi app (Node 20 Alpine) |
| `docker-compose.yml` | Orchestrates all services |
| `nginx.conf` | Reverse proxy configuration |
| `.dockerignore` | Files excluded from Docker build |
| `Docker.md` | Comprehensive Docker documentation |

### Services Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    myStrapiNetwork                          │
│                                                             │
│   ┌─────────┐      ┌─────────┐      ┌─────────┐            │
│   │  nginx  │─────►│   app   │─────►│   db    │            │
│   │  :80    │      │  :1337  │      │  :5432  │            │
│   └─────────┘      └─────────┘      └─────────┘            │
│        │                                                    │
└────────┼────────────────────────────────────────────────────┘
         │
         ▼
    External Access (port 80)
```

### Services

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| **nginx** | nginx:latest | 80 | Reverse proxy (entry point) |
| **app** | Custom (Dockerfile) | 1337 (internal) | Strapi application |
| **db** | postgres:15-alpine | 5432 | PostgreSQL database |

### Quick Start with Docker

```bash
# Build and start all services
docker compose up --build

# Run in background
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down

# Stop and remove volumes (reset database)
docker compose down -v
```

Access admin panel at: **http://localhost** (port 80 via Nginx)

### Environment Variables (Docker)

The following environment variables are configured in `docker-compose.yml`:

| Variable | Service | Description |
|----------|---------|-------------|
| `POSTGRES_USER` | db | Database username |
| `POSTGRES_PASSWORD` | db | Database password |
| `POSTGRES_DB` | db | Database name |
| `DATABASE_CLIENT` | app | Database client (postgres) |
| `DATABASE_HOST` | app | Database host (db) |
| `DATABASE_PORT` | app | Database port (5432) |

### Nginx Configuration

The Nginx reverse proxy:
- Listens on port 80
- Forwards all requests to Strapi (port 1337)
- Handles WebSocket connections for hot reload

### Persistent Data

Database data is persisted using Docker named volumes:
- `postgres_data` - PostgreSQL data directory

### Docker Documentation

For a comprehensive deep-dive into Docker concepts, architecture, and commands, see **[Docker.md](./Docker.md)**

## 📦 Push to GitHub

### 1. Verify .gitignore

Ensures these are ignored:
- `node_modules/`
- `.env`
- `.tmp/`
- `build/`, `dist/`, `.cache/`

### 2. Create Repository

On GitHub, create a new repository.

### 3. Push Code

```bash
git init
git add .
git commit -m "Initial commit: Strapi CMS with daily work logs"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
git push -u origin main
```

---

## 🚀 AWS Deployment with Terraform (EC2 + RDS PostgreSQL)

This project includes complete Terraform configuration to deploy Strapi on AWS with:
- **EC2 Instance** - Runs the Strapi Docker container
- **RDS PostgreSQL** - Managed database service
- **Default VPC** - Uses AWS default VPC (no custom VPC creation needed)
- **Security Groups** - Proper network access controls

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                                       │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                       Default VPC                                      │  │
│  │                                                                        │  │
│  │   ┌─────────────────────────────────────────────────────────────────┐ │  │
│  │   │                    Default Subnets                              │ │  │
│  │   │                                                                  │ │  │
│  │   │  ┌───────────────────┐      ┌───────────────────────────┐       │ │  │
│  │   │  │   EC2 Instance    │      │    RDS PostgreSQL         │       │ │  │
│  │   │  │   (Strapi App)    │─────►│    (Managed DB)           │       │ │  │
│  │   │  │   Port: 1337      │      │    Port: 5432             │       │ │  │
│  │   │  └─────────┬─────────┘      └───────────────────────────┘       │ │  │
│  │   │            │                                                     │ │  │
│  │   └────────────┼─────────────────────────────────────────────────────┘ │  │
│  │                │                                                        │  │
│  │   ┌────────────┴────────────┐                                          │  │
│  │   │    Internet Gateway     │                                          │  │
│  │   └────────────┬────────────┘                                          │  │
│  └────────────────┼───────────────────────────────────────────────────────┘  │
│                   │                                                          │
└───────────────────┼──────────────────────────────────────────────────────────┘
                    │
                    ▼
              🌐 Internet
              (Users access via Public IP)
```

### Prerequisites

1. **AWS Account** with programmatic access
2. **Terraform** installed (v1.0+)
3. **Docker Hub Account** (to push your image)
4. **AWS CLI** configured with credentials

### Step 1: Build & Push Docker Image

```bash
# Navigate to project directory
cd myStrapi

# Build the Docker image for linux/amd64 (EC2 compatible)
docker buildx build --platform linux/amd64 -t your-dockerhub-username/strapi-daily-logs:latest --push .

# Or build locally first, then push
docker build -t your-dockerhub-username/strapi-daily-logs:latest .
docker login
docker push your-dockerhub-username/strapi-daily-logs:latest
```

> **Note:** If building on Apple Silicon (M1/M2), you MUST use `--platform linux/amd64` for EC2 compatibility.

### Step 2: Generate SSH Key

```bash
# Generate SSH key pair for EC2 access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/strapi-key

# View your public key (copy this)
cat ~/.ssh/strapi-key.pub
```

### Step 3: Configure Terraform Variables

```bash
cd terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Required variables in `terraform.tfvars`:**

```hcl
# AWS Region
aws_region = "ap-south-1"

# SSH Public Key (from Step 2)
ssh_public_key = "ssh-rsa AAAA..."

# RDS Password (choose a strong password)
db_password = "YourSecurePassword123!"

# Docker Image (from Step 1)
docker_image = "your-dockerhub-username/strapi-daily-logs:latest"

# Generate these secrets:
# openssl rand -base64 32
app_keys         = "generated-key-1,generated-key-2"
api_token_salt   = "generated-api-token-salt"
admin_jwt_secret = "generated-admin-jwt-secret"
jwt_secret       = "generated-jwt-secret"
```

### Step 4: Deploy with Terraform

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply configuration (creates all AWS resources)
terraform apply
```

**Resources Created:**
- 2 Security Groups (EC2, RDS)
- 1 DB Subnet Group (uses default subnets)
- 1 EC2 Instance (t2.small, 30GB gp3 volume)
- 1 RDS PostgreSQL Instance (db.t3.micro)
- 1 SSH Key Pair

### Step 5: Access Strapi

After deployment (~5-10 minutes for RDS):

```bash
# Get outputs
terraform output

# Access Strapi Admin
http://<ec2-public-ip>:1337/admin
```

### Step 6: SSH into EC2 (Optional)

```bash
# Connect to EC2
ssh -i ~/.ssh/strapi-key ec2-user@<ec2-public-ip>

# View container logs
docker logs strapi

# Check container status
docker ps
```

### Terraform Files Structure

```
terraform/
├── main.tf              # Main infrastructure (VPC, EC2, RDS)
├── variables.tf         # Variable definitions
├── outputs.tf           # Output values
├── terraform.tfvars.example  # Example variables
└── user_data.sh         # EC2 bootstrap script
```

### Cost Estimate (ap-south-1)

| Resource | Type | Estimated Monthly Cost |
|----------|------|------------------------|
| EC2 | t2.small | ~$15-17 |
| RDS | db.t3.micro | ~$12-15 |
| EBS | 30GB gp3 | ~$2.50 |
| Data Transfer | Minimal | ~$1-5 |
| **Total** | | **~$30-40/month** |

### Cleanup

```bash
# Destroy all AWS resources
terraform destroy

# Confirm with 'yes'
```

### Troubleshooting

**EC2 instance not accessible:**
```bash
# Check security group rules
# Ensure ports 22, 80, 1337 are open
```

**Strapi not connecting to RDS:**
```bash
# SSH into EC2 and check logs
docker logs strapi

# Verify RDS endpoint in environment
cat /home/ec2-user/strapi/.env

# Common fix: Ensure SSL is enabled
# DATABASE_SSL=true
# DATABASE_SSL_REJECT_UNAUTHORIZED=false
```

**"no pg_hba.conf entry" error:**
This means RDS requires SSL. Ensure your `.env` has:
```
DATABASE_SSL=true
DATABASE_SSL_REJECT_UNAUTHORIZED=false
```

**Docker image not pulling:**
```bash
# Ensure image is public or login to Docker Hub
docker login
```

---

## 🔄 CI/CD with GitHub Actions + ECR

This project includes automated CI/CD pipelines using GitHub Actions to build, push Docker images to AWS ECR, and deploy to EC2 using Terraform.

### Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         GitHub Actions CI/CD                                │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    CI Pipeline (ci.yml)                                │ │
│  │                                                                        │ │
│  │   Push to main ──► Build Docker Image ──► Push to ECR                 │ │
│  │                                                                        │ │
│  │   Triggers: push to main, manual dispatch                              │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                │                                            │
│                                ▼                                            │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                    CD Pipeline (terraform.yml)                         │ │
│  │                                                                        │ │
│  │   Manual Trigger ──► Terraform Init ──► Plan ──► Apply ──► Verify     │ │
│  │                                                                        │ │
│  │   Actions: plan, apply, destroy                                        │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                │                                            │
└────────────────────────────────┼────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                                       │
│                                                                             │
│   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐        │
│   │       ECR       │    │       EC2       │    │       RDS       │        │
│   │  (Docker Image) │───►│  (Strapi App)   │───►│  (PostgreSQL)   │        │
│   └─────────────────┘    └─────────────────┘    └─────────────────┘        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Workflow Files

| File | Purpose | Trigger |
|------|---------|---------|
| `.github/workflows/ci.yml` | Build & push Docker image to ECR | Push to `main` branch |
| `.github/workflows/terraform.yml` | Deploy infrastructure with Terraform | Manual (workflow_dispatch) |

### Required GitHub Secrets

Configure these secrets in your GitHub repository settings (`Settings → Secrets and variables → Actions`):

| Secret | Description | Example |
|--------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS IAM access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret key | `wJalrXUtnFEMI/K7MDENG/...` |
| `EC2_SSH_PRIVATE_KEY` | Private key for EC2 SSH access | `-----BEGIN RSA PRIVATE KEY-----...` |
| `EC2_KEY_NAME` | AWS key pair name | `aadithkey` |
| `DB_PASSWORD` | PostgreSQL database password | `YourSecurePassword123!` |
| `APP_KEYS` | Strapi APP_KEYS | `key1==,key2==,key3==,key4==` |
| `API_TOKEN_SALT` | Strapi API token salt | `randomBase64String==` |
| `ADMIN_JWT_SECRET` | Strapi admin JWT secret | `randomBase64String==` |
| `JWT_SECRET` | Strapi JWT secret | `randomBase64String==` |

### Generate Strapi Secrets

```bash
# Generate each secret
openssl rand -base64 16  # For API_TOKEN_SALT, ADMIN_JWT_SECRET, JWT_SECRET

# Generate APP_KEYS (4 comma-separated keys)
echo "$(openssl rand -base64 16),$(openssl rand -base64 16),$(openssl rand -base64 16),$(openssl rand -base64 16)"
```

### CI Pipeline (ci.yml)

**Triggers:**
- Automatically on push to `main` branch
- Manually via workflow dispatch

**Steps:**
1. ✅ Checkout code
2. ✅ Configure AWS credentials
3. ✅ Login to Amazon ECR
4. ✅ Create ECR repository (if not exists)
5. ✅ Build Docker image (linux/amd64)
6. ✅ Push to ECR with tags (latest + commit SHA)
7. ✅ Output build summary

### CD Pipeline (terraform.yml)

**Triggers:**
- Manual only (workflow_dispatch)
- Options: `plan`, `apply`, `destroy`

**Steps:**
1. ✅ Checkout code
2. ✅ Configure AWS credentials
3. ✅ Login to ECR & get image URI
4. ✅ Setup Terraform
5. ✅ Terraform init, validate, plan
6. ✅ Terraform apply (if selected)
7. ✅ SSH verification of deployment
8. ✅ Output deployment summary

### How to Use

#### 1. Initial Setup

```bash
# Add all secrets to GitHub repository
# Settings → Secrets and variables → Actions → New repository secret
```

#### 2. Push Code to Trigger CI

```bash
git add .
git commit -m "feat: add new feature"
git push origin main
```

The CI pipeline will automatically:
- Build your Docker image
- Push to AWS ECR
- Tag with commit SHA and `latest`

#### 3. Deploy with Terraform (Manual)

1. Go to **Actions** tab in GitHub
2. Select **"CD - Terraform Deploy to EC2"**
3. Click **"Run workflow"**
4. Choose action: `plan` (preview) or `apply` (deploy)
5. Click **"Run workflow"**

#### 4. Verify Deployment

After successful apply:
- Check the **workflow summary** for Strapi URL
- SSH verification is done automatically
- Access `http://<ec2-ip>:1337/admin`

### IAM Permissions Required

The AWS IAM user needs these permissions:

**For CI Pipeline (ECR):**
```json
{
  "Effect": "Allow",
  "Action": [
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:PutImage",
    "ecr:InitiateLayerUpload",
    "ecr:UploadLayerPart",
    "ecr:CompleteLayerUpload",
    "ecr:CreateRepository",
    "ecr:DescribeRepositories"
  ],
  "Resource": "*"
}
```

**For CD Pipeline (Terraform):**
```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:*",
    "rds:*",
    "iam:*",
    "ecr:*"
  ],
  "Resource": "*"
}
```

### ECR Repository

The CI pipeline creates an ECR repository named `strapi-daily-logs` in `ap-south-1` region.

**Image Tags:**
- `latest` - Always points to the most recent build
- `<commit-sha>` - Specific commit for rollback

### Troubleshooting CI/CD

**ECR login failed:**
- Ensure AWS credentials have ECR permissions
- Check AWS_REGION is correct

**Terraform state conflict:**
- If state is locked, wait or manually unlock
- Consider using S3 backend for state in production

**EC2 can't pull ECR image:**
- Ensure IAM instance profile is attached
- Check ECR permissions in iam.tf
- Verify AWS region matches

**SSH verification failed:**
- Check EC2_SSH_PRIVATE_KEY secret format (include full key with headers)
- Ensure key matches EC2_KEY_NAME
- Wait longer for EC2 initialization

# Strapi CI/CD & Advanced Deployment Documentation

## Table of Contents
1. [GitHub Actions CI/CD Setup](#github-actions-cicd-setup)
2. [ECS Fargate Deployment](#ecs-fargate-deployment)
3. [Fargate Spot Configuration](#fargate-spot-configuration)
4. [Blue/Green Deployment with CodeDeploy](#bluegreen-deployment-with-codedeploy)
5. [CloudWatch Monitoring](#cloudwatch-monitoring)

---

## 🚀 GitHub Actions CI/CD Setup

### Overview
This project implements a two-stage CI/CD pipeline that automates the build and deployment process. The CI pipeline automatically builds and pushes Docker images when code is pushed to the main branch, while the CD pipeline allows manual triggering of Terraform deployments.

### CI Pipeline (Continuous Integration)

**Purpose**: Automatically build and push Docker images on code changes.

**Workflow File**: `.github/workflows/ci.yml`

**Triggers**:
- Automatic: Push to `main` branch
- Manual: workflow_dispatch

**Process**:
1. Code is pushed to the main branch
2. GitHub Actions checks out the repository
3. Configures AWS credentials from GitHub secrets
4. Logs into Docker Hub or Amazon ECR
5. Builds Docker image with linux/amd64 platform (EC2 compatible)
6. Pushes image with two tags:
    - `latest` - Always points to most recent build
    - `<commit-sha>` - Specific version for rollback capability
7. Saves image tag as output for CD pipeline

**Key Feature**: Image tag output allows CD pipeline to pull the exact version that was just built.

### CD Pipeline (Continuous Deployment)

**Purpose**: Deploy the updated Docker image to EC2/ECS infrastructure using Terraform.

**Workflow File**: `.github/workflows/terraform.yml`

**Triggers**:
- Manual only (workflow_dispatch)
- Action options: plan, apply, destroy

**Process**:
1. Manually triggered from GitHub Actions interface
2. Checks out repository code
3. Configures AWS credentials
4. Sets up Terraform
5. Retrieves latest image tag from ECR
6. Runs `terraform init` to initialize backend
7. Runs `terraform validate` to check configuration
8. Runs `terraform plan` to preview changes
9. If "apply" selected, runs `terraform apply` to deploy
10. SSH into EC2 instance to verify deployment
11. Checks Docker container status
12. Outputs deployment summary with public IP

**Deployment Verification**:
- Automated SSH connection to verify container is running
- Checks Docker logs for errors
- Tests HTTP endpoint availability
- Provides public IP for manual browser verification

### Required GitHub Secrets

All sensitive data is stored as GitHub repository secrets:

- **AWS_ACCESS_KEY_ID** - AWS IAM access key for API access
- **AWS_SECRET_ACCESS_KEY** - AWS IAM secret key
- **EC2_SSH_PRIVATE_KEY** - Private SSH key to access EC2 instances
- **EC2_KEY_NAME** - Name of the AWS key pair
- **DB_PASSWORD** - PostgreSQL database password
- **APP_KEYS** - Strapi application keys (4 comma-separated keys)
- **API_TOKEN_SALT** - Strapi API token salt
- **ADMIN_JWT_SECRET** - Strapi admin JWT secret
- **JWT_SECRET** - Strapi JWT secret

Generate Strapi secrets using: `openssl rand -base64 16`

### Deployment Workflow

**Step 1**: Developer pushes code to main branch → CI pipeline automatically builds and pushes new Docker image

**Step 2**: DevOps/Admin manually triggers CD pipeline → Terraform deploys updated infrastructure with new image

**Step 3**: Automated verification confirms deployment success → Public IP provided for access

### Access After Deployment

Once deployment completes, access Strapi at: `http://<EC2_PUBLIC_IP>:1337/admin`

SSH access for troubleshooting: `ssh -i ~/.ssh/strapi-key ec2-user@<EC2_PUBLIC_IP>`

---

## 🐳 ECS Fargate Deployment

### Overview
Deploy Strapi as a fully managed containerized application on AWS ECS Fargate. This eliminates the need to manage EC2 instances, provides automatic scaling, and integrates with Application Load Balancer for high availability.

### Why ECS Fargate?

**Benefits over EC2**:
- No server management required
- Automatic scaling based on demand
- Pay only for resources used (per second)
- Better fault tolerance with multiple tasks
- Automatic task replacement if failures occur
- Integration with AWS services (CloudWatch, ALB, IAM)

### Architecture Components

**ECS Cluster**: A logical grouping of ECS tasks and services. Container Insights enabled for monitoring.

**ECS Service**: Maintains desired number of running tasks (e.g., 2 tasks for high availability). Integrates with Application Load Balancer for traffic distribution.

**ECS Task Definition**: Blueprint for containers including CPU (512 = 0.5 vCPU), memory (1024 MB = 1 GB), container image from ECR, environment variables for database connection, port mappings (1337), and CloudWatch logs configuration.

**Application Load Balancer (ALB)**: Distributes incoming traffic across multiple ECS tasks. Performs health checks on /admin endpoint. Uses target group with IP target type for Fargate. Listens on port 80 (HTTP).

**Target Group**: Routes traffic to ECS tasks on port 1337. Health check monitors application availability. Deregisters unhealthy tasks automatically.

**RDS PostgreSQL**: Managed database service for Strapi data. Connected via security groups allowing only ECS task access.

### Network Configuration

Uses AWS VPC with public and private subnets. ECS tasks run in private subnets with NAT Gateway for internet access. ALB runs in public subnets for user access. Security groups control traffic between components.

### Task Execution

**Launch Type**: FARGATE (serverless, no EC2 management)

**Network Mode**: awsvpc (each task gets its own ENI and IP address)

**Task Count**: Minimum 2 for high availability

**Auto-scaling**: Configured based on CPU/memory utilization

### IAM Roles

**Task Execution Role**: Allows ECS to pull images from ECR, push logs to CloudWatch, and retrieve secrets from Secrets Manager.

**Task Role**: Gives containers permissions to access AWS services (if needed).

### Deployment Process

Terraform creates all required resources (cluster, service, task definition, ALB, target groups, security groups). ECS service launches initial tasks in private subnets. Tasks pull Docker image from ECR. ALB begins routing traffic to healthy tasks. CloudWatch collects logs and metrics.

### Accessing the Application

Once deployed, access Strapi via ALB DNS name: `http://<ALB_DNS_NAME>/admin`

No direct access to tasks required (unlike EC2 SSH).

---

## 💡 Fargate Spot Configuration

### Overview
AWS Fargate Spot allows you to run ECS tasks at up to 70% discount compared to regular Fargate pricing. Suitable for fault-tolerant workloads where tasks can be interrupted.

### What is Fargate Spot?

Fargate Spot uses spare AWS compute capacity. AWS can interrupt tasks with 2-minute warning when capacity is needed. Best for stateless applications, background processing, and development/test environments.

### Cost Savings

**Regular Fargate**: $0.04048 per vCPU per hour + $0.004445 per GB per hour

**Fargate Spot**: Up to 70% cheaper

**Example**: For 0.5 vCPU + 1 GB memory running 24/7, regular Fargate costs ~$30/month, while Fargate Spot costs ~$9/month.

### Implementation

Modify ECS service capacity provider strategy to use Fargate Spot. Set base capacity on regular Fargate for guaranteed availability. Use Fargate Spot for additional tasks beyond base.

**Configuration**:
- Base: 1 task on FARGATE (always available)
- Additional: Tasks on FARGATE_SPOT (cost-optimized)

**Capacity Provider Strategy**:
- FARGATE: Base = 1, Weight = 1 (guaranteed task)
- FARGATE_SPOT: Base = 0, Weight = 4 (80% of additional tasks use Spot)

### When to Use Fargate Spot

**Good for**:
- Development and testing environments
- Stateless applications (like Strapi with RDS backend)
- Non-critical workloads
- Applications with graceful shutdown handling

**Not recommended for**:
- Production workloads requiring 100% uptime SLA
- Applications storing critical state in containers
- Real-time processing without retry logic

### Handling Interruptions

AWS sends SIGTERM signal 2 minutes before interruption. Application should handle graceful shutdown. ECS automatically launches replacement task. For Strapi, database state is preserved in RDS, so new task resumes normally.

### Configuration in Terraform

Update ECS service to use capacity provider strategy instead of launch type. Create capacity providers for FARGATE and FARGATE_SPOT. Configure weights to balance cost and availability.

---

## 🔄 Blue/Green Deployment with CodeDeploy

### Overview
Blue/Green deployment strategy enables zero-downtime deployments with automatic rollback capability. AWS CodeDeploy manages the deployment process, gradually shifting traffic from old version (Blue) to new version (Green).

### What is Blue/Green Deployment?

**Blue Environment**: Current production version running and serving traffic.

**Green Environment**: New version deployed in parallel, tested before receiving traffic.

**Traffic Shift**: Load balancer gradually redirects users from Blue to Green.

**Rollback**: If issues detected, instantly switch back to Blue.

**Cleanup**: Once Green is stable, terminate Blue environment.

### Why Blue/Green for Strapi?

**Zero Downtime**: Users never experience service interruption during deployments.

**Safe Testing**: New version runs in production environment before receiving traffic.

**Instant Rollback**: Revert to previous version in seconds if problems occur.

**Gradual Rollout**: Canary deployment tests new version with small percentage of traffic first.

### AWS Resources Required

**ECS Cluster and Service**: Runs Strapi containers on Fargate.

**Application Load Balancer (ALB)**: Routes traffic between Blue and Green environments.

**Two Target Groups**:
- Blue Target Group: Points to current version containers
- Green Target Group: Points to new version containers

**ALB Listener**: Switches between target groups during deployment.

**CodeDeploy Application**: Named "strapi-codedeploy-app", configured for ECS platform.

**CodeDeploy Deployment Group**: Manages deployment process and rollback configuration.

### Deployment Configuration

**Strategy**: CodeDeployDefault.ECSCanary10Percent5Minutes

**How it works**:
1. Deploy new version to Green target group
2. Shift 10% of traffic to Green
3. Monitor for 5 minutes for errors
4. If successful, shift remaining 90% to Green
5. If failures detected, automatic rollback to Blue

**Alternative Strategies**:
- ECSAllAtOnce: Immediate full traffic switch (faster but riskier)
- ECSLinear10PercentEvery1Minute: Gradual 10% increments every minute
- ECSCanary10Percent30Minutes: Longer monitoring period for safety

### Auto Rollback Configuration

Automatic rollback triggers on:
- Deployment failure
- CloudWatch alarm breach (high error rate, CPU, memory)
- Target group health check failures

**Rollback Process**: Traffic instantly switches back to Blue target group. Green environment terminated. No user impact during rollback.

### Load Balancer Configuration

**Production Traffic Route**: ALB listener on port 80 (HTTP).

**Target Groups**:
- strapi-tg-blue: Current production tasks
- strapi-tg-green: New deployment tasks

**Health Check**: Monitors /admin endpoint to verify application availability.

**Target Type**: IP (required for Fargate awsvpc networking).

### Deployment Process

**Step 1**: GitHub Actions CI pipeline builds new Docker image and pushes to ECR.

**Step 2**: Create new ECS Task Definition with updated image tag.

**Step 3**: Trigger CodeDeploy deployment with AppSpec content.

**Step 4**: CodeDeploy creates Green environment by launching new tasks with new task definition and registering them to Green target group.

**Step 5**: Health checks confirm Green tasks are healthy.

**Step 6**: Canary shift begins - 10% of traffic routes to Green for 5 minutes monitoring.

**Step 7**: If no errors detected, remaining 90% of traffic shifts to Green.

**Step 8**: Wait 5 minutes for final confirmation.

**Step 9**: Terminate Blue environment (old tasks) to save costs.

**If failures occur at any step**: Auto rollback switches traffic back to Blue, terminates Green environment, zero user impact.

### AppSpec Configuration

The AppSpec defines deployment instructions for CodeDeploy. Specifies which ECS service to update, which task definition to deploy, container name and port for load balancer, and traffic routing rules.

**GitHub Actions Deployment Trigger**: Creates AppSpec JSON with new task definition ARN. Dynamically injects container name (strapi) and port (1337). Submits deployment request to CodeDeploy. Monitors deployment progress.

### Deployment Group Settings

**Service Role**: IAM role with permissions for ECS and ALB operations.

**Deployment Style**: Blue/Green with traffic control enabled.

**Automatic Rollback**: Enabled on deployment failure events.

**Blue Instance Termination**: Wait 5 minutes after successful deployment before terminating Blue tasks.

**Deployment Ready Option**: Continue deployment automatically when Green is ready (no manual approval required).

### Benefits of This Setup

**Zero Downtime**: Users never experience service interruption.

**Gradual Rollout**: 10% canary deployment catches issues early.

**Automatic Safety**: Rollback triggers automatically on any failure.

**Cost Efficient**: Old environment terminated after successful deployment.

**Easy Monitoring**: CloudWatch provides visibility into deployment health.

**Repeatable Process**: Fully automated via GitHub Actions and Terraform.

### Monitoring Deployments

CodeDeploy console shows real-time deployment status. CloudWatch logs capture deployment events. ECS service events show task launches and terminations. ALB target group health shows which tasks are receiving traffic.

---

## 📊 CloudWatch Monitoring

### Overview
CloudWatch provides comprehensive monitoring for the Strapi application with logging, metrics collection, alarms, and dashboards. This ensures visibility into application health and enables proactive issue detection.

### CloudWatch Log Groups

**Log Group**: /ecs/strapi

**Purpose**: Centralized storage for all container logs from ECS tasks.

**Configuration**: Created via Terraform with 7-day retention policy (adjustable). Log streams automatically created for each ECS task. Logs include application output, error messages, and access logs.

### ECS Task Logging Configuration

**Log Driver**: awslogs (AWS CloudWatch Logs)

**Stream Prefix**: ecs/strapi (organizes logs by task)

**Auto-configuration**: Task definition includes CloudWatch logs configuration. IAM task execution role has permissions to create log streams and put log events.

### Key Metrics Collected

**CPU Utilization**: Percentage of allocated CPU used by tasks. Helps identify performance bottlenecks. Triggers auto-scaling when thresholds exceeded.

**Memory Utilization**: Percentage of allocated memory used. Prevents out-of-memory errors. Indicates if tasks need more memory allocation.

**Task Count**: Number of running tasks in the service. Shows auto-scaling activity. Indicates service health (tasks restarting frequently = issues).

**Network In/Out**: Data transferred to and from tasks. Monitors traffic patterns. Useful for capacity planning.

**Target Group Health**: Number of healthy vs unhealthy targets. Critical for load balancer routing. Triggers alarms if tasks fail health checks.

**Response Time**: Application load balancer target response time. Indicates application performance. High response time = potential performance issues.

### CloudWatch Alarms

**High CPU Alarm**: Triggers when CPU utilization exceeds 80% for 5 minutes. Action: Send SNS notification or trigger auto-scaling.

**High Memory Alarm**: Triggers when memory utilization exceeds 85%. Action: Alert operations team to investigate.

**Task Health Check Alarm**: Triggers when target group has unhealthy tasks. Action: Notify team immediately for investigation.

**Low Task Count Alarm**: Triggers when running task count drops below desired. Indicates tasks are failing and not recovering.

**Response Latency Alarm**: Triggers when ALB target response time exceeds 3 seconds. Indicates application performance degradation.

### CloudWatch Dashboards

**Optional Custom Dashboard**: Single view of all key metrics. Graphs showing CPU, memory, network, and task count trends. ALB request count and error rates. Target group health status. Log insights for quick log searching.

### Log Insights Queries

CloudWatch Logs Insights allows querying logs for troubleshooting:

**Find Errors**: Query to filter ERROR level logs in specific time range.

**Track API Requests**: Query to count requests by endpoint.

**Monitor Response Times**: Query to calculate average response times.

**Identify Slow Queries**: Query to find database queries exceeding thresholds.

### Monitoring Best Practices

**Set Appropriate Alarm Thresholds**: Balance between false positives and missing real issues.

**Use SNS for Notifications**: Email or Slack integration for team alerts.

**Regular Dashboard Review**: Weekly review of trends to identify gradual degradation.

**Log Retention Policy**: Balance between cost and audit requirements (7-30 days typical).

**Enable Container Insights**: Enhanced ECS cluster metrics for deeper visibility.

### Cost Considerations

**Log Storage**: First 5 GB per month free, then $0.50 per GB.

**Metrics**: First 10 custom metrics free, then $0.30 per metric.

**Alarms**: First 10 alarms free, then $0.10 per alarm.

**Logs Insights Queries**: $0.005 per GB scanned.

**Tip**: Use log retention policies to control costs. Archive older logs to S3 if needed for compliance.

### Integration with Deployment

CloudWatch metrics inform CodeDeploy about deployment health. If alarms trigger during Blue/Green deployment, automatic rollback occurs. Post-deployment monitoring ensures Green environment stability before terminating Blue.

### Accessing Logs and Metrics

**AWS Console**: Navigate to CloudWatch → Log Groups → /ecs/strapi for logs. CloudWatch → Metrics → ECS for performance metrics.

**AWS CLI**: Use `aws logs tail` for real-time log streaming. Use `aws cloudwatch get-metric-statistics` for programmatic access.

**Terraform Outputs**: Log group ARN and dashboard URL exported as outputs.

### Troubleshooting with CloudWatch

**Application not starting**: Check ECS task logs for startup errors. Look for database connection failures or missing environment variables.

**High CPU usage**: Review log insights for resource-intensive operations. Check for infinite loops or inefficient queries.

**Memory leaks**: Monitor memory utilization trend over time. Investigate if memory continuously increases without dropping.

**Failed deployments**: Check CodeDeploy logs in CloudWatch. Review target group health check failures.

---

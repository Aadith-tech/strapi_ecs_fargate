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


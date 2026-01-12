# Strapi CMS on AWS with Docker & ECR

A production-ready deployment of Strapi CMS on AWS infrastructure using Terraform, Docker, and Amazon ECR.

## 🏗️ Architecture

```
Internet → ALB → EC2 (Docker) → RDS PostgreSQL
                 ↓
            ECR (Docker Images)
                 ↑
            Bastion Host (SSH Access)
```

**Key Components:**
- **Application Load Balancer (ALB)**: Public-facing entry point
- **EC2 Instance**: Runs Strapi in Docker container (private subnet)
- **RDS PostgreSQL**: Managed database (private subnet)
- **ECR**: Stores Docker images
- **Bastion Host**: Secure SSH access to private instances
- **VPC**: Isolated network with public and private subnets

## ✨ Features

- 🐳 **Dockerized Strapi**: Containerized application for consistency
- 🔒 **Secure Architecture**: Private subnets for app and database
- 📦 **ECR Integration**: Automated image storage and deployment
- 🚀 **Infrastructure as Code**: Complete Terraform configuration
- 🔐 **Bastion Host**: Secure SSH access via jump host
- 🔄 **Auto-restart**: Docker container restarts on failure
- 💾 **Encrypted Storage**: EBS and RDS encryption enabled

## 📋 Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured with profile: `iamadmin-general`
- Terraform >= 1.0
- Docker Desktop installed
- SSH key pair generated

## 🚀 Quick Start

### 1. Generate SSH Key

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/strapi_dev_key -C "strapi-dev-key"

# Get the public key
cat ~/.ssh/strapi_dev_key.pub
```

### 2. Configure Variables

Update `terraform/dev.tfvars` with your settings:

```terraform
environment = "dev"
aws_region  = "ap-south-1"

# Add your SSH public key
ssh_public_key = "ssh-rsa AAAA... your-key-here"

# Database password (no @, /, ", or spaces allowed)
db_password = "YourSecurePassword123"

# Restrict bastion access to your IP
bastion_allowed_cidrs = ["YOUR_IP/32"]
```

### 3. Build & Push Docker Image

```bash
cd strapi_Ec2

# Build for linux/amd64 (required for EC2)
docker build --platform linux/amd64 -t dev-strapi-app:latest .

# Login to ECR (after creating repository)
aws ecr get-login-password --region ap-south-1 --profile iamadmin-general | \
  docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com

# Tag and push
docker tag dev-strapi-app:latest YOUR_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/dev-strapi-app:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/dev-strapi-app:latest
```

### 4. Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Create ECR repository first
terraform apply -var-file=dev.tfvars \
  -target=aws_ecr_repository.strapi \
  -target=aws_iam_role.ec2_ecr_role \
  -target=aws_iam_role_policy.ec2_ecr_policy \
  -target=aws_iam_instance_profile.ec2_ecr_profile

# Build and push Docker image (see step 3)

# Deploy everything
terraform apply -var-file=dev.tfvars
```

### 5. Access Your Strapi

```bash
# Get ALB URL
terraform output alb_url

# Open in browser
http://YOUR_ALB_URL/admin
```

## 🔧 Configuration

### Environment Variables

The following environment variables are automatically configured:

```env
HOST=0.0.0.0
PORT=1337
NODE_ENV=dev
DATABASE_CLIENT=postgres
DATABASE_HOST=<rds-endpoint>
DATABASE_PORT=5432
DATABASE_NAME=strapi_dev
DATABASE_USERNAME=strapi_admin
DATABASE_PASSWORD=<your-password>
DATABASE_SSL=true
```

### Resource Sizing

**Development:**
- EC2: t2.medium
- RDS: db.t3.micro
- Bastion: t2.micro

**Production:**
Update in `prod.tfvars` for larger instances.

## 🔐 SSH Access

### Access Bastion Host

```bash
ssh -i ~/.ssh/strapi_dev_key ec2-user@<BASTION_PUBLIC_IP>
```

### Access Private EC2 (via ProxyJump)

```bash
ssh -i ~/.ssh/strapi_dev_key -J ec2-user@<BASTION_IP> ec2-user@<EC2_PRIVATE_IP>
```

### Useful Commands

```bash
# Check Docker container
sudo docker ps -a

# View logs
sudo docker logs dev-strapi-app

# Follow logs (live)
sudo docker logs -f dev-strapi-app

# Restart container
sudo docker restart dev-strapi-app

# View installation log
sudo tail -f /var/log/strapi-install.log
```

## 📁 Project Structure

```
strapi_ecs_fargate/
├── Dockerfile              # Docker image definition
├── package.json           # Strapi dependencies
├── src/                   # Strapi source code
├── config/                # Strapi configuration
└── terraform/
    ├── main.tf           # Provider configuration
    ├── vpc.tf            # VPC and networking
    ├── ec2.tf            # EC2 instance
    ├── ecr.tf            # ECR repository
    ├── iam.tf            # IAM roles
    ├── rds.tf            # PostgreSQL database
    ├── alb.tf            # Load balancer
    ├── bastion.tf        # Bastion host
    ├── *_sg.tf           # Security groups
    ├── user_data.sh      # EC2 bootstrap script
    ├── variables.tf      # Variable definitions
    ├── outputs.tf        # Output values
    ├── dev.tfvars        # Dev environment config
    └── prod.tfvars       # Prod environment config
```

## 🔄 Updating Your Application

### Option 1: Rebuild & Redeploy EC2

```bash
# 1. Rebuild Docker image
docker build --platform linux/amd64 -t dev-strapi-app:latest .

# 2. Push to ECR
docker tag dev-strapi-app:latest YOUR_ECR_URL:latest
docker push YOUR_ECR_URL:latest

# 3. Recreate EC2 instance
cd terraform
terraform destroy -target=aws_instance.strapi -var-file=dev.tfvars
terraform apply -target=aws_instance.strapi -var-file=dev.tfvars
```

### Option 2: Update Running Container

```bash
# SSH to EC2
ssh -i ~/.ssh/strapi_dev_key -J ec2-user@<BASTION> ec2-user@<EC2_IP>

# Pull new image and restart
sudo docker pull YOUR_ECR_URL:latest
sudo docker restart dev-strapi-app
```

## 💰 Cost Estimate (Monthly)

| Resource | Type | Cost (USD) |
|----------|------|------------|
| EC2 (Strapi) | t2.medium | ~$33 |
| EC2 (Bastion) | t2.micro | ~$8.50 |
| RDS PostgreSQL | db.t3.micro | ~$15 |
| ALB | - | ~$18 |
| NAT Gateway | - | ~$32 |
| ECR Storage | per GB | ~$0.10/GB |
| **Total** | | **~$106-120/month** |

**Cost Saving Tips:**
- Stop bastion when not needed
- Use smaller instances for testing
- Destroy infrastructure when not in use: `terraform destroy`

## 🛠️ Troubleshooting

### Container Won't Start

```bash
# Check logs
sudo docker logs dev-strapi-app

# Common issues:
# - Database connection failed (check RDS security group)
# - SSL/TLS errors (ensure DATABASE_SSL=true)
# - Port conflicts (check: netstat -tlnp | grep 1337)
```

### ALB Shows 502 Bad Gateway

```bash
# Verify container is running
sudo docker ps -a

# Check if Strapi is responding
curl localhost:1337

# View health check logs
sudo docker logs dev-strapi-app | grep health
```

### Can't SSH to Bastion

```bash
# Check your current IP
curl ifconfig.me

# Update bastion security group in dev.tfvars
bastion_allowed_cidrs = ["YOUR_NEW_IP/32"]

# Apply changes
terraform apply -var-file=dev.tfvars
```

### Database Connection Issues

Ensure:
- RDS security group allows EC2 security group
- DATABASE_SSL=true (RDS requires encrypted connections)
- Database credentials are correct

## 🔒 Security Best Practices

- ✅ Change database password from default
- ✅ Restrict bastion SSH to your IP only
- ✅ Enable MFA for AWS account
- ✅ Use AWS Secrets Manager for sensitive data (optional)
- ✅ Enable CloudWatch logging
- ✅ Regular security updates: `yum update`

## 📊 Monitoring

### CloudWatch Logs

Logs are available in:
- EC2: `/var/log/strapi-install.log`
- Docker: `docker logs dev-strapi-app`

### Health Checks

ALB health checks endpoint: `/_health`

### Metrics

Monitor via AWS Console:
- EC2 CPU/Memory utilization
- RDS connections and performance
- ALB request count and latency

## 🧹 Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy -var-file=dev.tfvars
```

**Note:** ECR repository must be empty or use `force_delete = true` in `ecr.tf`.

## 📝 Common Issues & Fixes

### Issue: Architecture Mismatch Error

```
no matching manifest for linux/amd64
```

**Fix:** Always build with `--platform linux/amd64`:
```bash
docker build --platform linux/amd64 -t dev-strapi-app:latest .
```

### Issue: Missing `nc` Command

**Fix:** Already included in `user_data.sh`:
```bash
yum install -y postgresql15 nc
```

### Issue: Database SSL Error

```
no pg_hba.conf entry for host ... no encryption
```

**Fix:** Set `DATABASE_SSL=true` in environment variables.



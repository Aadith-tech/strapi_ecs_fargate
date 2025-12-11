#!/bin/bash

set -e

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "==========================================="
echo "Starting Strapi EC2 Setup - $(date)"
echo "==========================================="

echo "[1/8] Updating system packages..."
yum update -y

echo "[2/8] Installing Docker..."
yum install -y docker

echo "[3/8] Starting Docker service..."
systemctl start docker
systemctl enable docker

usermod -aG docker ec2-user

sleep 5

echo "[4/8] Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws

echo "[5/8] Creating Strapi directory..."
mkdir -p /home/ec2-user/strapi
cd /home/ec2-user/strapi

echo "[6/8] Creating environment file..."
cat > .env << 'ENVFILE'
# Server
HOST=0.0.0.0
PORT=1337

# Database - RDS PostgreSQL
DATABASE_CLIENT=postgres
DATABASE_HOST=${db_host}
DATABASE_PORT=${db_port}
DATABASE_NAME=${db_name}
DATABASE_USERNAME=${db_username}
DATABASE_PASSWORD=${db_password}
DATABASE_SSL=true
DATABASE_SSL_REJECT_UNAUTHORIZED=false

# Strapi Secrets
APP_KEYS=${app_keys}
API_TOKEN_SALT=${api_token_salt}
ADMIN_JWT_SECRET=${admin_jwt_secret}
JWT_SECRET=${jwt_secret}

ENVFILE

echo "✅ Environment file created"
chown -R ec2-user:ec2-user /home/ec2-user/strapi

echo "[7/8] Logging into ECR and pulling Docker image..."
# Check if image is from ECR (contains .amazonaws.com)
DOCKER_IMAGE="${docker_image}"
if [[ "$DOCKER_IMAGE" == *".amazonaws.com"* ]]; then
    echo "ECR image detected, authenticating..."
    AWS_REGION="${aws_region}"
    ECR_REGISTRY=$(echo $DOCKER_IMAGE | cut -d'/' -f1)
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
fi

docker pull $DOCKER_IMAGE

echo "[8/8] Starting Strapi container..."
docker run -d \
  --name strapi \
  --restart unless-stopped \
  -p 1337:1337 \
  --env-file /home/ec2-user/strapi/.env \
  $DOCKER_IMAGE

echo "==========================================="
echo "🎉 Strapi EC2 Setup Complete! - $(date)"
echo "==========================================="
echo "Container Status:"
docker ps
echo ""
echo "Strapi URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):1337"
echo "==========================================="







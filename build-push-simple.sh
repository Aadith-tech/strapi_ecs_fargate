#!/bin/bash
set -e

echo "========================================="
echo "Building and Pushing Strapi to ECR"
echo "========================================="

# Hardcoded values
ECR_REPO="588738580776.dkr.ecr.ap-south-1.amazonaws.com/dev-strapi-app"
ECR_NAME="dev-strapi-app"
AWS_REGION="ap-south-1"
AWS_PROFILE="iamadmin-general"

echo "ECR Repository: $ECR_REPO"
echo "Region: $AWS_REGION"
echo ""

# Step 1: Login to ECR
echo "Step 1: Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION --profile $AWS_PROFILE | docker login --username AWS --password-stdin $ECR_REPO
echo "✓ Logged in to ECR"
echo ""

# Step 2: Build Docker image
echo "Step 2: Building Docker image (this may take 2-5 minutes)..."
docker build -t $ECR_NAME:latest .
echo "✓ Image built successfully"
echo ""

# Step 3: Tag image
echo "Step 3: Tagging image..."
docker tag $ECR_NAME:latest $ECR_REPO:latest
echo "✓ Image tagged"
echo ""

# Step 4: Push to ECR
echo "Step 4: Pushing to ECR..."
docker push $ECR_REPO:latest
echo "✓ Image pushed successfully"
echo ""

echo "========================================="
echo "✓ Build and Push Complete!"
echo "========================================="
echo "Image: $ECR_REPO:latest"
echo ""
echo "Next: Deploy infrastructure with:"
echo "cd terraform && terraform apply -var-file=dev.tfvars"


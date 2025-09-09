#!/bin/bash

set -e

echo "🚀 Quick Chattingo EKS deployment for masim01.shop"

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo "❌ AWS credentials not configured. Please run: aws configure"
    exit 1
fi

# Get AWS details
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "✅ AWS Account: $AWS_ACCOUNT_ID"
echo "✅ Region: $AWS_REGION"

# Create ECR repositories
echo "📦 Creating ECR repositories..."
aws ecr create-repository --repository-name chattingo-backend --region ${AWS_REGION} 2>/dev/null || echo "Backend repo exists"
aws ecr create-repository --repository-name chattingo-frontend --region ${AWS_REGION} 2>/dev/null || echo "Frontend repo exists"

# Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Build and push images
echo "🏗️ Building backend image..."
docker build -t ${ECR_REGISTRY}/chattingo-backend:latest ./backend

echo "🏗️ Building frontend image..."
docker build -t ${ECR_REGISTRY}/chattingo-frontend:latest ./frontend \
    --build-arg REACT_APP_API_URL="https://masim01.shop/api" \
    --build-arg REACT_APP_WS_URL="wss://masim01.shop/ws"

echo "📤 Pushing images..."
docker push ${ECR_REGISTRY}/chattingo-backend:latest
docker push ${ECR_REGISTRY}/chattingo-frontend:latest

# Update Helm values with ECR URLs
sed -i "s|repository: chattingo-backend|repository: ${ECR_REGISTRY}/chattingo-backend|g" helm/chattingo/values.yaml
sed -i "s|repository: chattingo-frontend|repository: ${ECR_REGISTRY}/chattingo-frontend|g" helm/chattingo/values.yaml

echo "✅ Images built and pushed successfully!"
echo ""
echo "Next steps:"
echo "1. Create EKS cluster: eksctl create cluster -f k8s/eks-cluster.yaml"
echo "2. Install monitoring: kubectl create namespace monitoring && helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f k8s/monitoring-values.yaml"
echo "3. Deploy app: helm repo add bitnami https://charts.bitnami.com/bitnami && helm install chattingo ./helm/chattingo"
echo ""
echo "Your domain: masim01.shop"
echo "Your email: mdaasim2701@gmail.com"

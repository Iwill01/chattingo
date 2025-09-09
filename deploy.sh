#!/bin/bash

set -e

echo "🚀 Starting Chattingo EKS deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    if ! command -v eksctl &> /dev/null; then
        echo -e "${RED}eksctl is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}kubectl is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}helm is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All prerequisites are installed${NC}"
}

# Create EKS cluster
create_cluster() {
    echo -e "${YELLOW}Creating EKS cluster...${NC}"
    eksctl create cluster -f k8s/eks-cluster.yaml
    echo -e "${GREEN}✓ EKS cluster created${NC}"
}

# Install AWS Load Balancer Controller
install_alb_controller() {
    echo -e "${YELLOW}Installing AWS Load Balancer Controller...${NC}"
    
    # Create IAM role
    eksctl create iamserviceaccount \
        --cluster=chattingo-cluster \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name AmazonEKSLoadBalancerControllerRole \
        --attach-policy-arn=arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess \
        --approve
    
    # Install controller
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=chattingo-cluster \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
    
    echo -e "${GREEN}✓ AWS Load Balancer Controller installed${NC}"
}

# Install monitoring stack
install_monitoring() {
    echo -e "${YELLOW}Installing monitoring stack (Prometheus + Grafana)...${NC}"
    
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
        -n monitoring \
        -f k8s/monitoring-values.yaml
    
    # Apply custom alerts
    kubectl apply -f k8s/prometheus-rules.yaml
    kubectl apply -f k8s/service-monitor.yaml
    
    echo -e "${GREEN}✓ Monitoring stack installed${NC}"
}

# Install logging stack
install_logging() {
    echo -e "${YELLOW}Installing logging stack (Fluent Bit)...${NC}"
    
    helm repo add fluent https://fluent.github.io/helm-charts
    helm repo update
    
    helm install fluent-bit fluent/fluent-bit \
        -n kube-system \
        -f k8s/fluent-bit-values.yaml
    
    echo -e "${GREEN}✓ Logging stack installed${NC}"
}

# Build and push Docker images
build_and_push_images() {
    echo -e "${YELLOW}Building and pushing Docker images...${NC}"
    
    # Get AWS account ID and region
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    AWS_REGION=$(aws configure get region)
    ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    
    # Create ECR repositories
    aws ecr create-repository --repository-name chattingo-backend --region ${AWS_REGION} || true
    aws ecr create-repository --repository-name chattingo-frontend --region ${AWS_REGION} || true
    
    # Login to ECR
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
    
    # Build and push backend
    docker build -t chattingo-backend ./backend
    docker tag chattingo-backend:latest ${ECR_REGISTRY}/chattingo-backend:latest
    docker push ${ECR_REGISTRY}/chattingo-backend:latest
    
    # Build and push frontend
    docker build -t chattingo-frontend ./frontend \
        --build-arg REACT_APP_API_URL="https://masim01.shop/api" \
        --build-arg REACT_APP_WS_URL="wss://masim01.shop/ws"
    docker tag chattingo-frontend:latest ${ECR_REGISTRY}/chattingo-frontend:latest
    docker push ${ECR_REGISTRY}/chattingo-frontend:latest
    
    # Update values.yaml with ECR URLs
    sed -i "s|chattingo-backend|${ECR_REGISTRY}/chattingo-backend|g" helm/chattingo/values.yaml
    sed -i "s|chattingo-frontend|${ECR_REGISTRY}/chattingo-frontend|g" helm/chattingo/values.yaml
    
    echo -e "${GREEN}✓ Docker images built and pushed${NC}"
}

# Deploy application
deploy_application() {
    echo -e "${YELLOW}Deploying Chattingo application...${NC}"
    
    # Add Bitnami repo for MySQL
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    
    # Deploy application
    helm install chattingo ./helm/chattingo
    
    echo -e "${GREEN}✓ Application deployed${NC}"
}

# Main deployment function
main() {
    echo -e "${GREEN}🎯 Chattingo EKS Deployment Script${NC}"
    echo "This script will deploy Chattingo to AWS EKS with monitoring and logging"
    echo ""
    
    check_prerequisites
    
    read -p "Do you want to create a new EKS cluster? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_cluster
        install_alb_controller
    fi
    
    read -p "Do you want to install monitoring stack? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_monitoring
    fi
    
    read -p "Do you want to install logging stack? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_logging
    fi
    
    read -p "Do you want to build and push Docker images? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        build_and_push_images
    fi
    
    read -p "Do you want to deploy the application? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_application
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Deployment completed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Update your domain DNS to point to the ALB"
    echo "2. Update SSL certificate ARN in values.yaml"
    echo "3. Configure email settings in monitoring-values.yaml"
    echo "4. Access Grafana at: http://grafana.your-domain.com (admin/admin123)"
    echo ""
    echo "Useful commands:"
    echo "kubectl get pods -A"
    echo "kubectl get svc -A"
    echo "kubectl logs -f deployment/chattingo-backend"
}

main "$@"

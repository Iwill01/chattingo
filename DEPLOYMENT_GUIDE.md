# Chattingo EKS Deployment Guide

This guide will help you deploy the Chattingo application to AWS EKS with comprehensive monitoring, logging, and alerting.

## Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **eksctl** - EKS cluster management tool
3. **kubectl** - Kubernetes command-line tool
4. **helm** - Kubernetes package manager
5. **Docker** - For building images

## Quick Start

```bash
# Make the deployment script executable
chmod +x deploy.sh

# Run the deployment script
./deploy.sh
```

## Manual Deployment Steps

### 1. Create EKS Cluster

```bash
eksctl create cluster -f k8s/eks-cluster.yaml
```

### 2. Install AWS Load Balancer Controller

```bash
# Create IAM service account
eksctl create iamserviceaccount \
    --cluster=chattingo-cluster \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --attach-policy-arn=arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess \
    --approve

# Install controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=chattingo-cluster \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller
```

### 3. Install Monitoring Stack

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    -n monitoring \
    -f k8s/monitoring-values.yaml

# Apply custom alerts
kubectl apply -f k8s/prometheus-rules.yaml
kubectl apply -f k8s/service-monitor.yaml
```

### 4. Install Logging Stack

```bash
helm repo add fluent https://fluent.github.io/helm-charts
helm install fluent-bit fluent/fluent-bit \
    -n kube-system \
    -f k8s/fluent-bit-values.yaml
```

### 5. Build and Push Images

```bash
# Get AWS account details
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Create ECR repositories
aws ecr create-repository --repository-name chattingo-backend
aws ecr create-repository --repository-name chattingo-frontend

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Build and push images
docker build -t ${ECR_REGISTRY}/chattingo-backend:latest ./backend
docker push ${ECR_REGISTRY}/chattingo-backend:latest

docker build -t ${ECR_REGISTRY}/chattingo-frontend:latest ./frontend
docker push ${ECR_REGISTRY}/chattingo-frontend:latest
```

### 6. Deploy Application

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install chattingo ./helm/chattingo
```

## Configuration

### Email Notifications

Update `k8s/monitoring-values.yaml`:

```yaml
alertmanager:
  config:
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
      smtp_from: 'your-alerts@gmail.com'
      smtp_auth_username: 'your-email@gmail.com'
      smtp_auth_password: 'your-app-password'
    receivers:
    - name: 'web.hook'
      email_configs:
      - to: 'admin@yourdomain.com'
```

### Domain Configuration

Update `helm/chattingo/values.yaml`:

```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account:certificate/cert-id
  hosts:
    - host: your-domain.com
```

### Backend Metrics

Add to `backend/pom.xml`:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

Add to `application.properties`:

```properties
management.endpoints.web.exposure.include=health,info,prometheus,metrics
management.endpoint.prometheus.enabled=true
management.metrics.export.prometheus.enabled=true
```

## Monitoring & Alerting

### Grafana Access

- URL: `http://grafana.your-domain.com`
- Username: `admin`
- Password: `admin123`

### Pre-configured Dashboards

1. **Spring Boot Dashboard** (ID: 12900)
2. **Kubernetes Cluster Dashboard** (ID: 7249)

### Alerts Configured

- Application down alerts
- Pod crash loop detection
- High CPU/Memory usage
- Database connectivity issues

### Log Access

Logs are automatically sent to CloudWatch Logs:
- Log Group: `/aws/eks/chattingo-cluster/application`
- Stream Prefix: `fluentbit-`

## Useful Commands

```bash
# Check cluster status
kubectl get nodes

# Check all pods
kubectl get pods -A

# Check application pods
kubectl get pods -l app.kubernetes.io/name=chattingo

# Check services
kubectl get svc

# Check ingress
kubectl get ingress

# View logs
kubectl logs -f deployment/chattingo-backend
kubectl logs -f deployment/chattingo-frontend

# Scale application
kubectl scale deployment chattingo-backend --replicas=3

# Update application
helm upgrade chattingo ./helm/chattingo

# Port forward to Grafana (if ingress not working)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

## Troubleshooting

### Common Issues

1. **Images not pulling**: Ensure ECR repositories exist and images are pushed
2. **Ingress not working**: Check ALB controller installation and certificate ARN
3. **Database connection**: Verify MySQL service is running and credentials are correct
4. **Monitoring not working**: Check ServiceMonitor labels match service labels

### Health Checks

```bash
# Check application health
kubectl get pods -l app.kubernetes.io/name=chattingo
kubectl describe pod <pod-name>

# Check monitoring stack
kubectl get pods -n monitoring
kubectl get servicemonitor -n monitoring

# Check logs
kubectl logs -n kube-system -l app.kubernetes.io/name=fluent-bit
```

## Security Considerations

1. **Network Policies**: Implement network policies for pod-to-pod communication
2. **RBAC**: Configure proper role-based access control
3. **Secrets Management**: Use AWS Secrets Manager or Kubernetes secrets
4. **Image Scanning**: Enable ECR image scanning
5. **Pod Security**: Implement pod security standards

## Cost Optimization

1. **Right-sizing**: Monitor resource usage and adjust requests/limits
2. **Spot Instances**: Use spot instances for non-critical workloads
3. **Auto Scaling**: Configure cluster autoscaler
4. **Storage**: Use appropriate storage classes

## Backup Strategy

1. **Database**: Configure automated RDS backups if using RDS
2. **Persistent Volumes**: Implement volume snapshots
3. **Configuration**: Store Helm values and K8s manifests in version control

## Next Steps

1. Set up CI/CD pipeline with GitHub Actions or AWS CodePipeline
2. Implement blue-green deployments
3. Add more comprehensive monitoring dashboards
4. Set up disaster recovery procedures
5. Implement security scanning and compliance checks

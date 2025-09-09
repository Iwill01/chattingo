# 💬 Chattingo - Real-time Chat Application

A modern, scalable chat application built with React, Spring Boot, and deployed on AWS EKS with comprehensive monitoring and alerting.

## 🚀 Live Demo

- **Application**: [https://masim01.shop](https://masim01.shop)
- **Monitoring**: [https://grafana.masim01.shop](https://grafana.masim01.shop)

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Frontend│    │ Spring Boot API │    │   MySQL Database│
│     (Nginx)     │◄──►│   (WebSocket)   │◄──►│                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌─────────────────────────────────────────────────┐
         │              AWS EKS Cluster                    │
         │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐│
         │  │ Prometheus  │  │   Grafana   │  │AlertManager││
         │  │ Monitoring  │  │ Dashboard   │  │   Email   ││
         │  └─────────────┘  └─────────────┘  └──────────┘│
         └─────────────────────────────────────────────────┘
```

## 🛠️ Tech Stack

### Frontend
- **React 18** - Modern UI framework
- **Redux Toolkit** - State management
- **Tailwind CSS** - Utility-first styling
- **WebSocket** - Real-time communication
- **Nginx** - Web server

### Backend
- **Spring Boot 3** - Java framework
- **Spring Security** - Authentication & authorization
- **JWT** - Token-based authentication
- **WebSocket** - Real-time messaging
- **JPA/Hibernate** - Database ORM
- **MySQL** - Relational database

### DevOps & Infrastructure
- **AWS EKS** - Kubernetes orchestration
- **Docker** - Containerization
- **Helm** - Kubernetes package management
- **Prometheus** - Metrics collection
- **Grafana** - Monitoring dashboards
- **AlertManager** - Email notifications
- **AWS ALB** - Load balancing
- **ECR** - Container registry

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+
- Java 17+
- Maven 3.8+

### Local Development

1. **Clone the repository**
```bash
git clone https://github.com/Iwill01/chattingo.git
cd chattingo
```

2. **Start with Docker Compose**
```bash
docker-compose up -d
```

3. **Access the application**
- Frontend: http://localhost:80
- Backend API: http://localhost:8080
- Database: localhost:3306

### Environment Variables

Create `.env` files in respective directories:

**Backend (.env)**
```env
SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/chattingo_db
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=root
JWT_SECRET=your-secret-key-here
```

**Frontend (.env)**
```env
REACT_APP_API_URL=http://localhost:8080/api
REACT_APP_WS_URL=ws://localhost:8080/ws
```

## ☁️ AWS EKS Deployment

### Prerequisites
- AWS CLI configured
- kubectl installed
- eksctl installed
- helm installed
- Docker installed

### Deploy to EKS

1. **Run the deployment script**
```bash
chmod +x deploy.sh
./deploy.sh
```

2. **Or deploy manually**
```bash
# Create EKS cluster
eksctl create cluster -f k8s/eks-cluster.yaml

# Install monitoring
kubectl create namespace monitoring
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring -f k8s/monitoring-values.yaml

# Deploy application
helm install chattingo ./helm/chattingo
```

### Configuration

Update the following files with your values:

- `k8s/monitoring-values.yaml` - Email settings
- `helm/chattingo/values.yaml` - Domain and SSL certificate
- `deploy.sh` - AWS account details

## 📊 Monitoring & Alerting

### Grafana Dashboards
- **Spring Boot Metrics** - Application performance
- **Kubernetes Cluster** - Infrastructure monitoring
- **Custom Chattingo Dashboard** - Business metrics

### Email Alerts
- Application crashes
- High CPU/Memory usage
- Database connectivity issues
- Pod restart detection

### Access Monitoring
```bash
# Port forward to Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Default credentials: admin/admin123
```

## 🔧 Development

### Backend Development
```bash
cd backend
./mvnw spring-boot:run
```

### Frontend Development
```bash
cd frontend
npm install
npm start
```

### Database Setup
```bash
# Run MySQL container
docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=chattingo_db \
  -p 3306:3306 mysql:8.0
```

## 📝 API Documentation

### Authentication Endpoints
- `POST /api/auth/signup` - User registration
- `POST /api/auth/signin` - User login
- `POST /api/auth/signout` - User logout

### Chat Endpoints
- `GET /api/messages` - Get chat messages
- `POST /api/messages` - Send message
- `WebSocket /ws` - Real-time messaging

### User Endpoints
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update profile

## 🧪 Testing

### Backend Tests
```bash
cd backend
./mvnw test
```

### Frontend Tests
```bash
cd frontend
npm test
```

## 🚀 CI/CD Pipeline

The repository includes GitHub Actions workflows for:
- Automated testing
- Docker image building
- EKS deployment
- Security scanning

## 📈 Performance

- **Real-time messaging** with WebSocket
- **Auto-scaling** based on CPU usage
- **Load balancing** with AWS ALB
- **Database connection pooling**
- **CDN integration** for static assets

## 🔒 Security

- JWT-based authentication
- HTTPS/WSS encryption
- CORS configuration
- SQL injection prevention
- XSS protection
- Security headers

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Iwill01** - *Initial work* - [Iwill01](https://github.com/Iwill01)

## 🙏 Acknowledgments

- Spring Boot community
- React community
- Kubernetes community
- AWS documentation

## 📞 Support

For support, email mdaasim2701@gmail.com or create an issue in this repository.

---

⭐ **Star this repository if you found it helpful!**

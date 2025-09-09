# GitHub Repository Setup Guide

This guide will help you create a GitHub repository for your Chattingo application.

## Option 1: Automated Setup (Recommended)

### Prerequisites
1. Install GitHub CLI:
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
```

2. Authenticate with GitHub:
```bash
gh auth login
```

### Create Repository
Run the automated setup script:
```bash
./create-github-repo.sh
```

## Option 2: Manual Setup

### 1. Create Repository on GitHub
1. Go to [GitHub](https://github.com)
2. Click "New repository"
3. Name: `chattingo`
4. Description: `Real-time chat application with React, Spring Boot, and AWS EKS`
5. Choose Public or Private
6. Don't initialize with README (we already have one)
7. Click "Create repository"

### 2. Add Remote and Push
```bash
git remote add origin https://github.com/YOUR_USERNAME/chattingo.git
git branch -M main
git push -u origin main
```

## Post-Setup Configuration

### 1. Add GitHub Secrets for CI/CD
Go to your repository → Settings → Secrets and variables → Actions

Add these secrets:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### 2. Update Repository URLs
Update the following files with your actual GitHub username:
- `README.md` - Update clone URL and links
- `CONTRIBUTING.md` - Update issue tracker links
- `.github/workflows/ci-cd.yml` - Verify repository references

### 3. Configure Branch Protection (Optional)
Go to Settings → Branches → Add rule:
- Branch name pattern: `main`
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging

### 4. Enable GitHub Pages (Optional)
Go to Settings → Pages:
- Source: Deploy from a branch
- Branch: `main` / `docs` (if you add documentation)

## Repository Structure

Your repository now includes:

```
chattingo/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions CI/CD
├── backend/                   # Spring Boot application
├── frontend/                  # React application
├── helm/                      # Helm charts for Kubernetes
├── k8s/                       # Kubernetes configurations
├── nginx/                     # Nginx configuration
├── .gitignore                 # Git ignore rules
├── README.md                  # Project documentation
├── CONTRIBUTING.md            # Contribution guidelines
├── LICENSE                    # MIT License
├── docker-compose.yml         # Local development
├── deploy.sh                  # EKS deployment script
└── DEPLOYMENT_GUIDE.md        # Deployment instructions
```

## Features Included

✅ **Complete Application Code**
- React frontend with Redux
- Spring Boot backend with WebSocket
- MySQL database integration

✅ **Containerization**
- Docker configurations
- Docker Compose for local development

✅ **Kubernetes Deployment**
- Helm charts for easy deployment
- EKS cluster configuration
- Auto-scaling and load balancing

✅ **Monitoring & Alerting**
- Prometheus metrics collection
- Grafana dashboards
- Email alerts for crashes

✅ **CI/CD Pipeline**
- GitHub Actions workflow
- Automated testing
- Docker image building
- EKS deployment

✅ **Documentation**
- Comprehensive README
- API documentation
- Deployment guides
- Contributing guidelines

## Next Steps

1. **Customize the application** with your specific requirements
2. **Set up CI/CD** by adding GitHub secrets
3. **Deploy to EKS** using the provided scripts
4. **Configure monitoring** with your email for alerts
5. **Invite collaborators** to contribute to the project

## Support

If you encounter any issues:
1. Check the [Issues](https://github.com/YOUR_USERNAME/chattingo/issues) page
2. Create a new issue with detailed information
3. Contact: mdaasim2701@gmail.com

Happy coding! 🚀

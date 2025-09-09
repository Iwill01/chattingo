#!/bin/bash

echo "🚀 GitHub Repository Setup for Chattingo"
echo "========================================"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Please install it first:"
    echo "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    echo "sudo apt update && sudo apt install gh"
    echo ""
    echo "Then run: gh auth login"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ You're not authenticated with GitHub."
    echo "Please run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is installed and authenticated"
echo ""

# Get repository details
read -p "Enter repository name (default: chattingo): " REPO_NAME
REPO_NAME=${REPO_NAME:-chattingo}

read -p "Enter repository description (default: Real-time chat application with React, Spring Boot, and AWS EKS): " REPO_DESC
REPO_DESC=${REPO_DESC:-"Real-time chat application with React, Spring Boot, and AWS EKS"}

read -p "Make repository public? (y/n, default: y): " IS_PUBLIC
IS_PUBLIC=${IS_PUBLIC:-y}

if [[ $IS_PUBLIC =~ ^[Yy]$ ]]; then
    VISIBILITY="--public"
else
    VISIBILITY="--private"
fi

echo ""
echo "Creating GitHub repository with:"
echo "  Name: $REPO_NAME"
echo "  Description: $REPO_DESC"
echo "  Visibility: $(if [[ $IS_PUBLIC =~ ^[Yy]$ ]]; then echo 'Public'; else echo 'Private'; fi)"
echo ""

# Create the repository
echo "📦 Creating GitHub repository..."
gh repo create $REPO_NAME $VISIBILITY --description "$REPO_DESC" --source=. --push

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Repository created successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Visit your repository: https://github.com/$(gh api user --jq .login)/$REPO_NAME"
    echo "2. Add GitHub Secrets for CI/CD:"
    echo "   - AWS_ACCESS_KEY_ID"
    echo "   - AWS_SECRET_ACCESS_KEY"
    echo "3. Update the repository URL in README.md"
    echo "4. Configure branch protection rules if needed"
    echo ""
    echo "🔧 To add secrets, run:"
    echo "gh secret set AWS_ACCESS_KEY_ID --body \"your-access-key\""
    echo "gh secret set AWS_SECRET_ACCESS_KEY --body \"your-secret-key\""
    echo ""
    echo "📖 Your repository is ready for collaboration!"
else
    echo "❌ Failed to create repository. Please check the error above."
    exit 1
fi

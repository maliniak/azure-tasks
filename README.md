Azure Node.js App with Terraform and CI/CD

This project demonstrates a Node.js web application deployed to Azure App Service, connected to a MySQL database via a private endpoint, and managed with Terraform. It includes a GitHub Actions pipeline for automated build, deployment, and testing.

## Prerequisites
- **Azure Account**: Subscription with permissions to create resources.
- **Azure CLI**: For local setup and Service Principal creation.
- **Docker**: For building the app locally.
- **Terraform**: For managing infrastructure.
- **GitHub Repository**: To run github actions with secrets configured in github

## Setup Instructions

### 1. Azure Configuration
1. **Create a Key Vault**
2. **Create an ACR**
3. **Service Principal**
4. **Setup Networking per environment**

## Folder structures

### 1. Deployments
1. **dev folder for creating dev environments**
2. **staging folder for creating staging environments**
3. **production folder for creating production environments**

### 2. Applications
1. **Modules for terraform located in web_app**
2. **NodeJs App located in app_js**

### Instructions
1. Run deployment through workflow dispatch from form generated for dev account

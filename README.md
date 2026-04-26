# 🚀 Automated Multi-Tier Microservices Deployment on AWS

> A complete DevOps pipeline deploying Google's Online Boutique microservices application on AWS EC2 using Docker, Terraform, Ansible, Kubernetes (microk8s), GitHub Actions, and ArgoCD.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Deployment Guide](#deployment-guide)
  - [Step 1: Codebase](#step-1-codebase)
  - [Step 2: Docker](#step-2-docker)
  - [Step 3: Terraform](#step-3-terraform)
  - [Step 4: Ansible](#step-4-ansible)
  - [Step 5: Kubernetes](#step-5-kubernetes)
  - [Step 6: CI/CD](#step-6-cicd)
- [Accessing the Application](#accessing-the-application)
- [CI/CD Pipeline Flow](#cicd-pipeline-flow)
- [Teardown](#teardown)

---

## Project Overview

This project demonstrates a complete end-to-end automated deployment pipeline for a microservices-based e-commerce application. The application (Google's Online Boutique) consists of 11 microservices written in different languages (Go, Python, Node.js, C#, Java) all deployed on a single AWS EC2 instance running a local Kubernetes cluster.

Every layer of the infrastructure is defined as code:
- **Dockerfiles** containerize each microservice
- **Terraform** provisions the AWS infrastructure
- **Ansible** configures the server automatically
- **Kubernetes manifests** define how services run
- **GitHub Actions** builds and pushes images on every commit
- **ArgoCD** automatically deploys changes to the cluster

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Developer                            │
│                    git push → GitHub                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   GitHub Actions (CI)                       │
│  • Builds Docker images for all 11 microservices            │
│  • Pushes images to DockerHub                               │
│  • Updates image tags in k8s manifests                      │
│  • Commits updated manifests back to repo                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      DockerHub                              │
│            22i1297/<service>:<commit-sha>                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  AWS EC2 (t3.medium)                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              ArgoCD (CD)                            │   │
│  │  • Watches GitHub repo for manifest changes         │   │
│  │  • Auto-syncs Kubernetes cluster                    │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│  ┌──────────────────────▼──────────────────────────────┐   │
│  │         Kubernetes Cluster (microk8s)               │   │
│  │                                                     │   │
│  │  frontend      cartservice    productcatalog         │   │
│  │  emailservice  checkout       recommendation         │   │
│  │  currency      payment        shipping               │   │
│  │  adservice     loadgenerator  redis                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              AWS VPC (10.0.0.0/16)                  │   │
│  │         Security Group | Public Subnet              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Tool | Purpose | Version |
|------|---------|---------|
| **Docker** | Containerize microservices | Latest |
| **Terraform** | AWS infrastructure provisioning | >= 1.5.0 |
| **Ansible** | Server configuration management | Latest |
| **microk8s** | Lightweight Kubernetes cluster | 1.28/stable |
| **GitHub Actions** | CI pipeline (build & push images) | v3/v4 |
| **ArgoCD** | CD pipeline (auto-deploy to k8s) | v3.3.8 |
| **AWS EC2** | Cloud server (t3.medium) | Ubuntu 22.04 |

---

## Repository Structure

```
microservices-demo/
├── src/                          # Application source code
│   ├── frontend/                 # Go - Web UI
│   │   └── Dockerfile            # Custom 2-stage build
│   ├── cartservice/              # C# - Shopping cart
│   │   └── src/Dockerfile        # Custom 2-stage build
│   ├── productcatalogservice/    # Go - Product catalog
│   ├── currencyservice/          # Node.js - Currency conversion
│   ├── paymentservice/           # Node.js - Payment processing
│   ├── shippingservice/          # Go - Shipping calculation
│   ├── emailservice/             # Python - Email notifications
│   ├── checkoutservice/          # Go - Order checkout
│   ├── recommendationservice/    # Python - Product recommendations
│   ├── adservice/                # Java - Advertisements
│   └── loadgenerator/            # Python - Traffic simulation
│
├── terraform/                    # AWS Infrastructure as Code
│   ├── main.tf                   # VPC, Subnet, Security Group, EC2
│   ├── variables.tf              # Configurable inputs
│   ├── providers.tf              # AWS provider config
│   ├── outputs.tf                # EC2 IP, SSH command, App URL
│   └── .gitignore                # Excludes sensitive state files
│
├── ansible/                      # Configuration Management
│   ├── inventory.ini             # EC2 server address + SSH config
│   ├── playbook.yml              # Master playbook
│   └── roles/
│       ├── docker/tasks/main.yml # Installs Docker on EC2
│       └── microk8s/tasks/main.yml # Installs & configures Kubernetes
│
├── k8s/                          # Kubernetes Manifests
│   ├── namespace.yml             # Creates 'boutique' namespace
│   ├── frontend/                 # Deployment + NodePort Service
│   ├── cartservice/              # Deployment + ClusterIP Service
│   ├── productcatalogservice/    # Deployment + ClusterIP Service
│   ├── currencyservice/          # Deployment + ClusterIP Service
│   ├── paymentservice/           # Deployment + ClusterIP Service
│   ├── shippingservice/          # Deployment + ClusterIP Service
│   ├── emailservice/             # Deployment + ClusterIP Service
│   ├── checkoutservice/          # Deployment + ClusterIP Service
│   ├── recommendationservice/    # Deployment + ClusterIP Service
│   ├── adservice/                # Deployment + ClusterIP Service
│   ├── loadgenerator/            # Deployment (no service needed)
│   ├── redis/                    # Deployment + ClusterIP Service
│   └── argocd/
│       └── application.yml       # ArgoCD app configuration
│
└── .github/
    └── workflows/
        └── ci.yml                # GitHub Actions CI pipeline
```

---

## Prerequisites

Before deploying, ensure you have:

- **AWS Account** with IAM user and AdministratorAccess
- **GitHub Account** with the repo forked
- **DockerHub Account** for storing images
- **Local machine** with:
  - Git installed
  - WSL (Ubuntu) installed on Windows
  - Terraform installed
  - AWS CLI installed and configured
  - SSH key pair generated (`~/.ssh/id_rsa`)

---

## Deployment Guide

### Step 1: Codebase

Fork the Google Online Boutique repository:

```
https://github.com/GoogleCloudPlatform/microservices-demo
```

Clone your fork locally:

```bash
git clone https://github.com/YOUR_USERNAME/microservices-demo.git
cd microservices-demo
```

---

### Step 2: Docker

Each microservice has a custom **2-stage Dockerfile**:
- **Stage 1 (Builder):** Compiles/builds the application
- **Stage 2 (Runner):** Copies only the final binary into a minimal image

This keeps images small and secure — no compilers or dev tools in production.

The Dockerfiles are located at `src/<service>/Dockerfile` for each of the 11 microservices.

Key languages and base images used:

| Service | Language | Base Image |
|---------|----------|------------|
| frontend | Go | `golang:1.26-alpine` + `alpine:3.21` |
| cartservice | C# | `dotnet/sdk:10.0` + `dotnet/aspnet:10.0` |
| adservice | Java | `gradle:8.6-jdk21` + `eclipse-temurin:21-jre` |
| emailservice | Python | `python:3.12-slim` |
| currencyservice | Node.js | `node:22-alpine` |

---

### Step 3: Terraform

Terraform provisions the entire AWS infrastructure with one command.

**Resources created:**
- VPC (`10.0.0.0/16`)
- Internet Gateway
- Public Subnet (`10.0.1.0/24`)
- Route Table
- Security Group (ports: 22, 80, 443, 8080, 9090, 30000, 30001)
- SSH Key Pair
- EC2 Instance (`t3.medium`, Ubuntu 22.04, 30GB SSD)

**Setup:**

```bash
# Configure AWS credentials
aws configure

# Generate SSH key
ssh-keygen -t rsa -b 4096

# Copy terraform files to WSL home (avoids Windows filesystem permission issues)
cp -r /mnt/f/path/to/terraform ~/terraform
cd ~/terraform

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

After apply, Terraform outputs your server's public IP:

```
ec2_public_ip = "18.232.178.157"
ssh_command   = "ssh -i ~/.ssh/id_rsa ubuntu@18.232.178.157"
```

---

### Step 4: Ansible

Ansible automatically configures the EC2 instance over SSH — no manual installation needed.

**What it installs:**
- Docker Engine + CLI
- microk8s (Kubernetes)
- Addons: DNS, Storage, Ingress, Registry

**Fix Windows line endings before running:**

```bash
sudo apt install dos2unix -y
dos2unix ansible/inventory.ini
```

**Update inventory with your EC2 IP:**

```ini
[microservices]
18.232.178.157

[microservices:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/bilal/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

**Run the playbook:**

```bash
cd ansible/
ansible-playbook -i inventory.ini playbook.yml
```

Expected output:
```
PLAY RECAP
18.232.178.157 : ok=25  changed=12  unreachable=0  failed=0
```

---

### Step 5: Kubernetes

Kubernetes manifests define how each microservice runs in the cluster.

**Each service has:**
- `deployment.yml` — defines the container image, ports, env vars, resource limits
- `service.yml` — exposes the container (ClusterIP for internal, NodePort for external)

**Apply manifests via ArgoCD** (see Step 6) or manually:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@18.232.178.157
microk8s kubectl apply -f https://raw.githubusercontent.com/BilalTariq03/microservices-demo/main/k8s/argocd/application.yml
```

**Verify pods are running:**

```bash
microk8s kubectl get pods -n boutique
```

Expected output:
```
NAME                                   READY   STATUS    RESTARTS   AGE
adservice-xxx                          1/1     Running   0          5m
cartservice-xxx                        1/1     Running   0          5m
checkoutservice-xxx                    1/1     Running   0          5m
currencyservice-xxx                    1/1     Running   0          5m
emailservice-xxx                       1/1     Running   0          5m
frontend-xxx                           1/1     Running   0          5m
paymentservice-xxx                     1/1     Running   0          5m
productcatalogservice-xxx              1/1     Running   0          5m
recommendationservice-xxx              1/1     Running   0          5m
redis-xxx                              1/1     Running   0          5m
shippingservice-xxx                    1/1     Running   0          5m
```

---

### Step 6: CI/CD

#### GitHub Actions (CI)

The workflow at `.github/workflows/ci.yml` triggers on every push to `main`:

1. Checks out the repository
2. Logs into DockerHub using repository secrets
3. Builds Docker images for all 11 services
4. Pushes images to DockerHub with a unique git commit SHA tag
5. Updates image tags in all `k8s/*/deployment.yml` files
6. Commits and pushes the updated manifests

**Add these secrets to GitHub** (Settings → Secrets → Actions):

| Secret | Value |
|--------|-------|
| `DOCKERHUB_USERNAME` | Your DockerHub username |
| `DOCKERHUB_TOKEN` | DockerHub access token |

#### ArgoCD (CD)

ArgoCD monitors the GitHub repository and automatically syncs the Kubernetes cluster when manifests change.

**Install ArgoCD on the server:**

```bash
ssh -i ~/.ssh/id_rsa ubuntu@18.232.178.157

microk8s kubectl create namespace argocd
microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
microk8s kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Get admin password
microk8s kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

**Expose ArgoCD UI:**

```bash
microk8s kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "nodePort": 30001, "targetPort": 8080}]}}'
```

**Apply the ArgoCD application:**

```bash
microk8s kubectl apply -f https://raw.githubusercontent.com/BilalTariq03/microservices-demo/main/k8s/argocd/application.yml
```

---

## Accessing the Application

| Service | URL | Credentials |
|---------|-----|-------------|
| Online Boutique App | `http://18.232.178.157:8080` | None required |
| ArgoCD Dashboard | `https://18.232.178.157:9090` | admin / (see above) |

**To expose the app via port-forward:**

```bash
# Frontend app (port 8080)
microk8s kubectl port-forward -n boutique svc/frontend 8080:80 --address 0.0.0.0 &

# ArgoCD UI (port 9090)
microk8s kubectl port-forward -n argocd svc/argocd-server 9090:443 --address 0.0.0.0 &
```

---

## CI/CD Pipeline Flow

```
Developer pushes code
        │
        ▼
GitHub Actions triggers
        │
        ├── Build Docker image (e.g. frontend)
        ├── Push to DockerHub: 22i1297/frontend:abc1234
        ├── Update k8s/frontend/deployment.yml image tag
        └── Commit & push changes to repo
                │
                ▼
        ArgoCD detects change (polls every 3 mins)
                │
                ▼
        ArgoCD syncs cluster
                │
                ▼
        Kubernetes pulls new image from DockerHub
                │
                ▼
        New pods replace old ones (zero-downtime)
                │
                ▼
        App updated! ✅
```

---

## Teardown

⚠️ **Always destroy AWS resources when done to avoid charges!**

```bash
cd ~/terraform
terraform destroy
```

Type `yes` when prompted. This deletes:
- EC2 instance
- VPC, Subnet, Security Group
- Internet Gateway
- All associated resources

**Estimated cost while running:** ~$1.20/day (t3.medium in us-east-1)

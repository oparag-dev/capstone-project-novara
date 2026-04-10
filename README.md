# Capstone Project Novara

## Overview
Capstone Project Novara is a cloud-native task management application deployed on AWS using Kubernetes. The infrastructure is provisioned with Terraform, the Kubernetes cluster is created with kOps, and the application is deployed with Kubernetes manifests and automated with Ansible.

## Architecture Summary
The solution uses:
- AWS VPC with public utility and private application subnets
- kOps-managed Kubernetes cluster across three Availability Zones
- Frontend and backend containerized with Docker
- PostgreSQL deployed as a StatefulSet with persistent storage
- NGINX Ingress for frontend and API routing
- Ansible for deployment automation

## Tech Stack
- AWS
- Terraform
- kOps
- Kubernetes
- Docker
- PostgreSQL
- Ansible
- GitHub Actions

## Repository Structure
- `terraform/` Infrastructure as code
- `kops/` Cluster configuration
- `k8s/` Kubernetes manifests
- `ansible/` Deployment and operations automation
- `docs/` Architecture, deployment, and troubleshooting documentation

## Quickstart
### 1. Provision infrastructure
Run Terraform from `terraform/root`.

### 2. Create the Kubernetes cluster
Apply the kOps cluster spec and instance group files.

### 3. Deploy the application
Apply the Kubernetes manifests or run the Ansible deploy playbook.

### 4. Validate deployment
Check pods, services, ingress, and persistent volumes.

## Application Endpoints
- Frontend: `https://oparatechstack.com`
- Backend API: `https://api.oparatechstack.com`

## Key Design Decisions
- Multi-AZ cluster for high availability
- Private subnets for application nodes
- Utility subnets for public-facing load balancers
- PostgreSQL deployed with StatefulSet for persistent storage
- Ansible used for deployment orchestration

## Documentation
- `docs/architecture.md`
- `docs/deployment-guide.md`
- `docs/troubleshooting.md`
- `docs/cost-analysis.md`

## Future Improvements
- Sealed Secrets for encrypted secret management
- Monitoring and alerting stack
- Full CI/CD pipeline with GitHub Actions
- Certificate automation with cert-manager




#
apply terraform
export KOPS_STATE_STORE=s3://opara-kops-state
Update your domain registrar nameservers

#
kops create cluster \
  --name cluster.oparatechstack.com \
  --state s3://opara-kops-state \
  --zones eu-west-3a,eu-west-3b,eu-west-3c \
  --control-plane-zones eu-west-3a,eu-west-3b,eu-west-3c \
  --networking calico \
  --topology private \
  --node-count 3 \
  --node-size t3.medium \
  --control-plane-size t3.medium \
  --kubernetes-version 1.28.11 \
  --vpc vpc-06abc217c642040aa \
  --subnets subnet-008cbf2237368bb30,subnet-06e2e9bae85af4f5a,subnet-0f68f545a6333c8bd \
  --utility-subnets subnet-053826f5e98457c4d,subnet-06fb5c198211469c0,subnet-096d791a233e8132b \
  --dry-run -o yaml > kops/cluster.yaml

#
  export KOPS_STATE_STORE=s3://opara-kops-state
echo $KOPS_STATE_STORE
#
kops replace -f kops/cluster.yaml --force
#

kops create secret --name cluster.oparatechstack.com sshpublickey admin -i ~/.ssh/kops-capstone.pub

# create aws resource

kops update cluster cluster.oparatechstack.com --yes --admin

# validate cluster nodes and pods
export KOPS_STATE_STORE=s3://opara-kops-state

kops validate cluster --wait 10m
kubectl get nodes -o wide
kubectl get pods -A

# confirm cluster
kubectl cluster-info
kubectl get nodes
kubectl get pods -A

# apply  namespace.yml

kubectl apply -f k8s/base/namespace.yaml

# apply kubectl

kubectl apply -k k8s/base

# For AWS, the official ingress-nginx docs provide an AWS-specific manifest
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.14.3/deploy/static/provider/aws/deploy.yaml

# 

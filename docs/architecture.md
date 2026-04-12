# Architecture

## Overview

This project implements a production-style DevOps application platform on AWS using Infrastructure as Code, Kubernetes, containerization, and HTTPS ingress. The solution provisions the underlying cloud network with Terraform, creates the Kubernetes cluster with Kops, deploys the application stack on Kubernetes, and exposes the services securely over the internet with TLS.

The application is a task management platform composed of a React frontend, a Flask backend API, and a PostgreSQL database. The frontend is served through NGINX, the backend exposes REST endpoints under `/api`, and the database runs as a stateful workload with persistent storage. The platform is designed to demonstrate core DevOps practices such as IaC, CI/CD readiness, high availability, secure secret handling, observability, and repeatable cleanup.

## High-Level Architecture

The architecture is split into four major layers:

1. **Infrastructure Layer**
   - AWS VPC
   - Public and private subnets across multiple Availability Zones
   - Internet Gateway
   - NAT Gateway
   - Route tables and security groups

2. **Cluster Layer**
   - Kubernetes cluster provisioned with Kops
   - 3 control plane nodes
   - 3 worker nodes
   - Ingress controller
   - Cert-manager for TLS certificate automation

3. **Application Layer**
   - Frontend deployment
   - Backend deployment
   - PostgreSQL StatefulSet
   - Kubernetes Services
   - Ingress resources

4. **Operations Layer**
   - Docker image build and registry workflow
   - GitHub Actions CI/CD
   - Terraform validation workflow
   - Cleanup scripts
   - Cost and operational documentation

## Networking Design

The platform uses a segmented AWS network design to improve isolation, security, and scalability.

- The **VPC** provides a dedicated private network for the project.
- **Public subnets** host internet-facing components such as load balancers and ingress.
- **Private subnets** host internal workloads such as worker nodes and database-connected application workloads.
- Traffic from the internet reaches the application through the **Ingress Load Balancer**.
- The frontend is exposed on HTTPS through the main domain.
- API traffic is routed through a subdomain dedicated to backend access.
- Internal pod-to-pod communication happens inside the Kubernetes network.

This design separates public entry points from internal workloads and follows standard cloud network isolation principles.

## CIDR Allocation Rationale

A dedicated VPC CIDR block was selected to provide enough IP space for:
- multiple public and private subnets
- future scaling of worker nodes
- Kubernetes pod and service networking growth
- clean routing separation across Availability Zones

Subnet ranges were divided to support:
- public ingress-facing infrastructure
- private compute nodes
- future expansion without readdressing

The chosen CIDR strategy favors clarity, future growth, and ease of troubleshooting.

## Kubernetes Cluster Design

The Kubernetes cluster is provisioned with Kops and spans multiple Availability Zones for resilience.

### Control Plane
- 3 control plane nodes
- distributed across 3 Availability Zones
- ensures quorum and control plane availability

### Worker Nodes
- 3 worker nodes minimum
- distributed across 3 Availability Zones
- runs frontend, backend, ingress, and supporting workloads

### Add-ons and Core Components
- Ingress NGINX controller
- Cert-manager
- EBS CSI driver for persistent volumes
- CoreDNS
- Calico networking

This design ensures the cluster can continue functioning even if one Availability Zone experiences issues.

## Application Design

The application follows a three-tier architecture.

### Frontend
- Built with React and TypeScript
- Served through NGINX
- Exposed via HTTPS on the main domain
- Communicates with the backend API through a dedicated API base URL

### Backend
- Built with Flask
- Exposes REST endpoints such as:
  - `/api/health`
  - `/api/auth/login`
  - `/api/auth/signup`
  - `/api/tasks`
- Handles authentication, task management, and database interactions

### Database
- PostgreSQL
- Deployed as a Kubernetes StatefulSet
- Uses persistent storage to survive pod recreation

The frontend and backend are stateless deployments. PostgreSQL is stateful and relies on persistent volumes.

## Database Design

PostgreSQL stores the core application data.

### Main Entities
- **users**
  - id
  - username
  - password_hash
  - created_at

- **tasks**
  - id
  - title
  - description
  - priority
  - status
  - created_at
  - updated_at

### Persistence
- Database storage is backed by a Kubernetes PersistentVolumeClaim
- Data remains available even if the database pod is deleted and recreated
- This supports the persistence requirement in the project checklist

## Security Model

Security is handled across infrastructure, cluster, and application layers.

### Infrastructure Security
- Security groups restrict inbound access
- Public exposure is limited to HTTPS and required service ports
- Internal services remain behind Kubernetes networking and service abstraction

### Cluster Security
- Secrets are stored in Kubernetes Secrets, not hardcoded in application manifests
- Sensitive configuration is externalized
- TLS certificates are managed through cert-manager

### Application Security
- User authentication is handled with JWT
- Passwords are stored as password hashes, not plaintext
- Backend uses authorization headers for protected endpoints

### Repository Security
- Real secrets are excluded from the repository
- `.gitignore` excludes local secret files
- Example configuration files use placeholders only

## High Availability Strategy

High availability is achieved through:

- Multi-AZ Kubernetes control plane
- Multi-AZ worker node placement
- Replicated frontend and backend deployments
- Ingress-based traffic distribution
- Persistent database storage
- Automated TLS certificate management
- Kubernetes self-healing through pod rescheduling and restart policies

While the database runs as a single StatefulSet pod in this project, the rest of the stack is designed to tolerate workload disruption more effectively.

## Design Decisions and Trade-Offs

### Terraform for AWS Infrastructure
**Decision:** Use Terraform for network and infrastructure provisioning  
**Reason:** Repeatable, version-controlled, and aligned with Infrastructure as Code principles

### Kops for Kubernetes Provisioning
**Decision:** Use Kops instead of manually provisioning EC2-based Kubernetes  
**Reason:** Simplifies production-style Kubernetes setup on AWS while exposing important cluster concepts

### React + Flask Stack
**Decision:** Use React frontend and Flask backend  
**Reason:** Clear separation between UI and API, simple to containerize, and good for demonstration purposes

### PostgreSQL StatefulSet
**Decision:** Run PostgreSQL inside the cluster with persistent storage  
**Reason:** Satisfies persistence and stateful workload requirements for the capstone  
**Trade-off:** Simpler than managed RDS, but requires more operational responsibility

### HTTPS with Ingress and Cert-Manager
**Decision:** Use NGINX Ingress and cert-manager for TLS  
**Reason:** Provides secure public access and production-style certificate automation

### Docker-Based Deployment
**Decision:** Package frontend and backend as containers  
**Reason:** Improves portability, consistency, and CI/CD readiness

### Externalized Secrets
**Decision:** Store sensitive values outside source code  
**Reason:** Supports security best practices and cleaner repository hygiene

## Summary

This architecture demonstrates a full DevOps lifecycle across infrastructure provisioning, Kubernetes operations, secure application deployment, persistence, and operational readiness. The final design balances practicality, learning goals, and production-style principles while remaining manageable within a capstone project scope.

##### Architecture Highlights
Multi-AZ Kubernetes cluster for improved availability
Public utility subnets for internet-facing load balancers
Private subnets for internal application workloads
Frontend exposed through HTTPS at the main domain
Backend API exposed through a dedicated subdomain
PostgreSQL backed by persistent storage to survive pod recreation
Secrets externalized from application source code
Application Endpoints
Frontend: https://oparatechstack.com
Backend API: https://api.oparatechstack.com
Health Check: https://api.oparatechstack.com/api/health
Prerequisites

Before deployment, make sure the following are installed and configured:

AWS CLI
Terraform
kubectl
kops
Docker
Git

You also need:

AWS credentials
access to your domain registrar and DNS settings
a Docker Hub account
access to the S3 bucket used for kOps state storage
Quickstart
1. Provision infrastructure

Run Terraform from terraform/root.

cd terraform/root
terraform init -reconfigure
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
2. Configure kOps state store
export KOPS_STATE_STORE=s3://opara-kops-state
echo $KOPS_STATE_STORE
3. Update domain registrar nameservers

Point your domain registrar to the correct DNS configuration before validating public cluster access and ingress resolution.

4. Create the Kubernetes cluster

Generate the cluster manifest:

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

Apply the cluster spec:

kops replace -f kops/cluster.yaml --force

Create the SSH public key secret:

kops create secret --name cluster.oparatechstack.com sshpublickey admin -i ~/.ssh/kops-capstone.pub

Create AWS resources for the cluster:

kops update cluster cluster.oparatechstack.com --yes --admin
5. Validate the cluster
export KOPS_STATE_STORE=s3://opara-kops-state
kops validate cluster --wait 10m
kubectl get nodes -o wide
kubectl get pods -A
kubectl cluster-info

Expected result:

cluster validates successfully
all nodes are Ready
core system pods are running
6. Apply the application namespace
kubectl apply -f k8s/base/namespace.yaml
7. Deploy the application

Apply the base manifests:

kubectl apply -k k8s/base
8. Install ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.14.3/deploy/static/provider/aws/deploy.yaml
9. Verify deployment
kubectl get pods -n taskapp
kubectl get svc -n taskapp
kubectl get ingress -A
kubectl get pvc -n taskapp
Key Design Decisions
Multi-AZ cluster for high availability
Private subnets for application nodes
Utility subnets for public-facing load balancers
PostgreSQL deployed with StatefulSet for persistent storage
Ansible used for deployment orchestration
HTTPS ingress for secure public access
Kubernetes Secrets for externalized sensitive values
Persistence Validation

To confirm database persistence:

create or confirm test data
delete the Postgres pod
wait for the pod to be recreated
confirm the data still exists

Example:

kubectl delete pod postgres-0 -n taskapp
kubectl get pods -n taskapp -w
Security Notes
No real passwords or tokens should be committed to the repository
Sensitive values should be stored in Kubernetes Secrets or externalized configuration
Local secret files should be excluded through .gitignore
Example files should contain placeholders only
CI/CD

The project supports GitHub Actions for:

Terraform validation
Docker image build and push
Kubernetes deployment updates

Recommended GitHub secrets:

DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
KUBECONFIG_BASE64
Documentation

Additional project documentation is stored under docs/:

docs/architecture.md
docs/deployment-guide.md
docs/troubleshooting.md
docs/cost-analysis.md
Submission Checklist

Before final submission, confirm:

terraform plan runs without errors
kops validate cluster reports the cluster is ready
kubectl get nodes shows 3+ control plane and 3+ worker nodes, all Ready
application is accessible via HTTPS without certificate warnings
database data persists after database pod recreation
no plaintext secrets are committed to the repository
cost estimate is documented
cleanup procedure is documented
repository is organized and documented
Submission Artifacts

Prepare these for submission:

Git repository URL
Live domain URL
Demo video URL
Future Improvements
Sealed Secrets for encrypted secret management
Monitoring and alerting stack
Full CI/CD pipeline with GitHub Actions
Cert-manager certificate automation
Stronger frontend runtime configuration handling
Managed database option for reduced operational overhead

Two important cleanups before submission:
- remove `terraform.tfstate` from the repo
- update the demo credentials shown in the UI so they match the actual login flow

If you want, I will turn this into a sharper version with a short “Results” section 
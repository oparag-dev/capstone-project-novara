# Capstone Project Novara

## Overview

Capstone Project Novara is a cloud-native task management platform deployed on AWS using Kubernetes. The infrastructure is provisioned with Terraform, the Kubernetes cluster is created with kOps, and the application is deployed with Kubernetes manifests. The project demonstrates Infrastructure as Code, containerized application delivery, HTTPS ingress, persistent storage, and operational troubleshooting in a production-style environment.

The platform includes:
- a React frontend
- a Flask backend API
- a PostgreSQL database
- Kubernetes-based deployment and service exposure
- supporting documentation for architecture, deployment, troubleshooting, and cost analysis

## Architecture Summary

The solution uses:
- AWS VPC with public utility subnets and private application subnets
- kOps-managed Kubernetes cluster across three Availability Zones
- Frontend and backend containerized with Docker
- PostgreSQL deployed as a StatefulSet with persistent storage
- NGINX Ingress for frontend and API routing
- Ansible for deployment automation
- GitHub Actions for CI/CD readiness

## Tech Stack

- AWS
- Terraform
- kOps
- Kubernetes
- Docker
- PostgreSQL
- Flask
- React
- NGINX Ingress
- Ansible
- GitHub Actions

## Repository Structure

```text
.github/         GitHub Actions workflows
ansible/         Deployment and operations automation
app/             Frontend and backend application source
docs/            Architecture, deployment, troubleshooting, and cost analysis
k8s/             Kubernetes manifests
kops/            Cluster configuration
scripts/         Utility and cleanup scripts
terraform/       Infrastructure as code
README.md        Project overview and usage


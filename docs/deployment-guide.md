# Deployment Guide

## Overview

This guide explains how to provision the infrastructure, create the Kubernetes cluster, deploy the application, expose it through HTTPS, and validate that the platform is working correctly.

The project uses:
- Terraform for AWS infrastructure
- Kops for Kubernetes cluster provisioning
- Docker for container images
- Kubernetes manifests for application deployment
- Ingress NGINX and cert-manager for HTTPS

## Prerequisites

Before starting, make sure the following tools are installed and working:

- AWS CLI
- Terraform
- kubectl
- kops
- Docker
- Git

You also need:
- an AWS account
- a configured domain and DNS access
- Docker Hub credentials
- valid AWS credentials on your machine

Check tool versions:

```bash
aws --version
terraform version
kubectl version --client
kops version
docker --version
git --version
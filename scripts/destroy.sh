#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KOPS_STATE_STORE="s3://opara-kops-state"
CLUSTER_NAME="cluster.oparatechstack.com"
AWS_REGION="eu-west-3"

export KOPS_STATE_STORE
export AWS_REGION

read -rp "This will destroy the app, cluster, and infrastructure. Continue? [y/N]: " confirm
[[ "${confirm:-N}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

echo "Deleting Kubernetes app resources..."
kubectl delete -k "$PROJECT_ROOT/k8s/overlays/prod" --ignore-not-found=true || true
kubectl delete -f "$PROJECT_ROOT/k8s/base/ingress.yaml" --ignore-not-found=true || true
kubectl delete -f "$PROJECT_ROOT/k8s/base/cluster-issuer.yaml" --ignore-not-found=true || true
kubectl delete namespace taskapp --ignore-not-found=true || true

echo "Deleting kops cluster..."
kops delete cluster --name "$CLUSTER_NAME" --state "$KOPS_STATE_STORE" --yes

echo "Waiting for ELB cleanup..."
sleep 60

echo "Destroying Terraform infrastructure..."
cd "$PROJECT_ROOT/terraform/root"
terraform destroy -auto-approve

echo "Cleanup complete."
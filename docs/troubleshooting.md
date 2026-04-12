# Troubleshooting

## Terraform issues
## kOps issues
## Kubernetes deployment issues
## Postgres issues
## Backend issues
## Frontend issues
## Ingress and DNS issues
## Ansible issues



# outdated kubernetes 

sed -i 's/kubernetesVersion: .*/kubernetesVersion: 1.34.6/' kops/cluster.yaml
grep kubernetesVersion -n kops/cluster.yaml
kops replace -f kops/cluster.yaml --force
kops update cluster cluster.oparatechstack.com --yes --admin

# stateful DB error
##update db-statefulset.yaml mix error then


kubectl delete statefulset postgres -n taskapp
kubectl delete pvc postgres-storage-postgres-0 -n taskapp
kubectl apply -f k8s/base/db-service.yaml
kubectl apply -f k8s/base/db-statefulset.yaml
kubectl get pods -n taskapp -w

#
docker build --no-cache -t oparag/taskapp-backend:latest ./app/taskapp_backend
docker push oparag/taskapp-backend:latest

##
grep -R "DATABASE_URL" -n app/taskapp_backend
grep -R "DB_HOST" -n app/taskapp_backend
grep -R "localhost" -n app/taskapp_backend


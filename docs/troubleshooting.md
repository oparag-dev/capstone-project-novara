# Postgres issues
StatefulSet and credential mismatch

Problem
The backend could not authenticate to Postgres.

Symptoms

/api/health returned unhealthy
password authentication failed for user "taskuser"

Cause

backend secret and database state were out of sync
the StatefulSet volume kept older DB initialization state

Fix

recreate the secret with the intended values
recreate the PVC when safe
redeploy Postgres

Commands used

kubectl delete secret postgres-secret -n taskapp

kubectl create secret generic postgres-secret -n taskapp \
  --from-literal=POSTGRES_DB=taskapp \
  --from-literal=POSTGRES_USER=taskuser \
  --from-literal=POSTGRES_PASSWORD='TaskappDb2026Secure!'

# Broken DB state after StatefulSet changes

Problem
Database pod state became inconsistent after changes to the StatefulSet setup.

Fix

kubectl delete statefulset postgres -n taskapp
kubectl delete pvc postgres-storage-postgres-0 -n taskapp
kubectl apply -f k8s/base/db-service.yaml
kubectl apply -f k8s/base/db-statefulset.yaml
kubectl get pods -n taskapp -w

Lesson

be careful when modifying persistent stateful workloads
deleting the PVC removes data and should only be done when safe

# Missing database tables

Problem
Login returned 500 because the database schema did not exist.

Symptoms

relation "users" does not exist
Did not find any relations

Cause

DB was reset
schema was not recreated
backend expected tables to exist

Fix

create tables from the application context
then seed or create a user again

Result

signup began to work
login returned 200 afterward
Backend issues

# Wrong environment variable naming

Problem
Backend connection setup was inconsistent because code and Kubernetes env names did not match cleanly during debugging.

Checks used

grep -R "DATABASE_URL" -n app/taskapp_backend
grep -R "DB_HOST" -n app/taskapp_backend
grep -R "localhost" -n app/taskapp_backend

Lesson

keep backend config variable names consistent across:
source code
Docker image
Kubernetes manifests
secrets

# Backend 500 during login

Problem
Login returned 500 Internal Server Error.

Root causes encountered during debugging

missing DB schema
missing users table
no seeded or created user
inconsistent database state after reset

Useful checks

kubectl logs -n taskapp deployment/backend --tail=200
curl -i -X POST https://api.oparatechstack.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'

# Backend image stale after code changes

Problem
Code changes did not appear in the cluster.

Fix

docker build --no-cache -t oparag/taskapp-backend:latest ./app/taskapp_backend
docker push oparag/taskapp-backend:latest
Frontend issues
Broken API base URL in deployed bundle

Problem
The deployed frontend bundle still used relative auth paths like /api/auth/login.

Symptoms

browser posted to https://oparatechstack.com/api/auth/login
login returned 405 Method Not Allowed
curl to https://api.oparatechstack.com/api/auth/login still worked

Root cause

Docker-built frontend did not get VITE_API_URL during build
fallback '/api' stayed in the live bundle

Fix

update AuthContext.tsx to use the absolute API base for login and signup
rebuild and redeploy frontend
verify the live bundle no longer contains /api/auth/login

Verification

kubectl exec -it -n taskapp deployment/frontend -- sh -c "grep -R '/api/auth/login' -n /usr/share/nginx/html/assets || true"
kubectl exec -it -n taskapp deployment/frontend -- sh -c "grep -R 'https://api.oparatechstack.com/api/auth/login' -n /usr/share/nginx/html/assets || true"

# Frontend JSON parse errors

Problem
The browser showed:

Unexpected token '<'
HTML error pages inside the UI

Cause

frontend expected JSON for all error responses
backend sometimes returned HTML error pages

Fix

improve error handling in AuthContext.tsx
inspect content-type
parse JSON only when appropriate
fall back to text for HTML error responses

# Missing config.js

Problem
Browser tried to load /config.js and got 404.

Cause

index.html still referenced a config file that was not present in the deployed container

Fix

remove the unused reference from index.html
or recreate the file if runtime config is intentionally used

Lesson

do not keep unused runtime config references in production HTML

# Browser cache confusion

Problem
Frontend appeared unchanged even after rebuild and redeploy.

Fix

use new image tags instead of reusing latest
disable cache in DevTools
hard reload browser
confirm live pod bundle contents directly
Ingress and DNS issues

# Main domain vs API subdomain confusion

Problem
Some tests were done against the wrong host.

Examples

https://api.oparatechstack.com/ returning 404
https://api.oparatechstack.com/api/health returning healthy
https://api.oparatechstack.com/api/auth/login in the browser address bar returning 405

Explanation

root / may not exist on the API service
/api/health is a GET endpoint
/api/auth/login requires POST, so opening it in the browser sends GET and correctly returns 405

# Verifying browser request path

Problem
The real issue was not clear until the browser Network tab was inspected.

Key finding

browser fetch request was going to:
https://oparatechstack.com/api/auth/login
instead of:
https://api.oparatechstack.com/api/auth/login

Lesson

always confirm the exact Request URL and Request Method in DevTools
Ansible issues

# Inventory path and role resolution issues

Problem
Ansible syntax check failed because the inventory path and role path were wrong.

Symptoms

inventory parsing warnings
role not found errors

Fix

verify inventory location
verify role path
confirm file layout under the ansible directory

Checks

ansible-playbook -i ansible/inventory/hosts.ini playbooks/harden-nodes.yml --syntax-check
ansible-inventory -i ansible/inventory/hosts.ini --list
General troubleshooting lessons
1. Confirm the failing layer first

Do not change multiple layers at once. Identify whether the issue is in:

Terraform
cluster
database
backend
frontend
ingress
browser
2. Verify live state, not only local source code

A local file may be fixed while the live pod still serves older code.

3. Use direct checks

Examples:

curl for API
kubectl logs for pods
browser Network tab for frontend
psql for database validation
4. Be careful with stateful resources

Resetting Postgres PVCs is powerful but destructive.

5. Prefer exact evidence over assumptions

The breakthrough in this project came from verifying:

backend health
login curl response
browser request URL
deployed frontend bundle content
Final root causes resolved during the project
Unsupported Kubernetes version in kOps cluster manifest
Postgres secret and persistent state mismatch
Missing database schema after database reset
Frontend deployed bundle using wrong relative API auth path
Missing runtime config reference cleanup
Browser cache and stale image confusion during redeployments

Two more cleanups before submission:
- remove `terraform.tfstate` from the repo and add it to `.gitignore`
- replace outdated demo credentials in the UI so reviewers are not confused by placeholder accounts

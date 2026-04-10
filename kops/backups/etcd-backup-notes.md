# etcd Backup Notes

Cluster name: cluster.oparatechstack.com
State store: s3://opara-kops-state
Region: eu-west-3
Control plane AZs:
- eu-west-3a
- eu-west-3b
- eu-west-3c

etcd backup retention:
- main: 90 days
- events: 90 days

Important commands:
- export KOPS_STATE_STORE=s3://opara-kops-state
- kops validate cluster --wait 10m
- kops get cluster
- kops get ig
- kops update cluster cluster.oparatechstack.com --yes --admin

Recovery notes:
- keep Route 53 zone active
- do not delete the kops state store bucket
- do not delete control plane EBS volumes unless rebuilding intentionally
# Cost estimate
Assumptions

This estimate is based on the current deployed architecture in AWS Paris, eu-west-3:

3 control plane nodes
3 worker nodes
instance type: t3.medium
1 PostgreSQL persistent volume, 10 GiB
1 ingress load balancer
1 NAT Gateway
1 Route 53 public hosted zone
cert-manager for TLS
data transfer not fixed, so listed separately

AWS prices On-Demand EC2 by usage, gp3 EBS by GB-month, NAT Gateway by hour plus per-GB processing, and Route 53 public hosted zones at $0.50 per zone-month for the first 25 zones. The AWS Pricing Calculator should be used to validate the final submission estimate.

Monthly estimate
1. EC2 nodes

Using 6 t3.medium instances:

6 × $0.0416 × 730 hours = $182.21/month
2. EBS volumes

For the PostgreSQL PVC only, using gp3 at $0.08/GB-month:

10 GiB × $0.08 = $0.80/month

Note: this does not include the EC2 root EBS volumes. Those should be counted separately based on the actual disk size attached to each node. AWS bills gp3 storage by provisioned GB-month.

3. NAT Gateway

AWS charges NAT Gateway by the hour and by data processed. The hourly charge shown is $0.045/hour:

0.045 × 730 hours = $32.85/month base cost

AWS also charges $0.045/GB for data processed through the NAT Gateway, so the final NAT cost increases with outbound traffic.

4. Load balancer

Using one ingress load balancer, with AWS ELB pricing example rate of about $0.0455/hour before LCU charges:

0.0455 × 730 hours = $33.21/month base cost

This estimate excludes LCU or request-driven charges.

5. Route 53 hosted DNS

For one public hosted zone in Route 53:

$0.50/month for the hosted zone

Route 53 also charges for DNS queries, starting at $0.40 per million standard queries, but this is usually small at low traffic volume.

6. Data transfer

Variable cost, not included in the fixed subtotal:

NAT data processing: $0.045/GB
internet egress: depends on actual traffic pattern and AWS billing category
7. cert-manager

cert-manager has no separate AWS license cost. Its only cost impact is the compute already included in the cluster nodes.

Expected monthly total
Fixed monthly subtotal

This subtotal includes:

6 EC2 nodes
PostgreSQL PVC
1 NAT Gateway
1 ingress load balancer
1 Route 53 hosted zone

Estimated fixed monthly cost:

EC2: $182.21
PostgreSQL PVC: $0.80
NAT Gateway: $32.85
Load balancer: $33.21
Route 53 hosted zone: $0.50

Estimated fixed subtotal: ~$249.57/month

Additional variable costs

These are not included in the subtotal:

NAT data processing
internet egress
Route 53 query charges
EC2 root EBS volumes
any extra load balancer created by kops for the Kubernetes API
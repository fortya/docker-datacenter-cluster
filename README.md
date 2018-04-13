# Docker Datacenter Cluster

This Docker Enterprise cluster is comprised of 3 kind of nodes:

- Manager: the "brain" of the cluster.
- Worker: doers.
- DTR: Registry nodes take care of hosting docker images.

The cluster will provision fully functional Docker Enterprise environment that follows AWS Well Architectured Framework principles.

Characteristics:
- All infrastructure is in TF and requires 0 manual intervention.
- Stack runs on its own VPC.
- All nodes run in private subnets and are only exposed through Load Balancers.
- Port management has been thoroughly thought to prevent any backdoor or open ports.
- Only ALB and NLB are used as load balancers, instead of the classic previous generation ELBs. This also significantly improves performance for inter-node communication.
- Each type of node is part of an AutoScalingGroup with default scaling policies.
- Each launched master or dtr node is smart enough to decide whether it needs to install the cluster/dtr or just join an existing cluster.
- Only HTTPS traffic is supported for UCP

## Installation

1. It is recommended to launch the cluster with only 1 master node at first.
1. Login to UCP (default to `ucp.yourselecteddomain.com`) and configure as needed.
1. Once all settings have been carefully selected proceed to update ASGs for `workers` and `dtr` through Terraform so they can join the cluster.
1. Login to DTR and configure as needed (default to `dtr.yourselecteddomain.com`).

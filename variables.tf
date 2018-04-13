variable "aws_region" {
  type    = "string"
  default = "us-west-2"
}

variable "service" {
  type    = "string"
  default = "ddc"
}

variable "service_instance" {
  type = "string"
}

variable "global_tags" {
  type = "map"

  default = {
    Provisioner = "Terraform"
  }
}

variable "service_ip_whitelist" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

variable "ucp_username" {
  type = "string"
}

variable "ucp_password" {
  type = "string"
}

variable "hosted_zone_id" {
  type = "string"
}

variable domain {
  type        = "string"
  description = "Domain where UCP and DTR are going to run (ie. wslogistics.io). TF will attempt to find existing ACM certs."
}

variable "ucp_subdomain" {
  type        = "string"
  description = "Subdomain for UCP (ie. ucp). It will be used along with 'domain' variable like: ucp.wslogistics.io"
  default     = "ucp"
}

variable "dtr_subdomain" {
  type        = "string"
  description = "Subdomain for DTR (ie. dtr). It will be used along with 'domain' variable like: dtr.wslogistics.io"
  default     = "dtr"
}

variable "dtr_http_port" {
  type        = "string"
  description = "HTTP Port where DTR is gonna run internally (defaults to 80). DTR is finally exposed through LB on port 80 anyway."
  default     = 80
}

variable "dtr_https_port" {
  type        = "string"
  description = "HTTPS Port where DTR is gonna run internally (defaults to 443). DTR is finally exposed through LB on port 443 anyway."
  default     = 443
}

variable "ucp_https_port" {
  type        = "string"
  description = "HTTPS Port where UCP is gonna run internally (defaults to 443). UCP is finally exposed through LB on port 443 anyway."
  default     = 4443
}

variable "docker_ee_url" {
  type = "string"
}

variable "docker_ee_version" {
  type    = "string"
  default = "stable-17.06"
}

variable "docker_ucp_version" {
  type    = "string"
  default = "2.2.5"
}

# VPC
variable "vpc_cidr" {
  description = "VPC CIDR to use. Defaults to 10.0.0.0/16."
  type        = "string"
  default     = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  description = "Private subnets cidrs to create."
  type        = "list"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  description = "Public subnets cidrs to create."
  type        = "list"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "AWS AZs to launch servers."
  type        = "list"
  default     = ["us-west-2a", "us-west-2b"]
}

# EC2

variable "ssh_key_name" {
  type = "string"
}

variable "manager_node_min_count" {
  type    = "string"
  default = 0
}

variable "manager_node_max_count" {
  type    = "string"
  default = 0
}

variable "manager_node_desired_count" {
  type    = "string"
  default = 0
}

variable "manager_node_instance_type" {
  type    = "string"
  default = "t2.medium"
}

variable "dtr_node_min_count" {
  type    = "string"
  default = 0
}

variable "dtr_node_max_count" {
  type    = "string"
  default = 0
}

variable "dtr_node_desired_count" {
  type        = "string"
  description = "It is recommended to have 3, 5, or 7 DTR replicas for HA"
  default     = 0
}

variable "dtr_node_instance_type" {
  type    = "string"
  default = "t2.medium"
}

variable "worker_node_min_count" {
  type    = "string"
  default = 0
}

variable "worker_node_max_count" {
  type    = "string"
  default = 0
}

variable "worker_node_desired_count" {
  type    = "string"
  default = 0
}

variable "worker_node_instance_type" {
  type    = "string"
  default = "t2.small"
}

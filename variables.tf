variable "manager_node_min_count" {
  type = "string"
  default = 0
}
variable "manager_node_max_count" {
  type = "string"
  default = 0
}
variable "manager_node_desired_count" {
  type = "string"
  default = 0
}
variable "dtr_node_min_count" {
  type = "string"
  default = 0
}
variable "dtr_node_max_count" {
  type = "string"
  default = 0
}
variable "dtr_node_desired_count" {
  type = "string"
  default = 0
}

variable "worker_node_min_count" {
  type = "string"
  default = 0
}
variable "worker_node_max_count" {
  type = "string"
  default = 0
}
variable "worker_node_desired_count" {
  type = "string"
  default = 0
}


variable "aws_region" {
  type    = "string"
  default = "us-west-2"
}

variable "ssh_key_name" {
  type = "string"
}

variable "service" {
  type    = "string"
  default = "ddc"
}

variable "service_owner" {
  type        = "string"
  description = "Who is responsible for this stack? (email address)"
}

variable "service_stage" {
  type    = "string"
  default = "dev"
}
variable "service_instance" {
  type = "string"
}

variable "service_ip_whitelist" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

variable "manager-ssl-certificate" {
  type = "string"
}

variable "ucp_token_manager" {
  type = "string"
  default = ""
}

variable "ucp_token_worker" {
  type = "string"
  default = ""
}

variable "ucp_username" {
  type = "string"
}

variable "ucp_password" {
  type = "string"
}

variable "ucp_endpoint" {
  type = "string"
}
variable "dtr_endpoint" {
  type = "string"
}

variable "dtr_http_port" {
  type    = "string"
  default = 81
}

variable "dtr_https_port" {
  type    = "string"
  default = 4443
}
variable "dtr_replica_id" {
  type = "string"
  default = ""

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
variable "aws_profile" {
  type    = "string"
  default = "default"
}

variable "hosted_zone_id" {
  type = "string"
}

variable "vpc_cidr" {
  description = "VPC CIDR to use. Defaults to 10.0.0.0/16"
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
  description = "AWS region to launch servers; if not set the available zones will be detected automatically"
  type        = "list"
  default     = ["us-west-2a", "us-west-2b"]
}

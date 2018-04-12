module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.service}-${var.service_instance}-vpc"
  cidr = "${var.vpc_cidr}"

  azs = ["${var.availability_zones}"]

  private_subnets = ["${var.vpc_private_subnets}"]
  public_subnets  = ["${var.vpc_public_subnets}"]

  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  private_subnet_tags = {
    Layer = "private"
  }

  public_subnet_tags = {
    Layer = "public"
  }

  tags = "${merge(var.global_tags, map("Name","${var.service}-${var.service_instance}-vpc"))}"
}

resource "aws_security_group" "admin" {
  name        = "${var.service}-${var.service_instance}-admin-sg"
  description = "SSH Access for admins"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["${var.service_ip_whitelist}"]
  }
}

resource "aws_security_group" "swarm_node" {
  name        = "${var.service}-${var.service_instance}-swarm-node-sg"
  description = "Allows docker swarm communication across nodes"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 2375
    to_port     = 2377
    protocol    = "UDP"
    description = "Port for communication between swarm nodes"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2375
    to_port     = 2377
    protocol    = "TCP"
    description = "Port for communication between swarm nodes"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "TCP"
    description = "Port for overlay networking"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "UDP"
    description = "Port for overlay networking"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12376
    to_port     = 12376
    protocol    = "TCP"
    description = "Port for a TLS proxy that provides access to UCP, Docker Engine, and Docker Swarm"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12376
    to_port     = 12376
    protocol    = "UDP"
    description = "Port for a TLS proxy that provides access to UCP, Docker Engine, and Docker Swarm"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12379
    to_port     = 12387
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12379
    to_port     = 12387
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "TCP"
    description = "Port for gossip-based clustering"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "UDP"
    description = "Port for gossip-based clustering"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "manager_node" {
  name        = "${var.service}-${var.service_instance}-manager-sg"
  description = "Allows HTTP(s) inbound for manager nodes"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description = "Allows inboud HTTPS traffic for manager nodes"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = "Allows inboud HTTP traffic for manager nodes"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dtr_node" {
  name        = "${var.service}-${var.service_instance}-dtr-sg"
  description = "Allows HTTP(s) inbound for dtr nodes"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "${var.dtr_https_port}"
    to_port     = "${var.dtr_https_port}"
    protocol    = "TCP"
    description = "Allows inboud HTTPS traffic for dtr nodes"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "${var.dtr_http_port}"
    to_port     = "${var.dtr_http_port}"
    protocol    = "TCP"
    description = "Allows inboud HTTP traffic for dtr nodes"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "node_dtr_lb" {
  name        = "${var.service}-${var.service_instance}-dtr-elb-sg"
  description = "manager elb"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = "443"
    to_port     = "443"
    description = "DTR ELB HTTPS traffic"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "TCP"
    description = "DTR ELB HTTP traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "node_ucp_lb" {
  name        = "${var.service}-${var.service_instance}-manager-elb-sg"
  description = "manager elb"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = "Port for the UCP web UI and API"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description = "Port for the UCP web UI and API"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

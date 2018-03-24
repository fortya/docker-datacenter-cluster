module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.service}-${var.service_instance}"
  cidr = "${var.vpc_cidr}"

  azs = ["${var.availability_zones}"]

  private_subnets  = ["${var.vpc_private_subnets}"]
  public_subnets   = ["${var.vpc_public_subnets}"]
  database_subnets = ["${var.vpc_database_subnets}"]

  enable_nat_gateway           = true
  enable_vpn_gateway           = false
  enable_dns_hostnames         = true
  create_database_subnet_group = true

  private_subnet_tags = {
    Layer = "private"
  }

  public_subnet_tags = {
    Layer = "public"
  }

  tags = {
    Owner       = "${var.service_owner}"
    Provisioner = "Terraform"
    Stage       = "${var.service_stage}"
    Service     = "${var.service}"
    Instance    = "${var.service_instance}"
  }
}

resource "aws_security_group" "node-manager" {
  name        = "${var.service}-${var.service_instance}-master-sg"
  description = "master nodes"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 2375
    to_port     = 2377
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2375
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12376
    to_port     = 12376
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12376
    to_port     = 12376
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12379
    to_port     = 12387
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12379
    to_port     = 12387
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.service_ip_whitelist}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "node-worker" {
  name        = "${var.service}-${var.service_instance}-worker-sg"
  description = "Allow all HTTP(s) inbound"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 2375
    to_port     = 2377
    protocol    = "tcp"
    description = "Port for communication between swarm nodes"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2375
    to_port     = 2377
    protocol    = "udp"
    description = "Port for communication between swarm nodes"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    description = "Port for overlay networking"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    description = "Port for overlay networking"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12376
    to_port     = 12376
    protocol    = "tcp"
    description = "Port for a TLS proxy that provides access to UCP, Docker Engine, and Docker Swarm"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 12376
    to_port     = 12376
    protocol    = "udp"
    description = "Port for a TLS proxy that provides access to UCP, Docker Engine, and Docker Swarm"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    description = "Port for gossip-based clustering"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
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

resource "aws_security_group" "node-dtr-elb" {
  name        = "${var.service}-${var.service_instance}-dtr-elb-sg"
  description = "manager elb"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 4443
    to_port     = 4443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "node-ucp-elb" {
  name        = "${var.service}-${var.service_instance}-master-elb-sg"
  description = "manager elb"
  vpc_id      = "${module.vpc.vpc_id}"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "Port for the UCP web UI and API"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Port for the UCP web UI and API"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

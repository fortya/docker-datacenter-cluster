

module "node-master-elb" {
  source = "terraform-aws-modules/elb/aws"

  name = "${var.service}-${var.service_instance}-master-elb"

  subnets         = ["${module.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.node-ucp-elb.id}"]
  internal        = false

  listener = [
    {
      instance_port      = "443"
      instance_protocol  = "HTTPS"
      lb_port            = "443"
      lb_protocol        = "HTTPS"
      ssl_certificate_id = "${var.manager-ssl-certificate}"
    },
    {
      instance_port      = "80"
      instance_protocol  = "HTTP"
      lb_port            = "80"
      lb_protocol        = "HTTP"
    },
    {
      instance_port      = "2377"
      instance_protocol  = "TCP"
      lb_port            = "2377"
      lb_protocol        = "TCP"
    },
    {
      instance_port      = "7946"
      instance_protocol  = "TCP"
      lb_port            = "7946"
      lb_protocol        = "TCP"
    },
    {
      instance_port      = "4789"
      instance_protocol  = "TCP"
      lb_port            = "4789"
      lb_protocol        = "TCP"
    }
  ]

  health_check = [
    {
      target              = "HTTPS:443/_ping"
      interval            = 10
      healthy_threshold   = 2
      unhealthy_threshold = 4
      timeout             = 5
    },
  ]

  tags = {
    Owner       = "${var.service_owner}"
    Provisioner = "Terraform"
    Stage       = "${var.service_stage}"
    Service     = "${var.service}"
    Instance    = "${var.service_instance}"
  }
}

module "node-manager-elb" {
  source = "terraform-aws-modules/elb/aws"

  name = "${var.service}-${var.service_instance}-manager-elb"

  subnets         = ["${module.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.node-ucp-elb.id}"]
  internal        = false

  listener = [
    {
      instance_port      = "443"
      instance_protocol  = "HTTPS"
      lb_port            = "443"
      lb_protocol        = "HTTPS"
      ssl_certificate_id = "${var.manager-ssl-certificate}"
    },
    {
      instance_port      = "80"
      instance_protocol  = "HTTP"
      lb_port            = "80"
      lb_protocol        = "HTTP"
    },
    {
      instance_port      = "2377"
      instance_protocol  = "TCP"
      lb_port            = "2377"
      lb_protocol        = "TCP"
    },
    {
      instance_port      = "7946"
      instance_protocol  = "TCP"
      lb_port            = "7946"
      lb_protocol        = "TCP"
    },
    {
      instance_port      = "4789"
      instance_protocol  = "TCP"
      lb_port            = "4789"
      lb_protocol        = "TCP"
    }
  ]

  health_check = [
    {
      target              = "HTTPS:443/_ping"
      interval            = 10
      healthy_threshold   = 2
      unhealthy_threshold = 4
      timeout             = 5
    },
  ]

  tags = {
    Owner       = "${var.service_owner}"
    Provisioner = "Terraform"
    Stage       = "${var.service_stage}"
    Service     = "${var.service}"
    Instance    = "${var.service_instance}"
  }
}

module "node-dtr-elb" {
  source = "terraform-aws-modules/elb/aws"

  name = "${var.service}-${var.service_instance}-dtr-elb"

  subnets         = ["${module.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.node-dtr-elb.id}"]
  internal        = false

  listener = [
    {
      instance_port      = "4443"
      instance_protocol  = "HTTPS"
      lb_port            = "443"
      lb_protocol        = "HTTPS"
      ssl_certificate_id = "${var.manager-ssl-certificate}"
    },
    {
      instance_port      = "81"
      instance_protocol  = "HTTP"
      lb_port            = "80"
      lb_protocol        = "HTTP"
    },
    {
      instance_port      = "2377"
      instance_protocol  = "TCP"
      lb_port            = "2377"
      lb_protocol        = "TCP"
    },
    {
      instance_port      = "7946"
      instance_protocol  = "TCP"
      lb_port            = "7946"
      lb_protocol        = "TCP"
    },
    {
      instance_port      = "4789"
      instance_protocol  = "TCP"
      lb_port            = "4789"
      lb_protocol        = "TCP"
    }
  ]

  health_check = [
    {
      target              = "HTTPS:4443/_ping"
      interval            = 10
      healthy_threshold   = 2
      unhealthy_threshold = 4
      timeout             = 5
    },
  ]

  tags = {
    Owner       = "${var.service_owner}"
    Provisioner = "Terraform"
    Stage       = "${var.service_stage}"
    Service     = "${var.service}"
    Instance    = "${var.service_instance}"
  }
}

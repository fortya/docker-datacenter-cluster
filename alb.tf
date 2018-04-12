module "node-manager-alb" {
  source              = "terraform-aws-modules/alb/aws"
  load_balancer_name  = "${var.service}-${var.service_instance}-manager-alb"
  vpc_id              = "${module.vpc.vpc_id}"
  subnets             = ["${module.vpc.public_subnets}"]
  security_groups     = ["${aws_security_group.node_ucp_lb.id}"]
  log_bucket_name     = "${var.logs_bucket}"
  log_location_prefix = "${var.service}-${var.service_instance}-manager-alb"
  tags                = "${merge(var.global_tags, map("Name","${var.service}-${var.service_instance}-manager-alb"))}"

  https_listeners = [
    {
      certificate_arn = "${var.manager-ssl-certificate}"
      port            = "443"
    },
  ]

  https_listeners_count = "1"

  http_tcp_listeners = [
    {
      port     = "80"
      protocol = "HTTP"
    },
  ]

  http_tcp_listeners_count = "1"

  target_groups = [
    {
      name                             = "manager-nodes-443-tg"
      backend_protocol                 = "HTTPS"
      backend_port                     = "443"
      health_check_interval            = 10
      health_check_path                = "/_ping"
      health_check_port                = "443"
      health_check_healthy_threshold   = 2
      health_check_unhealthy_threshold = 4
      health_check_timeout             = 5
    },
    {
      name             = "manager-nodes-80-tg"
      backend_protocol = "HTTP"
      backend_port     = "80"
    },
  ]

  target_groups_count = "2"
}

module "node-dtr-alb" {
  source              = "terraform-aws-modules/alb/aws"
  load_balancer_name  = "${var.service}-${var.service_instance}-dtr-alb"
  vpc_id              = "${module.vpc.vpc_id}"
  subnets             = ["${module.vpc.public_subnets}"]
  security_groups     = ["${aws_security_group.node_dtr_lb.id}"]
  log_bucket_name     = "${var.logs_bucket}"
  log_location_prefix = "${var.service}-${var.service_instance}-dtr-alb"
  tags                = "${merge(var.global_tags, map("Name","${var.service}-${var.service_instance}-dtr-alb"))}"

  https_listeners = [
    {
      certificate_arn = "${var.manager-ssl-certificate}"
      port            = "443"
    },
  ]

  https_listeners_count = "1"

  http_tcp_listeners = [
    {
      port     = "80"
      protocol = "HTTP"
    },
  ]

  http_tcp_listeners_count = "1"

  target_groups = [
    {
      name                             = "dtr-nodes-${var.dtr_https_port}-tg"
      backend_protocol                 = "HTTPS"
      backend_port                     = "${var.dtr_https_port}"
      health_check_interval            = 10
      health_check_path                = "/_ping"
      health_check_port                = "${var.dtr_https_port}"
      health_check_healthy_threshold   = 2
      health_check_unhealthy_threshold = 4
      health_check_timeout             = 5
    },
    {
      name             = "dtr-nodes-${var.dtr_http_port}-tg"
      backend_protocol = "HTTP"
      backend_port     = "${var.dtr_http_port}"
    },
  ]

  target_groups_count = "1"
}

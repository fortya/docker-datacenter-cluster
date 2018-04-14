resource "aws_lb" "ucp_lb" {
  name               = "${var.service}-${var.service_instance}-ucp-lb"
  security_groups    = ["${aws_security_group.node_ucp_lb.id}"]
  subnets            = ["${module.vpc.public_subnets}"]
  load_balancer_type = "application"
  idle_timeout       = 400
  tags               = "${merge(var.global_tags, map("Name","${var.service}-${var.service_instance}-ucp-lb"))}"
}

resource "aws_lb_target_group" "ucp_lb_https_tg" {
  name     = "${var.service}-${var.service_instance}-ucp-https-tg"
  port     = "${var.ucp_https_port}"
  protocol = "HTTPS"
  vpc_id   = "${module.vpc.vpc_id}"

  health_check = {
    interval            = 10
    path                = "/_ping"
    port                = "${var.ucp_https_port}"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 4
  }
}

resource "aws_lb_listener" "ucp_lb_https" {
  load_balancer_arn = "${aws_lb.ucp_lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${data.aws_acm_certificate.domain.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.ucp_lb_https_tg.arn}"
    type             = "forward"
  }
}

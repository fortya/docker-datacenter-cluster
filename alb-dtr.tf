resource "aws_lb" "dtr_lb" {
  name               = "${var.service}-${var.service_instance}-dtr-lb"
  security_groups    = ["${aws_security_group.node_dtr_lb.id}"]
  subnets            = ["${module.vpc.public_subnets}"]
  load_balancer_type = "application"
  idle_timeout       = 400
  tags               = "${merge(var.global_tags, map("Name","${var.service}-${var.service_instance}-dtr-lb"))}"
}

resource "aws_lb_target_group" "dtr_lb_http_tg" {
  name     = "${var.service}-${var.service_instance}-dtr-http-tg"
  port     = "${var.dtr_http_port}"
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
}

resource "aws_lb_listener" "dtr_lb_http" {
  load_balancer_arn = "${aws_lb.dtr_lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.dtr_lb_http_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "dtr_lb_https_tg" {
  name     = "${var.service}-${var.service_instance}-dtr-https-tg"
  port     = "${var.dtr_https_port}"
  protocol = "HTTPS"
  vpc_id   = "${module.vpc.vpc_id}"

  health_check = {
    interval            = 10
    path                = "/_ping"
    port                = "${var.dtr_https_port}"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 4
  }
}

resource "aws_lb_listener" "dtr_lb_https" {
  load_balancer_arn = "${aws_lb.dtr_lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${data.aws_acm_certificate.domain.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.dtr_lb_https_tg.arn}"
    type             = "forward"
  }
}

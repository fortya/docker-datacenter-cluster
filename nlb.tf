resource "aws_lb" "swarm_nlb" {
  name               = "${var.service}-${var.service_instance}-swarm-nlb"
  load_balancer_type = "network"
  subnets            = ["${module.vpc.public_subnets}"]
  internal           = false
  idle_timeout       = 400
  tags               = "${merge(var.global_tags, map("Name","${var.service}-${var.service_instance}-swarm-nlb"))}"
}

resource "aws_lb_listener" "manager_nodes_2377" {
  load_balancer_arn = "${aws_lb.swarm_nlb.arn}"
  port              = "2377"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.manager_nodes_2377_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "manager_nodes_2377_tg" {
  name     = "${var.service}-${var.service_instance}-swarm-nlb-2377-tg"
  port     = 2377
  protocol = "TCP"
  vpc_id   = "${module.vpc.vpc_id}"
}

resource "aws_lb_listener" "manager_nodes_7946" {
  load_balancer_arn = "${aws_lb.swarm_nlb.arn}"
  port              = "7946"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.manager_nodes_7946_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "manager_nodes_7946_tg" {
  name     = "${var.service}-${var.service_instance}-swarm-nlb-7946-tg"
  port     = 7946
  protocol = "TCP"
  vpc_id   = "${module.vpc.vpc_id}"
}

resource "aws_lb_listener" "manager_nodes_4789" {
  load_balancer_arn = "${aws_lb.swarm_nlb.arn}"
  port              = "4789"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.manager_nodes_4789_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "manager_nodes_4789_tg" {
  name     = "${var.service}-${var.service_instance}-swarm-nlb-4789-tg"
  port     = 4789
  protocol = "TCP"
  vpc_id   = "${module.vpc.vpc_id}"
}

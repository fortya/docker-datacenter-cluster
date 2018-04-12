module "node-dtr-asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.2.2"

  name                 = "${var.service}-${var.service_instance}-dtr-asg"
  user_data            = "${data.template_file.node-dtr.rendered}"
  key_name             = "${var.ssh_key_name}"
  lc_name              = "${var.service}-${var.service_instance}-dtr-lc"
  iam_instance_profile = "${aws_iam_instance_profile.ddc.id}"
  image_id             = "${data.aws_ami.ubuntu.id}"
  instance_type        = "${var.dtr_node_instance_type}"
  security_groups      = ["${aws_security_group.dtr_node.id}", "${aws_security_group.admin.id}"]

  target_group_arns = "${
    concat(module.node-dtr-alb.target_group_arns,
    list(
      aws_lb_target_group.manager_nodes_2377_tg.arn,
      aws_lb_target_group.manager_nodes_7946_tg.arn,
      aws_lb_target_group.manager_nodes_4789_tg.arn)
    )}"

  root_block_device = [
    {
      volume_size = "150"
      volume_type = "gp2"
    },
  ]

  asg_name                  = "${var.service}-${var.service_instance}-dtr-asg"
  vpc_zone_identifier       = ["${module.vpc.public_subnets}"]
  health_check_type         = "EC2"
  min_size                  = "${var.dtr_node_min_count}"
  max_size                  = "${var.dtr_node_max_count}"
  desired_capacity          = "${var.dtr_node_desired_count}"
  wait_for_capacity_timeout = 0
  tags_as_map               = "${merge(var.global_tags, map("Name", "${var.service}-${var.service_instance}-dtr"))}"
}

resource "aws_autoscaling_policy" "dtr_nodes_scale_out" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${module.node-dtr-asg.this_autoscaling_group_name}"
  cooldown               = "60"                                                              // Give it 60 secods to the alarm to cool down
  name                   = "${var.service}-${var.service_instance}-dtr-asg-scale-out-policy"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1                                                                 // Add 1 instance
}

resource "aws_autoscaling_policy" "dtr_nodes_scale_in" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${module.node-dtr-asg.this_autoscaling_group_name}"
  cooldown               = "60"                                                             // Give it 60 secods to the alarm to cool down
  name                   = "${var.service}-${var.service_instance}-dtr-asg-scale-in-policy"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1                                                               // Add 1 instance
}

resource "aws_cloudwatch_metric_alarm" "dtr_nodes_monitor_scale_out" {
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.dtr_nodes_scale_out.arn}"]
  alarm_description   = "Monitors dtr nodes CPU Utilization"
  alarm_name          = "${var.service}-${var.service_instance}-dtr-asg-monitor-scale-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"                                                              // periods of 5 minutes
  evaluation_periods  = "1"
  statistic           = "Average"
  threshold           = "60"
  treat_missing_data  = "missing"

  dimensions = {
    "AutoScalingGroupName" = "${module.node-dtr-asg.this_autoscaling_group_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "dtr_nodes_monitor_scale_in" {
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.dtr_nodes_scale_in.arn}"]
  alarm_description   = "Monitors dtr nodes CPU Utilization"
  alarm_name          = "${var.service}-${var.service_instance}-dtr-asg-monitor-scale-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"                                                             // periods of 5 minutes
  evaluation_periods  = "1"
  statistic           = "Average"
  threshold           = "40"
  treat_missing_data  = "missing"

  dimensions = {
    "AutoScalingGroupName" = "${module.node-dtr-asg.this_autoscaling_group_name}"
  }

  # Avoid race condition among metrics alarms
  depends_on = ["aws_cloudwatch_metric_alarm.dtr_nodes_monitor_scale_out"]
}

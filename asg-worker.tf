module "node-worker-asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.2.2"

  name                 = "${var.service}-${var.service_instance}-worker-asg"
  user_data            = "${data.template_file.node-worker.rendered}"
  key_name             = "${var.ssh_key_name}"
  lc_name              = "${var.service}-${var.service_instance}-worker-lc"
  iam_instance_profile = "${aws_iam_instance_profile.ddc.id}"
  image_id             = "${data.aws_ami.ubuntu.id}"
  instance_type        = "${var.worker_node_instance_type}"
  security_groups      = ["${aws_security_group.swarm_node.id}", "${aws_security_group.admin.id}"]

  root_block_device = [
    {
      volume_size = "100"
      volume_type = "gp2"
    },
  ]

  asg_name                  = "${var.service}-${var.service_instance}-worker-asg"
  vpc_zone_identifier       = ["${module.vpc.private_subnets}"]
  health_check_type         = "EC2"
  min_size                  = "${var.worker_node_min_count}"
  max_size                  = "${var.worker_node_max_count}"
  desired_capacity          = "${var.worker_node_desired_count}"
  wait_for_capacity_timeout = 0
  tags_as_map               = "${merge(var.global_tags, map("Name", "${var.service}-${var.service_instance}-worker"))}"
}

resource "aws_autoscaling_policy" "worker_nodes_scale_out" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${module.node-worker-asg.this_autoscaling_group_name}"
  cooldown               = "60"                                                                 // Give it 60 secods to the alarm to cool down
  name                   = "${var.service}-${var.service_instance}-worker-asg-scale-out-policy"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1                                                                    // Add 1 instance
}

resource "aws_autoscaling_policy" "worker_nodes_scale_in" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${module.node-worker-asg.this_autoscaling_group_name}"
  cooldown               = "60"                                                                // Give it 60 secods to the alarm to cool down
  name                   = "${var.service}-${var.service_instance}-worker-asg-scale-in-policy"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1                                                                  // Add 1 instance
}

resource "aws_cloudwatch_metric_alarm" "worker_nodes_monitor_scale_out" {
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.worker_nodes_scale_out.arn}"]
  alarm_description   = "Monitors worker nodes CPU Utilization"
  alarm_name          = "${var.service}-${var.service_instance}-worker-asg-monitor-scale-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"                                                                 // periods of 5 minutes
  evaluation_periods  = "1"
  statistic           = "Average"
  threshold           = "60"
  treat_missing_data  = "missing"

  dimensions = {
    "AutoScalingGroupName" = "${module.node-worker-asg.this_autoscaling_group_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "worker_nodes_monitor_scale_in" {
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.worker_nodes_scale_in.arn}"]
  alarm_description   = "Monitors worker nodes CPU Utilization"
  alarm_name          = "${var.service}-${var.service_instance}-worker-asg-monitor-scale-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"                                                                // periods of 5 minutes
  evaluation_periods  = "1"
  statistic           = "Average"
  threshold           = "40"
  treat_missing_data  = "missing"

  dimensions = {
    "AutoScalingGroupName" = "${module.node-worker-asg.this_autoscaling_group_name}"
  }

  # Avoid race condition among metrics alarms
  depends_on = ["aws_cloudwatch_metric_alarm.worker_nodes_monitor_scale_out"]
}

module "node-master-asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name           = "${var.service}-${var.service_instance}-master-asg"
  load_balancers = ["${module.node-master-elb.this_elb_id}"]

  user_data = "${data.template_file.node-master.rendered}"
  key_name  = "${var.ssh_key_name}"

  lc_name = "${var.service}-${var.service_instance}-master-lc"

  image_id        = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.master_node_instance_type}"
  security_groups = ["${aws_security_group.node-manager.id}", "${aws_security_group.node-ucp-elb.id}"]

  root_block_device = [
    {
      volume_size = "150"
      volume_type = "gp2"
    },
  ]

  asg_name                  = "${var.service}-${var.service_instance}-master-asg"
  vpc_zone_identifier       = ["${module.vpc.public_subnets}"]
  health_check_type         = "EC2"
  min_size                  = "1"
  max_size                  = "1"
  desired_capacity          = "1"
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Provisioner"
      value               = "Terraform"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "${var.service_owner}"
      propagate_at_launch = true
    },
    {
      key                 = "Stage"
      value               = "${var.service_stage}"
      propagate_at_launch = true
    },
    {
      key                 = "Service"
      value               = "${var.service_instance}"
      propagate_at_launch = true
    },
    {
      key                 = "Instance"
      value               = "${var.service_instance}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.service}-${var.service_instance}-master"
      propagate_at_launch = true
    },
  ]
}

module "node-manager-asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name           = "${var.service}-${var.service_instance}-manager-asg"
  load_balancers = ["${module.node-manager-elb.this_elb_id}"]

  user_data = "${data.template_file.node-manager.rendered}"
  key_name  = "${var.ssh_key_name}"

  lc_name = "${var.service}-${var.service_instance}-manager-lc"

  image_id        = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.manager_node_instance_type}"
  security_groups = ["${aws_security_group.node-manager.id}"]

  root_block_device = [
    {
      volume_size = "150"
      volume_type = "gp2"
    },
  ]

  asg_name                  = "${var.service}-${var.service_instance}-manager-asg"
  vpc_zone_identifier       = ["${module.vpc.public_subnets}"]
  health_check_type         = "EC2"
  min_size                  = "${var.manager_node_min_count}"
  max_size                  = "${var.manager_node_max_count}"
  desired_capacity          = "${var.manager_node_desired_count}"
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Provisioner"
      value               = "Terraform"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "${var.service_owner}"
      propagate_at_launch = true
    },
    {
      key                 = "Stage"
      value               = "${var.service_stage}"
      propagate_at_launch = true
    },
    {
      key                 = "Service"
      value               = "${var.service}"
      propagate_at_launch = true
    },
    {
      key                 = "Instance"
      value               = "${var.service}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.service}-${var.service_instance}-manager"
      propagate_at_launch = true
    },
  ]
}

module "node-dtr-asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name           = "${var.service}-${var.service_instance}-dtr-asg"
  load_balancers = ["${module.node-dtr-elb.this_elb_id}"]

  user_data = "${data.template_file.node-dtr.rendered}"
  key_name  = "${var.ssh_key_name}"

  lc_name = "${var.service}-${var.service_instance}-dtr-lc"

  image_id        = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.dtr_node_instance_type}"
  security_groups = ["${aws_security_group.node-worker.id}", "${aws_security_group.node-dtr-elb.id}"]

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

  tags = [
    {
      key                 = "Provisioner"
      value               = "Terraform"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "${var.service_owner}"
      propagate_at_launch = true
    },
    {
      key                 = "Stage"
      value               = "${var.service_stage}"
      propagate_at_launch = true
    },
    {
      key                 = "Service"
      value               = "${var.service}"
      propagate_at_launch = true
    },
    {
      key                 = "Instance"
      value               = "${var.service}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.service}-${var.service_instance}-dtr"
      propagate_at_launch = true
    },
  ]
}

module "node-worker-asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.service}-${var.service_instance}-worker-asg"

  user_data = "${data.template_file.node-worker.rendered}"
  key_name  = "${var.ssh_key_name}"

  lc_name = "${var.service}-${var.service_instance}-worker-lc"

  image_id        = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.worker_node_instance_type}"
  security_groups = ["${aws_security_group.node-worker.id}"]

  root_block_device = [
    {
      volume_size = "100"
      volume_type = "gp2"
    },
  ]

  asg_name                  = "${var.service}-${var.service_instance}-worker-asg"
  vpc_zone_identifier       = ["${module.vpc.public_subnets}"]
  health_check_type         = "EC2"
  min_size                  = "${var.worker_node_min_count}"
  max_size                  = "${var.worker_node_max_count}"
  desired_capacity          = "${var.worker_node_desired_count}"
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Provisioner"
      value               = "Terraform"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "${var.service_owner}"
      propagate_at_launch = true
    },
    {
      key                 = "Stage"
      value               = "${var.service_stage}"
      propagate_at_launch = true
    },
    {
      key                 = "Service"
      value               = "${var.service}"
      propagate_at_launch = true
    },
    {
      key                 = "Instance"
      value               = "${var.service_instance}"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "${var.service}-${var.service_instance}-worker"
      propagate_at_launch = true
    },
  ]
}

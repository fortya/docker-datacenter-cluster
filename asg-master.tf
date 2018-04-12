# module "node-master-asg" {
#   source  = "terraform-aws-modules/autoscaling/aws"
#   version = "2.2.2"
#   name           = "${var.service}-${var.service_instance}-master-asg"
#   load_balancers = ["${module.node-master-elb.this_elb_id}"]
#   # target_group_arns    = ["${module.node-master-alb.target_group_arns}"]
#   user_data            = "${data.template_file.node-master.rendered}"
#   key_name             = "${var.ssh_key_name}"
#   lc_name              = "${var.service}-${var.service_instance}-master-lc"
#   iam_instance_profile = "${aws_iam_instance_profile.ddc.id}"
#   image_id             = "${data.aws_ami.ubuntu.id}"
#   instance_type        = "${var.master_node_instance_type}"
#   security_groups      = ["${aws_security_group.node-manager.id}", "${aws_security_group.node-ucp-elb.id}"]
#   root_block_device = [
#     {
#       volume_size = "150"
#       volume_type = "gp2"
#     },
#   ]
#   asg_name                  = "${var.service}-${var.service_instance}-master-asg"
#   vpc_zone_identifier       = ["${module.vpc.public_subnets}"]
#   health_check_type         = "EC2"
#   min_size                  = "1"
#   max_size                  = "1"
#   desired_capacity          = "1"
#   wait_for_capacity_timeout = 0
#   tags_as_map               = "${merge(var.global_tags, map("Name", "${var.service}-${var.service_instance}-master"))}"
# }


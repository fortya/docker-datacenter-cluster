data "template_file" "ddc_instance_role_policy" {
  template = "${file("${path.module}/iam-policies/ec2-role-trust-policy.tpl")}"
}

data "template_file" "allow_s3_access_policy" {
  template = "${file("${path.module}/iam-policies/allow-s3-access-policy.tpl")}"

  vars = {
    S3_CONFIGURATIONS_BUCKET_NAME = "${aws_s3_bucket.configurations.id}"
  }
}

resource "aws_iam_role" "ddc_instance_role" {
  name               = "${var.service}-${var.service_instance}-ddc-instance-role"
  assume_role_policy = "${data.template_file.ddc_instance_role_policy.rendered}"
}

resource "aws_iam_role_policy" "allow_s3_access" {
  name   = "${var.service}-${var.service_instance}-allow-s3-access"
  policy = "${data.template_file.allow_s3_access_policy.rendered}"
  role   = "${aws_iam_role.ddc_instance_role.id}"
}

resource "aws_iam_instance_profile" "ddc" {
  name = "${var.service}-${var.service_instance}-ddc-instance-profile"
  path = "/"
  role = "${aws_iam_role.ddc_instance_role.name}"
}

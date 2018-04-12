# We use S3 to store a file with the configurations that worker, and dtr nodes need to join the cluter
resource "aws_s3_bucket" "configurations" {
  bucket = "${var.service}-${var.service_instance}-configurations-${random_id.bucket_id.hex}"
  acl    = "private"
  tags   = "${merge(var.global_tags, map("Name","${var.service}-${var.service_instance}-configurations-${random_id.bucket_id.hex}"))}"
}

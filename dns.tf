resource "aws_route53_record" "ucp-nodes" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.ucp_endpoint}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.node-manager-elb.this_elb_dns_name}"]
}

resource "aws_route53_record" "dtr-nodes" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.dtr_endpoint}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.node-dtr-elb.this_elb_dns_name}"]
}
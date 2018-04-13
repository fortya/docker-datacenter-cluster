data "aws_acm_certificate" "domain" {
  domain   = "*.${var.domain}"
  statuses = ["ISSUED"]
}

resource "aws_route53_record" "ucp" {
  zone_id = "${var.hosted_zone_id}"
  name    = "ucp.${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.ucp_lb.dns_name}"]
}

resource "aws_route53_record" "dtr" {
  zone_id = "${var.hosted_zone_id}"
  name    = "dtr.${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.dtr_lb.dns_name}"]
}

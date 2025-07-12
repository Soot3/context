data "aws_route53_zone" "prod" {
  name = "drafttests.click"
}

resource "aws_route53_zone" "dev" {
  name = "dev.drafttests.click"
}

resource "aws_route53_record" "dev-ns" {
  zone_id = data.aws_route53_zone.prod.zone_id
  name    = "dev.drafttests.click"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.dev.name_servers
} 
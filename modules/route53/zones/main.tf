resource "aws_route53_zone" "zone" {

  name          = var.hosted_zone_name
  force_destroy = false

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(
    var.tags
  )
}

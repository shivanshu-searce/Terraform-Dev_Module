provider "aws" {
  region = var.region
}

resource "aws_vpc_endpoint" "api_gateway" {

  vpc_id              = var.vpc_id
  service_name        = var.service_name
  vpc_endpoint_type   = var.vpc_endpoint_type
  security_group_ids  = var.security_group_ids
  subnet_ids          = var.subnet_ids
  private_dns_enabled = true
  tags = {
    "Name"             = "Rest-API-Endpoint-POC"
    "Application Name" = "Globe-Project"
    "Owner"            = "Shivanshu"
    "Environment"      = "dev"
  }
}


# resource "aws_vpc_endpoint" "vpc_endpoints" {
#   count               = length(local.vpc_endpoints) > 0 ? length(local.vpc_endpoints) : 0
#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.${var.region}.${lookup(element(local.vpc_endpoints, count.index), "endpoint")}"
#   vpc_endpoint_type   = lookup(element(local.vpc_endpoints, count.index), "type")
#   private_dns_enabled = lookup(element(local.vpc_endpoints, count.index), "type") == "Interface" ? true : false
#   subnet_ids          = lookup(element(local.vpc_endpoints, count.index), "type") == "Interface" ? local.distinct_vpc_endpoint_subnets : null
#   security_group_ids  = lookup(element(local.vpc_endpoints, count.index), "type") == "Interface" ? aws_security_group.vpc_endpoint_sg.*.id : null
#   route_table_ids     = lookup(element(local.vpc_endpoints, count.index), "type") == "Gateway" ? aws_route_table.private.*.id : null
#   tags = merge(
#     {
#       "Name" : format("%s-vpc-endpoint-%s", var.prefix, lookup(element(local.vpc_endpoints, count.index), "endpoint"))
#     },
#     var.common_tags
#   )
# }

#output "zone_ids" {
# value = values(module.zones.zone_ids)[0]
#}

output "zone_ids" {
  description = "Map of zone names to their corresponding zone IDs"
  value       = aws_route53_zone.zone.zone_id
}

# output "route53_zone_zone_arn" {
#   description = "Zone ARN of Route53 zone"
#   value       = { for k, v in aws_route53_zone.zone : k => v.arn }
# }

output "route53_static_zone_name" {
  description = "Name of Route53 zone created statically to avoid invalid count argument error when creating records and zones simultaneously"
  value       = { for k, v in var.zones : k => lookup(v, "domain_name", k) if var.create }
}

output "name" {
  value       = join("", aws_lb.alb.*.name)
  description = "The ARN suffix of the ALB."
}

output "arn" {
  value       = join("", concat(aws_lb.alb.*.arn))
  description = "The ARN of the ALB."
}
output "dns_name" {
  value       = join("", aws_lb.alb.*.dns_name)
  description = "DNS name of ALB."
}
output "zone_id" {
  value       = join("", aws_lb.alb.*.zone_id)
  description = "The ID of the zone which ALB is provisioned."
}


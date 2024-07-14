output "api_gateway_id" {
  description = "The ID of the created API Gateway"
  value       = join("", aws_api_gateway_rest_api.default.*.id)
}

output "api_gateway_arn" {
  description = "The arn of the rest api"
  value       = join("", aws_api_gateway_rest_api.default.*.arn)
}

output "deployment_id" {
  description = "The ID of the created API Gateway deployment"
  value       = join("", aws_api_gateway_deployment.default.*.id)
}




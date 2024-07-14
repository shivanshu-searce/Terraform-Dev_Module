# output "api_gateway_private_ip" {
#   value = aws_vpc_endpoint.api_gateway.network_interface_ids[0] != null ? aws_network_interface.api_gateway_private_ip.private_ip : "No IP assigned"
# }

# data "aws_network_interface" "api_gateway_private_ip" {
#   count = length(aws_vpc_endpoint.api_gateway.network_interface_ids)
#   id    = element(aws_vpc_endpoint.api_gateway.network_interface_ids, count.index)
# }

# output "api_gateway_private_ip" {
#   value = [for ni in data.aws_network_interface.api_gateway_private_ip : ni.private_ip]
# }

output "network_ids" {
  value = tolist(aws_vpc_endpoint.api_gateway.network_interface_ids)
}

output "endpoint_id" {
  value = aws_vpc_endpoint.api_gateway.id
}


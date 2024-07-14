variable "vpc_id" {
  type        = string
  description = "VPC used for the Globe Project Demo"
  default     = "vpc-064fac12ad5ee182f"
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "service_name" {
  type        = string
  description = "Service type to be used along with the endpoint"
  default     = "com.amazonaws.ap-south-1.execute-api"
}

variable "vpc_endpoint_type" {
  type        = string
  description = "Endpoint type, Interface or Gateway"
  default     = "Interface"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security Groups to be associated to the Endpoint"
  default     = ["sg-0eca89ee530d24226"]
}

variable "private_dns_enabled" {
  type        = bool
  description = "Set 'true' to enable private DNS"
  default     = true
}

variable "ip_address_type" {
  type        = string
  description = "The IP address type for the endpoint. Valid values are ipv4, dualstack, and ipv6."
  default     = "ipv4"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The ID of one or more subnets in which to create a network interface for the endpoint. Applicable for endpoints of type GatewayLoadBalancer and Interface."
  default     = ["subnet-0ff79d3add0d8f1bc", "subnet-04d3ab8f6c890ace4"]
}

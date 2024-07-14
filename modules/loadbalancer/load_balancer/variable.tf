variable "enable" {
  type        = bool
  default     = false
  description = "If true, create load balancer."
}

variable "internal" {
  type        = string
  default     = ""
  description = "If true, the LB will be internal."
}
variable "load_balancer_type" {
  type        = string
  default     = ""
  description = "The type of load balancer to create. Possible values are application or network. The default value is application."
}
variable "drop_invalid_header_fields" {
  type        = bool
  default     = false
  description = "drop_invalid_header_fields"
}
variable "security_groups" {
  type        = list(any)
  default     = []
  description = "A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application."
}
variable "subnet_mapping" {
  default     = []
  type        = list(map(string))
  description = "A list of subnet mapping blocks describing subnets to attach to network load balancer"
}

variable "access_logs" {
  description = "Map containing access logging configuration for load balancer."
  type        = map(string)
  default = {
  }
}
# variable "client_routing_policy" {
#   type        = string
#   description = "How traffic is distributed among the load balancer Availability Zones. Possible values are any_availability_zone (default), availability_zone_affinity, or partial_availability_zone_affinity"
#   default     = ""
#   validation {
#     condition     = var.client_routing_policy == "availability_zone_affinity" || var.client_routing_policy == "partial_availability_zone_affinity" || var.client_routing_policy == "any_availability_zone"
#     error_message = "Possible values are any_availability_zone (default), availability_zone_affinity, or partial_availability_zone_affinity"
#   }
# }

variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}
variable "networklbcreate" {
  type        = bool
  default     = false
  description = "network lb create."
}

variable "log_bucket_name" {
  type        = string
  default     = ""
  description = "S3 bucket (externally created) for storing load balancer access logs. Required if logging_enabled is true."
}
variable "subnets" {
  type        = list(any)
  default     = []
  description = "A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value will for load balancers of type network will force a recreation of the resource."
  sensitive   = true
}
variable "enable_deletion_protection" {
  type        = bool
  default     = false
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
}
variable "idle_timeout" {
  type        = number
  default     = 60
  description = "The time in seconds that the connection is allowed to be idle."
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  default     = true
  description = "Indicates whether cross zone load balancing should be enabled in application load balancers."
}
variable "name_prefix" {
  description = "The resource name prefix and Name tag of the load balancer. Cannot be longer than 6 characters"
  type        = string
  default     = null
}
variable "enable_http2" {
  type        = bool
  default     = true
  description = "Indicates whether HTTP/2 is enabled in application load balancers."
}
variable "tags" {
  type = map(string)
}

variable "load_balancer_create_timeout" {
  type        = string
  default     = "10m"
  description = "Timeout value when creating the ALB."
}

variable "load_balancer_delete_timeout" {
  type        = string
  default     = "10m"
  description = "Timeout value when deleting the ALB."
}

variable "load_balancer_update_timeout" {
  type        = string
  default     = "10m"
  description = "Timeout value when updating the ALB."
}
variable "ip_address_type" {
  type        = string
  sensitive   = true
  default     = "ipv4"
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack."
}

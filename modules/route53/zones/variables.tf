variable "AccountId" {
  type    = string
  default = ""
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "us-east-1"
}

variable "create" {
  description = "Whether to create Route53 zone"
  type        = bool
  default     = true
}

variable "zones" {
  description = "Map of Route53 zone parameters"
  type        = any
  default     = {}
}

variable "zone_name" {
  type        = string
  description = "zone name"
  default     = ""
}

variable "tags" {
  description = "Tags added to all zones. Will take precedence over tags from the 'zones' variable"
  type        = map(any)
  default     = {}
}

variable "environment" {
  type        = string
  description = "environment details"
  default     = ""
}

# default = {
#   policy1 = {
#     type = "PRIMARY"

#   }
# }

/*variable "records" {
  description = "List of DNS records with their routing policies"
  type = list(object({
    name  = string
    type  = string
    ttl   = number
    value = string
    routing_policy = object({
      type                             = string
      set_identifier                   = string
      health_check_id                  = optional(string)
      weight                           = optional(number)
      multivalue_answer_routing_policy = optional(bool)
    })
  }))
}*/

variable "hosted_zone_name" {
  type        = string
  description = "Name of the hosted zone"
  default     = "globepoc.co.in"
}

variable "vpc_id" {
  type        = string
  description = "VPC used for the Globe Project Demo"
  default     = "vpc-079a968a221b7733a"
}

variable "zone_id" {
  type    = string
  default = ""
}

# variable "records" {
#   description = "Map of records parameters"
#   type = map(object({
#     name                             = string
#     type                             = string
#     ttl                              = number
#     records                          = list(string)
#     set_identifier                   = optional(string)
#     health_check_id                  = optional(string)
#     multivalue_answer_routing_policy = optional(bool)
#     allow_overwrite                  = optional(bool)
#   }))
# }

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

variable "failover_routing_policies" {
  description = "Map of failover routing policies"
  type        = map(any)
  default     = {}
}

variable "latency_routing_policy" {
  description = "Map of latency routing policies"
  type        = map(any)
  default     = {}
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

variable "records" {
  description = "List of DNS records with their routing policies"
  type = list(object({
    name  = string
    type  = string
    ttl   = optional(number)
    value = optional(string)
    routing_policy = object({
      type            = optional(string)
      failover_type   = optional(string)
      set_identifier  = optional(string)
      health_check_id = optional(string)
      weight          = optional(number)
      alias_target = optional(object({
        dns_name               = string
        hosted_zone_id         = string
        evaluate_target_health = optional(bool)
      }))
      geolocation_routing_policy = optional(object({
        continent   = optional(string)
        country     = optional(string)
        subdivision = optional(string)
      }))
      latency_routing_policy = optional(object({
        region = string
      }))
    })
  }))
  default = []
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

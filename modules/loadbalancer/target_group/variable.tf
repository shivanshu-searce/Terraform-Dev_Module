variable "name" {
  type        = string
  default     = "tgt"
  description = "Name  (e.g. `app` or `cluster`)."
}
variable "name_prefix" {
  description = "The resource name prefix and Name tag of the load balancer. Cannot be longer than 6 characters"
  type        = string
  default     = null
}
variable "listener_ssl_policy_default" {
  description = "The security policy if using HTTPS externally on the load balancer. [See](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html)."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}
variable "enable" {
  description = "Enable or disable the creation of target groups"
  type        = bool
  default     = true
}
variable "acm_domain" {
  type        = string
  description = "Domain of the ACM certificate"
}
variable "certificate_type" {
  type        = list(string)
  description = "Certificate type, e.g. Amazon Issued"
}
variable "target_groups" {
  description = "A list of target group configurations"
  type = list(object({
    name                 = string
    backend_port         = number
    backend_protocol     = string
    target_type          = string
    deregistration_delay = optional(number)
    slow_start           = optional(number)
    health_check = optional(object({
      enabled             = optional(bool)
      interval            = optional(number)
      path                = optional(string)
      port                = optional(string)
      healthy_threshold   = optional(number)
      unhealthy_threshold = optional(number)
      timeout             = optional(number)
      protocol            = optional(string)
      matcher             = optional(string)
    }))
    stickiness = optional(object({
      enabled         = optional(bool)
      cookie_duration = optional(number)
      type            = optional(string)
    }))
  }))
}
variable "lbARN" {
  description = "The ARN of the load balancer"
  type        = string
}
variable "listener_rule" {
  type = map(object({
    name        = string
    priority    = number
    type        = optional(string, "forward")
    path_values = optional(list(string), null)
    host_values = optional(list(string), null)
  }))
}
variable "targets" {
  description = "List of targets to attach to the target groups."
  type = list(object({
    target_group_index = number
    target_id          = optional(list(string))
    port               = number
  }))
}
variable "listeners" {
  type = map(object({
    port     = string
    protocol = string
    fixed_response = optional(object({
      content_type = optional(string)
      message_body = optional(string)
      status_code  = optional(string)
    }))
    authenticate_cognito = optional(object({
      authentication_request_extra_params = optional(map(string))
      on_unauthenticated_request          = optional(string)
      scope                               = optional(string)
      session_cookie_name                 = optional(string)
      session_timeout                     = optional(string)
      user_pool_arn                       = optional(string)
      user_pool_client_id                 = optional(string)
      user_pool_domain                    = optional(string)
    }))
    default_action = object({
      type               = string
      target_group_index = number
      port               = optional(string)
      protocol           = optional(string)
      status_code        = string
      content_type       = optional(string)
      message_body       = optional(string)
    })
    authenticate_oidc = optional(object({
      authentication_request_extra_params = optional(map(string))
      authorization_endpoint              = optional(string)
      client_id                           = optional(string)
      client_secret                       = optional(string)
      issuer                              = optional(string)
      on_unauthenticated_request          = optional(string)
      scope                               = optional(string)
      session_cookie_name                 = optional(string)
      session_timeout                     = optional(string)
      token_endpoint                      = optional(string)
      user_info_endpoint                  = optional(string)
    }))
  }))
}
variable "enable_path_based" {
  type        = bool
  default     = true
  description = "enable path based routing for your Application load balancer"
}
variable "tags" {
  type = map(string)
}
variable "target_group_tags" {
  description = "A map of tags to add to all target groups"
  type        = map(string)
  default     = {}
}
variable "enable_host_based" {
  type        = bool
  description = "Enable host header based routing"
}
variable "instance_count" {
  type        = number
  default     = 0
  description = "The count of instances."
}
variable "networklbcreate" {
  type = bool
}
variable "listener_certificate_arn" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The ARN of the SSL server certificate. Exactly one certificate is required if the protocol is HTTPS."
}
variable "vpc_id" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The identifier of the VPC in which to create the target group."
}
variable "log_bucket_name" {
  type        = string
  default     = ""
  description = "S3 bucket (externally created) for storing load balancer access logs. Required if logging_enabled is true."
}
variable "enable_connection_draining" {
  type        = bool
  default     = false
  description = "Whether or not to enable connection draining (\"true\" or \"false\")."
}
variable "connection_draining_timeout" {
  type        = number
  default     = 300
  description = "The time after which connection draining is aborted in seconds."
}
variable "connection_draining" {
  type        = bool
  default     = false
  description = "TBoolean to enable connection draining. Default: false."
}
variable "availability_zones" {
  default     = []
  type        = list(map(string))
  description = "The AZ's to serve traffic in."
}
variable "health_check_target" {
  description = "The target to use for health checks."
  type        = string
  default     = "TCP:80"
}
variable "health_check_timeout" {
  type        = number
  default     = 5
  description = "The time after which a health check is considered failed in seconds."
}

variable "health_check_interval" {
  description = "The time between health check attempts in seconds."
  type        = number
  default     = 30
}
variable "health_check_unhealthy_threshold" {
  type        = number
  default     = 2
  description = "The number of failed health checks before an instance is taken out of service."
}
variable "health_check_healthy_threshold" {
  type        = number
  default     = 10
  description = "The number of successful health checks before an instance is put into service."
}
variable "target_type" {
  type        = string
  default     = "ip"
  description = "The type of target that you must specify when registering targets with this target group."
}

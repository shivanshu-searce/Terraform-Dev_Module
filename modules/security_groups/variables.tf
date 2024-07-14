variable "create" {
  description = "Whether to create an instance"
  type        = bool
  default     = true
}
variable "name" {
  type        = string
  description = "Security group name"
}
variable "description" {
  type        = string
  description = "Security group description"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
variable "common_tags" {
  type    = map(any)
  default = {}
}
variable "sg_tags" {
  type    = map(any)
  default = {}
}

variable "security_group_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    type        = string
    origin_type = string
    origins     = list(string)
  }))
}

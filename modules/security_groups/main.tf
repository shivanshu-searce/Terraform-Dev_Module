resource "aws_security_group" "sg" {
  count       = var.create ? 1 : 0
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags = merge(
    var.common_tags,
    var.sg_tags
  )
}

locals {
  security_group_rules = {
    for index, rule in var.security_group_rules :
    index => rule
  }
}

resource "aws_security_group_rule" "sg_rule" {
  for_each                 = length(local.security_group_rules) > 0 ? local.security_group_rules : {}
  description              = each.value.description
  security_group_id        = join("", aws_security_group.sg.*.id)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  type                     = each.value.type
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.origin_type == "cidr_blocks" ? each.value.origins : null
  source_security_group_id = each.value.origin_type == "sg" ? each.value.origins[0] : null
}

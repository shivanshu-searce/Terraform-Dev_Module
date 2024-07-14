resource "aws_lb_target_group" "main" {
  for_each = var.enable ? { for idx, tg in var.target_groups : idx => tg } : {}

  name                 = lookup(each.value, "name", null)
  port                 = lookup(each.value, "backend_port", null)
  protocol             = lookup(each.value, "backend_protocol", null) != null ? upper(lookup(each.value, "backend_protocol")) : null
  vpc_id               = var.vpc_id
  target_type          = lookup(each.value, "target_type", null)
  deregistration_delay = lookup(each.value, "deregistration_delay", null)
  slow_start           = lookup(each.value, "slow_start", null)

  dynamic "health_check" {
    for_each = length(keys(lookup(each.value, "health_check", {}))) == 0 ? [] : [lookup(each.value, "health_check", {})]

    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  dynamic "stickiness" {
    for_each = length(keys(lookup(each.value, "stickiness", {}))) == 0 ? [] : [lookup(each.value, "stickiness", {})]

    content {
      enabled         = lookup(stickiness.value, "enabled", null)
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      type            = stickiness.value["type"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags
}

resource "aws_lb_target_group_attachment" "main" {
  count = length(var.targets[0].target_id)

  target_group_arn = aws_lb_target_group.main[var.targets[0].target_group_index].arn
  target_id        = var.targets[0].target_id[count.index]
  port             = var.targets[0].port
}

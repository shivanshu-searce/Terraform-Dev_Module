resource "aws_lb_listener" "frontend_https" {
  for_each          = var.listeners
  load_balancer_arn = var.lbARN
  port              = each.value.port
  protocol          = lookup(each.value, "protocol", "HTTPS")
  certificate_arn   = each.value["protocol"] == "HTTPS" ? lookup(each.value, "certificate_arn", data.aws_acm_certificate.listener_certificate.arn) : null
  ssl_policy        = each.value["protocol"] == "HTTPS" ? lookup(each.value, "ssl_policy", var.listener_ssl_policy_default) : null
  alpn_policy       = each.value["protocol"] == "TCP" ? lookup(each.value, "alpn_policy", null) : null

  default_action {
    type             = each.value.default_action.type
    target_group_arn = contains([null, "", "forward"], lookup(each.value.default_action, "action_type", "")) && each.value.default_action.type != "fixed-response" ? aws_lb_target_group.main[each.value.default_action.target_group_index].id : null

    redirect {
      port        = each.value.default_action.port
      protocol    = each.value.default_action.protocol
      status_code = each.value.default_action.status_code
    }
    dynamic "fixed_response" {
      for_each = each.value.default_action.type == "fixed-response" ? [each.value.fixed_response] : []
      content {
        content_type = each.value.fixed_response.content_type
        message_body = each.value.fixed_response.message_body
        status_code  = each.value.fixed_response.status_code
      }

    }

    dynamic "authenticate_cognito" {
      for_each = each.value.default_action.type == "authenticate-cognito" ? [each.value.authenticate-cognito] : []
      content {
        authentication_request_extra_params = each.value.authenticate_cognito.authentication_request_extra_params
        on_unauthenticated_request          = each.value.authenticate_cognito.on_unauthenticated_request
        scope                               = each.value.authenticate_cognito.scope
        session_cookie_name                 = each.value.authenticate_cognito.session_cookie_name
        session_timeout                     = each.value.authenticate_cognito.session_timeout
        user_pool_arn                       = each.value.authenticate_cognito.user_pool_arn
        user_pool_client_id                 = each.value.authenticate_cognito.user_pool_client_id
        user_pool_domain                    = each.value.authenticate_cognito.user_pool_domain
      }
    }

    dynamic "authenticate_oidc" {
      for_each = each.value.default_action.type == "authenticate-oidc" ? [each.value.authenticate-cognito] : []
      content {
        authentication_request_extra_params = each.value.authenticate_oidc.authentication_request_extra_params
        authorization_endpoint              = each.value.authenticate_oidc.authorization_endpoint
        client_id                           = each.value.authenticate_oidc.client_id
        client_secret                       = each.value.authenticate_oidc.client_secret
        issuer                              = each.value.authenticate_oidc.issuer
        on_unauthenticated_request          = each.value.authenticate_oidc.on_unauthenticated_request
        scope                               = each.value.authenticate_oidc.scope
        session_cookie_name                 = each.value.authenticate_oidc.session_cookie_name
        session_timeout                     = each.value.authenticate_oidc.session_timeout
        token_endpoint                      = each.value.authenticate_oidc.token_endpoint
        user_info_endpoint                  = each.value.authenticate_oidc.user_info_endpoint
      }
    }
  }
  tags = var.tags
}


#------- Path based routing rule----

resource "aws_lb_listener_rule" "path_routing" {
  for_each     = !var.networklbcreate && var.enable_path_based ? var.listener_rule : {}
  listener_arn = aws_lb_listener.frontend_https[0].arn
  priority     = each.value.priority

  tags = var.tags

  action {
    type             = lookup(var.listener_rule[each.key], "type", "forward")
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  condition {
    path_pattern {
      values = lookup(var.listener_rule[each.key], "path_values", [])
    }
  }

}

resource "aws_lb_listener_rule" "host_based_routing" {
  for_each     = !var.networklbcreate && var.enable_host_based && !var.enable_path_based ? var.listener_rule : {}
  listener_arn = aws_lb_listener.frontend_https[0].arn
  priority     = each.value.priority

  tags = var.tags

  action {
    type             = lookup(var.listener_rule[each.key], "type", "forward")
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  condition {
    host_header {
      values = lookup(var.listener_rule[each.key], "host_values", [])
    }
  }
}


data "aws_acm_certificate" "listener_certificate" {
  domain = var.acm_domain
  types  = var.certificate_type
}


#####API GATEWAY##############
module "apigateway" {
  source                   = "../modules/apigateway"
  enabled                  = var.enabled
  region                   = var.region
  AccountId                = var.AccountId
  name                     = var.name
  description              = var.description
  binary_media_types       = var.binary_media_types
  minimum_compression_size = var.minimum_compression_size
  api_key_source           = var.api_key_source
  endpoint_configuration = [
    {
      "type"             = ["PRIVATE"]
      "vpc_endpoint_ids" = module.vpc_endpoints.endpoint_id
    }
  ]
  vpc_link_count        = 1
  target_arns           = [module.nlb.arn]
  vpc_link_names        = var.vpc_link_names
  vpc_link_descriptions = ["POC Globe Project"]
  connection_types      = var.connection_types
  vpc_id                = var.vpc_id
  tags = {
    "region"           = var.region
    "account"          = var.AccountId
    "Application_name" = var.application-name
    "Owner"            = var.owner
  }
  deployment_enabled = true
  stage_enabled      = true
  stage_name         = var.stage_name
  #enable_cors        = false

  # Api Gateway Resource
  path_parts = var.path_parts

  # Api Gateway Method
  method_enabled = var.method_enabled
  http_methods   = var.http_methods

  # Api Gateway Integration
  integration_types              = var.integration_types
  authorizations                 = var.authorizations
  integration_http_methods       = var.integration_http_methods
  uri                            = ["http://${module.nlb.dns_name}"]
  integration_request_parameters = var.integration_request_parameters
  cache_key_parameters           = var.cache_key_parameters
  cache_namespaces               = var.cache_namespaces
  status_codes                   = var.status_codes
}

######LOAD BALANCER#############

module "alb" {
  source                     = "../modules/loadbalancer/load_balancer"
  networklbcreate            = var.networklbcreate
  name                       = "${var.name_prefix}-${var.environment}-alb"
  enable                     = var.enable
  internal                   = var.internal
  security_groups            = [module.security_group.securitygroup_id]
  subnets                    = var.alb_subnets
  enable_deletion_protection = var.deletion_protection
  tags = merge(var.tags,
    {
      Application_Name = var.your_application_name,
      Owner            = var.owner,
      Environment      = var.environment
    }
  )
}

module "nlb" {
  source                     = "../modules/loadbalancer/load_balancer"
  networklbcreate            = true
  name                       = "${var.name_prefix}-${var.environment}-network-lb"
  enable                     = var.enable
  internal                   = false
  security_groups            = [module.security_group.securitygroup_id]
  subnets                    = var.alb_subnets
  enable_deletion_protection = var.deletion_protection
  tags = merge(var.tags,
    {
      Application_Name = var.your_application_name,
      Owner            = var.owner,
      Environment      = var.environment
    }
  )
}

module "tgt" {
  source            = "../modules/loadbalancer/target_group"
  enable            = var.enable
  lbARN             = module.alb.arn
  vpc_id            = var.vpc_id
  target_groups     = var.target_groups
  enable_host_based = var.enable_host_based
  name_prefix       = var.name_prefix
  targets = [
    {
      target_group_index = 0
      target_id          = [for nic in data.aws_network_interface.nics : nic.private_ip]
      port               = 443
      health_check       = "/"
      matcher            = "403"
    }
  ]
  listeners = {
    listener_1 = {
      port            = "443"
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:ap-south-1:088585194665:certificate/d7205f54-a4ec-4db3-8d24-04a8580b41e8"
      ssl_policy      = "ELBSecurityPolicy-2016-08"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed response content"
        status_code  = "200"
      }
      default_action = {
        target_group_index = 0
        type               = "forward"
        port               = 80
        protocol           = "HTTPS"
        status_code        = "HTTP_301"
      }
    },
    listener_2 = {
      port     = "80"
      protocol = "HTTPS"
      default_action = {
        target_group_index = 0
        type               = "redirect"
        port               = 443
        protocol           = "HTTPS"
        status_code        = "HTTP_301"
      }
    }
  }

  listener_rule     = var.listener_rule
  networklbcreate   = var.networklbcreate
  acm_domain        = var.acm_domain
  certificate_type  = var.certificate_type
  enable_path_based = var.enable_path_based
  tags = merge(var.tags,
    {
      Application_Name = var.your_application_name,
      Owner            = var.owner,
      Environment      = var.environment
    }
  )
}

module "nlb_tgt" {
  source            = "../modules/loadbalancer/target_group"
  enable            = var.enable
  lbARN             = module.nlb.arn
  vpc_id            = var.vpc_id
  enable_host_based = var.enable_host_based
  name_prefix       = var.name_prefix
  target_groups = [
    {
      name                 = "target-group-1-globe-nlb"
      backend_port         = 443
      backend_protocol     = "TCP"
      target_type          = "ip"
      deregistration_delay = 300
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
      }
      stickiness = {
        enabled         = true
        cookie_duration = 86400
        type            = "source_ip"
      }
    }
  ]
  targets = [
    {
      target_group_index = 0
      target_id          = []
      port               = 443
    }
  ]
  listeners = {
    nlb_listener = {
      port       = 443
      protocol   = "TCP"
      ssl_policy = "ELBSecurityPolicy-2016-08"
      authenticate_cognito = {
        authentication_request_extra_params = { param1 = "value1" }
        on_unauthenticated_request          = "deny"
        scope                               = "openid"
        session_cookie_name                 = "AWSELBAuthSessionCookie"
        session_timeout                     = "3600"
        user_pool_arn                       = "arn:aws:cognito-idp:us-west-2:123456789012:userpool/us-west-2_AbCdEfGhI"
        user_pool_client_id                 = "1234567890abcdefg"
        user_pool_domain                    = "mydomain"
      }
      default_action = {
        type               = "forward"
        target_group_index = 0
        port               = 80
        status_code        = "HTTP_301"
        protocol           = "#{protocol}"
      }
    }
  }
  listener_rule     = var.listener_rule
  networklbcreate   = var.networklbcreate
  acm_domain        = var.acm_domain
  certificate_type  = var.certificate_type
  enable_path_based = var.enable_path_based
  tags = merge(var.tags,
    {
      Application_Name = var.your_application_name,
      Owner            = var.owner,
      Environment      = var.environment
    }
  )
}


###### VPC ENDPOINTS ######

module "vpc_endpoints" {
  source              = "../modules/vpc_endpoint"
  vpc_id              = var.vpc_id
  region              = var.region
  service_name        = var.service_name
  vpc_endpoint_type   = var.vpc_endpoint_type
  security_group_ids  = [module.security_group.securitygroup_id]
  private_dns_enabled = var.private_dns_enabled
  ip_address_type     = var.ip_address_type
  subnet_ids          = var.subnet_ids
}

data "aws_network_interface" "nics" {
  count      = length(var.subnet_ids)
  id         = module.vpc_endpoints.network_ids[count.index]
  depends_on = [module.vpc_endpoints]
}

####### ROUTE 53 #######

module "zones" {
  source           = "../modules/route53/zones"
  vpc_id           = var.vpc_id
  hosted_zone_name = var.hosted_zone_name
}


module "records" {
  source                    = "../modules/route53/records"
  create                    = var.create
  failover_routing_policies = var.failover_routing_policies
  records = [
    {
      name = "restapi.searcesp.com"
      type = "A"
      routing_policy = {
        type = "alias"
        alias_target = {
          dns_name               = module.alb.dns_name
          hosted_zone_id         = module.alb.zone_id
          evaluate_target_health = false
        }
      }
    }
  ]
  zone_id = module.zones.zone_ids
}


######### SECURITY GROUPS #########

module "security_group" {
  source      = "../modules/security_groups"
  create      = var.create
  name        = var.sg_name
  vpc_id      = var.vpc_id
  description = var.sg_desc
  security_group_rules = [
    {
      description = "Allow SSH FROM INTERNAL VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      type        = "ingress"
      origin_type = "cidr_blocks"
      origins     = ["${data.aws_vpc.vpc_sg.cidr_block}"]
    },
    {
      description = "Allow SSH FROM INTERNAL VPC"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      type        = "ingress"
      origin_type = "cidr_blocks"
      origins     = ["${data.aws_vpc.vpc_sg.cidr_block}"]
    },
    {
      description = "Allow SSH FROM INTERNAL VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      type        = "ingress"
      origin_type = "cidr_blocks"
      origins     = ["${data.aws_vpc.vpc_sg.cidr_block}"]
    },
    {
      description = "Outbound all"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      type        = "egress"
      origin_type = "cidr_blocks"
      origins     = ["0.0.0.0/32"]
  }]

  sg_tags = {
    Name             = var.sg_name
    owner            = var.owner
    application_name = var.application_name
    environment      = var.environment
  }
}

data "aws_vpc" "vpc_sg" {
  id = var.vpc_id
}

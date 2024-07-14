###### LOAD BALANCER ########

name_prefix           = "globe-project"
your_application_name = "Globe"
vpc_id                = "vpc-064fac12ad5ee182f"
alb_subnets           = ["subnet-04d3ab8f6c890ace4", "subnet-0ff79d3add0d8f1bc"]
acm_domain            = "*.searcesp.com"
certificate_type      = ["AMAZON_ISSUED"]
security_groups       = ["sg-02120161afede72d4"]
networklbcreate       = false
enable_host_based     = false
enable_path_based     = false
enable                = true
internal              = true

######## Creating Target Groups ########

target_groups = [
  {
    name                 = "target-group-1-globe"
    backend_port         = 443
    backend_protocol     = "HTTPS"
    target_type          = "ip"
    deregistration_delay = 300
    slow_start           = 30
    health_check = {
      enabled             = true
      interval            = 30
      path                = "/"
      port                = "traffic-port"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      timeout             = 5
      protocol            = "HTTPS"
      matcher             = "403"
    }
    stickiness = {
      enabled         = true
      cookie_duration = 86400
      type            = "lb_cookie"
    }
  },
  {
    name                 = "target-group-2-globe"
    backend_port         = 80
    backend_protocol     = "HTTP"
    target_type          = "ip"
    deregistration_delay = 300
    slow_start           = 30
    health_check = {
      enabled             = true
      interval            = 30
      path                = "/"
      port                = "traffic-port"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      timeout             = 5
      protocol            = "HTTPS"
      matcher             = "403"
    }
    stickiness = {
      enabled         = true
      cookie_duration = 86400
      type            = "lb_cookie"
    }
  }
]

######### CREATE LISTENER ########

# listeners = {
#   listener_1 = {
#     port            = "443"
#     protocol        = "HTTP"
#     certificate_arn = "arn:aws:acm:ap-south-1:088585194665:certificate/d7205f54-a4ec-4db3-8d24-04a8580b41e8"
#     ssl_policy      = "ELBSecurityPolicy-2016-08"
#     default_action = {
#       target_group_index = 0
#       type               = "forward"
#       port               = 80
#       protocol           = "HTTP"
#       status_code        = "HTTP_301"
#     }
#   },
#   listener_2 = {
#     port     = "80"
#     protocol = "HTTP"
#     default_action = {
#       target_group_index = 0
#       type               = "redirect"
#       port               = 443
#       protocol           = "HTTPS"
#       status_code        = "HTTP_301"
#     }
#   }
# }


listener_ssl_policy_default = "ELBSecurityPolicy-2016-08"

########### LISTENER RULES (Only if custom routing rules are required, e.g. Host Header based or Path Based) ############

listener_rule = {
  rule1 = {
    name        = "rule1"
    priority    = 1
    path_values = ["/app1/*"]
    host_values = ["app4.exqamsssple.com"]
  }
  rule2 = {
    name        = "rule2"
    priority    = 2
    path_values = ["/dev/*"]
    host_values = ["app4.example.com"]
  }
}

#================== API GATEWAY ====================

AccountId      = "088585194665"
region         = "ap-south-1"
environment    = "dev"
project_name   = "project-globe-poc"
vpc_link_names = ["globe-project-poc-vpc_link"]

#####################   API Gateway Values ######################

enabled                  = true
name                     = "project-globe-poc-dev-tf"
description              = "Globe Project Dev Test - tf"
binary_media_types       = ["application/json"]
minimum_compression_size = -1
api_key_source           = "HEADER"
stage_enabled            = true
stage_name               = "Demo-Stage"

# ===== Api Gateway Resource ===== 

path_parts = ["GET"]
# path_parts               = ["{proxy+}", "enqueue", "notifications", "notify_order"]

# ===== Api Gateway Method ===== 

method_enabled   = true
http_methods     = ["GET"]
connection_types = ["VPC_LINK"]
# NLB ARN to be provided
target_arns = ["arn:aws:elasticloadbalancing:ap-south-1:088585194665:loadbalancer/net/globe-poc-nlb-test/c3fe8607e3ebddb8"]

# ===== Api Gateway Integration ===== 

integration_types        = ["HTTP"]
authorizations           = []
integration_http_methods = ["GET"]

# DNS name of the above specified NLB
uri = ["http://globe-poc-nlb-test-c3fe8607e3ebddb8.elb.ap-south-1.amazonaws.com"]

# integration_request_parameters = [
#   {
#     "integration.request.path.proxy" = "'method.request.path.proxy'"
#   },
#   {
#     "integration.request.path.proxy" = "'method.request.path.proxy'"
#   }
# ]

cache_key_parameters = []
cache_namespaces     = []
status_codes         = [200]



###### VPC ENDPOINTS ###########

service_name        = "com.amazonaws.ap-south-1.execute-api"
vpc_endpoint_type   = "Interface"
security_group_ids  = ["sg-02120161afede72d4"]
private_dns_enabled = true
ip_address_type     = "ipv4"
subnet_ids          = ["subnet-0ff79d3add0d8f1bc", "subnet-04d3ab8f6c890ace4"]

######### Route53 #########

create = true
zones = {
  "searcesp.com" = {
    comment = "Globe POC zone 1"
    tags = {
      Environment = "production"
    }
  }
}

hosted_zone_name = "searcesp.com"


####### SECURITY GROUPS #########

sg_name          = "Globe-POC-SG"
sg_desc          = "Private-sg"
owner            = "searce_hyd"
application_name = "GLOBE-POC"

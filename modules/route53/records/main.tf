locals {
  //records = try(jsondecode(var.records), var.records)
  records = {
    for x in var.records :
    format("%s", x.name) => x
  }


  recordsets = {
    for rs in local.records :
    join(" ", compact(["${rs.name} ${rs.type}", lookup(rs, "set_identifier", "")])) => merge(rs, {
      records = jsonencode(try(rs.records, null))
    })
  }
}


# data "aws_route53_zone" "selected" {
#   name         = var.zone_name
#   private_zone = false
# }


# resource "aws_route53_record" "route53_record" {
#   for_each                         = local.records
#   zone_id                          = var.zone_id
#   name                             = lookup(each.value, "name") != "" ? "${lookup(each.value, "name")}.${var.zone_name}" : var.zone_name
#   type                             = lookup(each.value, "type")
#   ttl                              = lookup(each.value, "ttl", null)
#   records                          = lookup(each.value, "records")
#   set_identifier                   = lookup(each.value, "set_identifier", null)
#   health_check_id                  = lookup(each.value, "health_check_id", null)
#   multivalue_answer_routing_policy = lookup(each.value, "multivalue_answer_routing_policy", null)
#   allow_overwrite                  = lookup(each.value, "allow_overwrite", null)


#   dynamic "alias" {
#     for_each = length(keys(lookup(each.value, "alias", {}))) == 0 ? [] : [true]


#     content {
#       name                   = each.value.alias.name
#       zone_id                = try(each.value.alias.zone_id, data.aws_route53_zone.selected[0].zone_id)
#       evaluate_target_health = lookup(each.value.alias, "evaluate_target_health", false)
#     }
#   }
#   dynamic "failover_routing_policy" {
#     for_each = var.failover_routing_policies

#     content {
#       type = failover_routing_policy.value.type

#       # Add other configuration parameters for failover routing policy if needed
#     }
#   }



#   dynamic "weighted_routing_policy" {
#     for_each = length(keys(lookup(each.value, "weighted_routing_policy", {}))) == 0 ? [] : [true]


#     content {
#       weight = each.value.weighted_routing_policy.weight
#     }
#   }


#   dynamic "geolocation_routing_policy" {
#     for_each = length(keys(lookup(each.value, "geolocation_routing_policy", {}))) == 0 ? [] : [true]


#     content {
#       continent   = lookup(each.value.geolocation_routing_policy, "continent", null)
#       country     = lookup(each.value.geolocation_routing_policy, "country", null)
#       subdivision = lookup(each.value.geolocation_routing_policy, "subdivision", null)
#     }
#   }


#   dynamic "latency_routing_policy" {
#     for_each = length(keys(lookup(each.value, "latency_routing_policy", {}))) == 0 ? [] : [true]


#     content {
#       region = each.value.latency_routing_policy.region
#     }
#   }
# }

resource "aws_route53_record" "route53_record" {
  for_each = { for idx, record in var.records : idx => record }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.routing_policy.type == "alias" ? null : each.value.ttl
  records = each.value.routing_policy.type == "alias" ? null : [each.value.value]

  set_identifier  = each.value.routing_policy.set_identifier
  health_check_id = each.value.routing_policy.type == "failover" ? each.value.routing_policy.health_check_id : null
  dynamic "alias" {
    for_each = each.value.routing_policy.type == "alias" ? [each.value.routing_policy.alias_target] : []

    content {
      name                   = each.value.routing_policy.alias_target.dns_name
      zone_id                = each.value.routing_policy.alias_target.hosted_zone_id
      evaluate_target_health = alias.value.evaluate_target_health != null ? alias.value.evaluate_target_health : false
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.routing_policy.type == "geolocation" ? [each.value.routing_policy.geolocation_routing_policy] : []

    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  dynamic "latency_routing_policy" {
    for_each = (each.value.routing_policy.type == "latency" && each.value.routing_policy.latency_routing_policy != null) ? [each.value.routing_policy.latency_routing_policy] : []

    content {
      region = latency_routing_policy.value.region
    }
  }


  dynamic "failover_routing_policy" {
    for_each = each.value.routing_policy.type == "failover" ? [each.value.routing_policy] : []

    content {
      type = failover_routing_policy.value.failover_type
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.routing_policy.type == "weighted" ? [each.value.routing_policy] : []

    content {
      weight = weighted_routing_policy.value.weight
    }
  }
}

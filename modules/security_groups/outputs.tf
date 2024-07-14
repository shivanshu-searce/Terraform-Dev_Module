
output "securitygroup_id" {
  value = join("", aws_security_group.sg.*.id)
}

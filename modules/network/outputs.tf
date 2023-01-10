output "security_group" {
    value = aws_security_group.restrict_instance.id
}

output "internal_subnet" {
    value = aws_subnet.subnets["subnet3"].id
}
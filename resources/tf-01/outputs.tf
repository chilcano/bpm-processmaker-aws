output "remote_fqdn" {
  value = aws_instance.my_instance.public_dns
}

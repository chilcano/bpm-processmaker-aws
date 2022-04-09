output "remotedesktop_fqdn" {
  value = aws_instance.remotedesktop.public_dns
}

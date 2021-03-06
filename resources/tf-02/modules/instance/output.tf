output "public_ips" {
  value       = aws_instance.main.*.public_ip
  description = "The public ips of the workstation"
}
output "unique_identifiers" {
  value = aws_instance.main.*.tags.Name
}
output "private_dns" {
  value       = aws_instance.main.*.private_dns
  description = "The private dns of the workstation"
}
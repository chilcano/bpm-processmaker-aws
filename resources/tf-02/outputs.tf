output "instances_workstation" {
  #value = module.dns_workstation.*.name    // If you use DNS
  value = module.workstation.*.public_ips   // If you use Public IP address
}

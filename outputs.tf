output "vpc" {
  description = "Azure VPC ID for the created VPC"
  value       = ""
}

output "bigip_mgmt_public_ips" {
  description = "Public IP addresses for the BIG-IP management interfaces"
  value       = ""
}

output "bigip_mgmt_port" {
  description = "BIG-IP management port"
  value       = ""
}

output "bigip_password" {
  description = "BIG-IP management password"
  value       = ""
}

output "nginx_ips" {
  description = "Internal IP addresses of the demo app servers"
  value       = ""
}
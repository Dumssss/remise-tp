# outputs.tf

output "public_ip_address" {
  value       = azurerm_public_ip.main.ip_address
  description = "The public IP address of the virtual machine."
}

output "vm_dns_name" {
  value       = azurerm_public_ip.main.fqdn
  description = "The DNS name of the virtual machine."
}
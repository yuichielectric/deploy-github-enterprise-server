output "public_ip" {
  value       = azurerm_public_ip.main.ip_address
  description = "The IP address of the GitHub Enterprise Server instance"
}

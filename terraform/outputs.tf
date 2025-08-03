output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL server"
  value       = module.sql.fqdn
  
}

output "appservice_url" {
  description = "The URL of the deployed App Service"
  value       = module.appservice.default_site_hostname
  
}

output "acr_login_server" {
  description = "The login server URL of the Azure Container Registry"
  value       = azurerm_container_registry.rtrain_acr.login_server
  
}

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

output "app_service_principal_id" {
  description = "The principal ID of the App Service"
  value       = module.appservice.app_service_principal_id
  
}

output "sql_database_name" {
  description = "SQL database name"
  value       = module.sql.database_name
}

# output "sql_principal_id" {
#   description = "The principal ID of the SQL server's system-assigned identity"
#   value       = module.sql.sql_principal_id
  
# }

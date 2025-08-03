output "default_site_hostname" {
  description = "The URL of the deployed App Service"
  value       = azurerm_linux_web_app.rtrain_app_service.default_site_hostname
  
}

output "app_service_principal_id" {
  description = "The principal ID of the App Service"
  value       = azurerm_linux_web_app.rtrain_app_service.identity[0].principal_id
  
}

output "app_service_id" {
  description = "value of the App Service ID"
  value       = azurerm_linux_web_app.rtrain_app_service.id
  
}

output "app_service_name" {
  description = "The name of the App Service"
  value       = azurerm_linux_web_app.rtrain_app_service.name
  
}

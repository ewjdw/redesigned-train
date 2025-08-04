output "fqdn" {
  description = "The fully qualified domain name of the SQL server"
  value       = azurerm_mssql_server.rtrain_sql_server.fully_qualified_domain_name
  
}

output "database_name" {
  description = "The name of the SQL database"
  value       = azurerm_mssql_database.rtrain_sql_database.name
  
}

output "sql_server_name" {
  description = "The ID of the SQL server"
  value       = azurerm_mssql_server.rtrain_sql_server.name
  
}

output "sql_principal_id" {
  description = "The principal ID of the SQL server's system-assigned identity"
  value       = azurerm_mssql_server.rtrain_sql_server.identity[0].principal_id
  
}

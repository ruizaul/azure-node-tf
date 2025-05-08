output "resource_group_id" {
  description = "ID del grupo de recursos"
  value       = azurerm_resource_group.main.id
}

output "webapp_url" {
  description = "URL de la aplicación web"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "sql_server_fqdn" {
  description = "Nombre de dominio completo del servidor SQL"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "database_name" {
  description = "Nombre de la base de datos SQL"
  value       = azurerm_mssql_database.main.name
}

output "sql_connection_string" {
  description = "Cadena de conexión a la base de datos SQL"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${azurerm_mssql_server.main.administrator_login};Password=${azurerm_mssql_server.main.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
} 
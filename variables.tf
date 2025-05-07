variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "api-recursos"
}

variable "location" {
  description = "Ubicación de los recursos de Azure"
  type        = string
  default     = "Canada Central"
}

variable "sql_server_name" {
  description = "Nombre del servidor SQL"
  type        = string
  default     = "servidor-sql-api"
}

variable "sql_database_name" {
  description = "Nombre de la base de datos SQL"
  type        = string
  default     = "api-database"
}

variable "sql_admin_username" {
  description = "Nombre de usuario del administrador SQL"
  type        = string
  default     = "adminuser"
}

variable "sql_admin_password" {
  description = "Contraseña del administrador SQL"
  type        = string
  default     = "P@ssw0rd1234!" # Cambiar en producción o usar variables de entorno
  sensitive   = true
} 
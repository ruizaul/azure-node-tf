variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  # Los valores se encuentran en terraform.tfvars
}

variable "location" {
  description = "Ubicación de los recursos de Azure"
  type        = string
  # Los valores se encuentran en terraform.tfvars
}

variable "sql_server_name" {
  description = "Nombre del servidor SQL"
  type        = string
  # Los valores se encuentran en terraform.tfvars
}

variable "sql_database_name" {
  description = "Nombre de la base de datos SQL"
  type        = string
  # Los valores se encuentran en terraform.tfvars
}

variable "sql_admin_username" {
  description = "Nombre de usuario del administrador SQL (solo necesario en la primera ejecución)"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "Contraseña del administrador SQL (solo necesario en la primera ejecución)"
  type        = string
  sensitive   = true
} 
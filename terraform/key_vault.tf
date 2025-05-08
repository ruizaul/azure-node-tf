# Obtener la configuración actual del cliente de Azure (para acceder a tenant_id y object_id)
data "azurerm_client_config" "current" {}

# Crear un Key Vault para almacenar secretos
resource "azurerm_key_vault" "main" {
  # Solo crear si el archivo marcador no existe
  count = fileexists("${path.module}/.keyvault_created") ? 0 : 1
  
  name                        = "kv-api-${random_string.suffix.result}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  # Política de acceso para el Service Principal que ejecuta Terraform
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Purge"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
  }
}

# Crear los secretos en Key Vault
resource "azurerm_key_vault_secret" "sql_admin_username" {
  # Solo crear si el archivo marcador no existe
  count = fileexists("${path.module}/.keyvault_created") ? 0 : 1
  
  name         = "sql-admin-username"
  value        = var.sql_admin_username
  key_vault_id = azurerm_key_vault.main[0].id
}

resource "azurerm_key_vault_secret" "sql_admin_password" {
  # Solo crear si el archivo marcador no existe
  count = fileexists("${path.module}/.keyvault_created") ? 0 : 1
  
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.main[0].id
}

# Crear un archivo local para marcar que el Key Vault ya fue creado
resource "local_file" "keyvault_created" {
  count = fileexists("${path.module}/.keyvault_created") ? 0 : 1
  
  filename = "${path.module}/.keyvault_created"
  content  = "Key Vault was created on ${timestamp()}"
  
  depends_on = [
    azurerm_key_vault.main,
    azurerm_key_vault_secret.sql_admin_username,
    azurerm_key_vault_secret.sql_admin_password
  ]
} 
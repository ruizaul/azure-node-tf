# Otorgar a la App Service acceso a los secretos del Key Vault
resource "azurerm_key_vault_access_policy" "webapp" {
  count = fileexists("${path.module}/.keyvault_created") ? 1 : 0
  
  key_vault_id = data.azurerm_key_vault.existing[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.main.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_linux_web_app.main
  ]
} 
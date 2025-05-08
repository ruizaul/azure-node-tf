terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Configuración del proveedor de Azure
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = "58d6e3f1-8dbd-4f6b-a645-654bb7589eb0"
}

# Obtener datos del Key Vault
data "azurerm_key_vault" "existing" {
  name                = "kv-api-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  
  # Solo intentar leer los datos del Key Vault si ya existe
  count = fileexists("${path.module}/.keyvault_created") ? 1 : 0
}

# Obtener secretos del Key Vault si ya existe
data "azurerm_key_vault_secret" "sql_username" {
  name         = "sql-admin-username"
  key_vault_id = data.azurerm_key_vault.existing[0].id
  
  # Solo intentar leer los datos del Key Vault si ya existe
  count = fileexists("${path.module}/.keyvault_created") ? 1 : 0
}

data "azurerm_key_vault_secret" "sql_password" {
  name         = "sql-admin-password"
  key_vault_id = data.azurerm_key_vault.existing[0].id
  
  # Solo intentar leer los datos del Key Vault si ya existe
  count = fileexists("${path.module}/.keyvault_created") ? 1 : 0
}

# Generar un sufijo aleatorio para nombres únicos (se debe hacer antes de usar el resultado)
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Crear un grupo de recursos
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Crear un servidor SQL
resource "azurerm_mssql_server" "main" {
  name                = var.sql_server_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  version             = "12.0"
  
  # Si el Key Vault ya existe, usar los secretos almacenados; de lo contrario, usar las variables
  administrator_login          = fileexists("${path.module}/.keyvault_created") ? data.azurerm_key_vault_secret.sql_username[0].value : var.sql_admin_username
  administrator_login_password = fileexists("${path.module}/.keyvault_created") ? data.azurerm_key_vault_secret.sql_password[0].value : var.sql_admin_password
}

# Crear una base de datos SQL
resource "azurerm_mssql_database" "main" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "Basic"
}

# Crear una regla de firewall para permitir todas las conexiones de Azure
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Crear un plan de servicio de App Service
resource "azurerm_service_plan" "main" {
  name                = "api-service-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Crear una App de servicio para la API
resource "azurerm_linux_web_app" "main" {
  name                = "api-webapp-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      node_version = "20-lts"
    }
    
    # Usar nuestro script de inicio en lugar del comando directo
    app_command_line = "bash ./scripts/startup.sh"
    
    # Configuración de contenedor 
    always_on                = true
    ftps_state               = "Disabled"
    health_check_path        = "/"
    health_check_eviction_time_in_min = 5
  }

  # Asignar identidad para que la aplicación pueda acceder al Key Vault
  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "~20-lts"
    "NODE_ENV"                     = "production"
    "PORT"                         = "8080"
    "DB_SERVER"                    = azurerm_mssql_server.main.fully_qualified_domain_name
    "DB_NAME"                      = azurerm_mssql_database.main.name
    "KEYVAULT_URI"                 = fileexists("${path.module}/.keyvault_created") ? data.azurerm_key_vault.existing[0].vault_uri : null
    
    # Credenciales de fallback
    "DB_USER"                      = var.sql_admin_username
    "DB_PASSWORD"                  = var.sql_admin_password
    
    # Configurar logs para depuración
    "WEBSITE_RUN_FROM_PACKAGE"     = "1"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=00000000-0000-0000-0000-000000000000"
    
    # Configuración para permitir identidad administrada
    "AZURE_CLIENT_ID"              = ""  # Se llenará automáticamente por la identidad administrada del sistema
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }
  
  # Configurar un tiempo de espera más largo para la sincronización de implementación
  logs {
    application_logs {
      file_system_level = "Information"
    }
    
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
} 
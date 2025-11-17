############################################################
# main.tf - Recursos Azure Function completos
# Naming convention: {project}-{environment}-{resource}
# Storage account: {project}{environment}funcst (sin guiones)
# Tags obligatorias: Environment, Owner, CostCenter, Project, ManagedBy, CreatedDate
# Seguridad: HTTPS obligatorio, TLS1.2 mínimo, sin acceso público blob
############################################################

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Storage Account (para funciones + logs destino diag settings)
resource "azurerm_storage_account" "funcsa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  account_kind             = var.storage_account_kind

  # HTTPS obligatorio y TLS mínimo
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  public_network_access_enabled = false

  tags = local.common_tags
}

# Application Insights
resource "azurerm_application_insights" "appi" {
  name                = local.app_insights_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = var.app_insights_application_type
  tags                = local.common_tags
}

# Service Plan Linux (consumption si Dynamic/Y1)
resource "azurerm_service_plan" "plan" {
  name                = local.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = var.plan_sku_tier == "Dynamic" ? "Y1" : var.plan_sku_size

  tags = local.common_tags
}

# Function App Linux
resource "azurerm_linux_function_app" "func" {
  name                        = local.function_app_name
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  service_plan_id             = azurerm_service_plan.plan.id
  storage_account_name        = azurerm_storage_account.funcsa.name
  storage_account_access_key  = azurerm_storage_account.funcsa.primary_access_key
  functions_extension_version = var.functions_extension_version
  https_only                  = true

  identity {
    type = var.function_app_identity_type
  }

  site_config {
    minimum_tls_version = "1.2"
    linux_fx_version    = var.linux_fx_version
    always_on           = var.always_on
  }

  app_settings = merge({
    FUNCTIONS_WORKER_RUNTIME              = var.runtime,
    AzureWebJobsStorage                   = azurerm_storage_account.funcsa.primary_connection_string,
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appi.connection_string,
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.appi.instrumentation_key,
    WEBSITE_RUN_FROM_PACKAGE              = ""
  }, var.app_settings_additional)

  tags = local.common_tags

  lifecycle {
    ignore_changes = [app_settings["WEBSITE_RUN_FROM_PACKAGE"]]
  }
}

# Diagnostic Settings -> envío logs a Storage Account
resource "azurerm_monitor_diagnostic_setting" "func_diag" {
  name               = "${local.function_app_name}-diag"
  target_resource_id = azurerm_linux_function_app.func.id
  storage_account_id = azurerm_storage_account.funcsa.id

  log {
    category = "AppServiceHTTPLogs"
    enabled  = var.enable_diag_http_logs
    retention_policy { enabled = false }
  }
  log {
    category = "AppServiceConsoleLogs"
    enabled  = var.enable_diag_console_logs
    retention_policy { enabled = false }
  }
  log {
    category = "AppServiceAppLogs"
    enabled  = var.enable_diag_app_logs
    retention_policy { enabled = false }
  }
  log {
    category = "AppServicePlatformLogs"
    enabled  = var.enable_diag_platform_logs
    retention_policy { enabled = false }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy { enabled = false }
  }
}

# Host Keys (referencia a la function app para obtener keys)
# Nota: Las keys se obtienen via Azure CLI o Portal en producción por seguridad

############################################################
# outputs.tf - Salidas principales del módulo
############################################################

output "resource_group_name" {
  description = "Nombre del Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "function_app_name" {
  description = "Nombre de la Function App"
  value       = azurerm_linux_function_app.func.name
}

output "function_app_hostname" {
  description = "Hostname por defecto de la Function App"
  value       = azurerm_linux_function_app.func.default_hostname
}

output "function_app_identity_principal_id" {
  description = "Principal ID de la identidad administrada"
  value       = azurerm_linux_function_app.func.identity[0].principal_id
}

output "function_app_identity_tenant_id" {
  description = "Tenant ID de la identidad administrada"
  value       = azurerm_linux_function_app.func.identity[0].tenant_id
}

output "storage_account_name" {
  description = "Nombre de la cuenta de almacenamiento"
  value       = azurerm_storage_account.funcsa.name
}

output "storage_account_primary_connection_string" {
  description = "Connection string primaria de la cuenta de almacenamiento"
  value       = azurerm_storage_account.funcsa.primary_connection_string
  sensitive   = true
}

output "app_insights_instrumentation_key" {
  description = "Instrumentation Key de Application Insights"
  value       = azurerm_application_insights.appi.instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "Connection string de Application Insights"
  value       = azurerm_application_insights.appi.connection_string
  sensitive   = true
}

output "function_master_key" {
  description = "Master host key de la Function App"
  value       = data.azurerm_function_app_host_keys.host_keys.master_key
  sensitive   = true
}

output "function_default_function_key" {
  description = "Default function key"
  value       = data.azurerm_function_app_host_keys.host_keys.default_function_key
  sensitive   = true
}

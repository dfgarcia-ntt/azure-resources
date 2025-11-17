#################################################################
# terraform.tfvars - Valores completos de ejemplo
# Ajusta según tu entorno antes de aplicar.
#################################################################

project                       = "myproj"
environment                   = "dev"
location                      = "westeurope"
runtime                       = "dotnet-isolated"
function_app_kind             = "functionapp"
plan_sku_tier                 = "Dynamic"
plan_sku_size                 = "Y1"
plan_reserved                 = true
storage_account_tier          = "Standard"
storage_account_replication   = "LRS"
storage_account_kind          = "StorageV2"
app_insights_application_type = "web"
functions_extension_version   = "~4"
always_on                     = false
enable_diag_http_logs         = true
enable_diag_console_logs      = true
enable_diag_app_logs          = true
enable_diag_platform_logs     = true
owner                         = "owner@example.com"
cost_center                   = "CC-1234"
managed_by                    = "terraform"
created_date                  = "2025-11-17"
function_app_identity_type    = "SystemAssigned"
linux_fx_version              = ""

# Tags extras opcionales
extra_tags = {
  Compliance = "internal"
}

# App settings adicionales
app_settings_additional = {
  CUSTOM_SETTING = "value"
}

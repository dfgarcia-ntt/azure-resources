############################################################
# variables.tf - Todas las variables parametrizadas
# REGLAS:
# - Ningún valor hardcodeado fuera de defaults razonables
# - Validaciones para tipos y formatos
# - Tags obligatorias expuestas individualmente
############################################################

variable "project" {
  description = "Nombre corto del proyecto (lowercase, sin espacios)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{2,30}$", var.project))
    error_message = "project debe usar solo a-z, 0-9 y guiones, 2-30 chars."
  }
}

variable "environment" {
  description = "Entorno: dev | stg | prod u otro estándar corto."
  type        = string
  validation {
    condition     = can(regex("^(dev|stg|prod|test|qa)$", var.environment))
    error_message = "environment debe ser uno de dev, stg, prod, test, qa."
  }
}

variable "location" {
  description = "Región de Azure (ej: westeurope, eastus)."
  type        = string
  validation {
    condition     = length(var.location) > 2
    error_message = "location debe ser una región Azure válida."
  }
}

variable "runtime" {
  description = "FUNCTIONS_WORKER_RUNTIME (dotnet, dotnet-isolated, node, python, java, powershell)."
  type        = string
  default     = "dotnet-isolated"
  validation {
    condition     = contains(["dotnet", "dotnet-isolated", "node", "python", "java", "powershell"], var.runtime)
    error_message = "runtime inválido. Usar uno soportado por Azure Functions."
  }
}

variable "function_app_kind" {
  description = "Tipo de Function App (normalmente 'functionapp')."
  type        = string
  default     = "functionapp"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.function_app_kind))
    error_message = "function_app_kind inválido."
  }
}

variable "plan_sku_tier" {
  description = "Tier del App Service Plan (Dynamic para consumo, Premium, etc)."
  type        = string
  default     = "Dynamic"
  validation {
    condition     = length(var.plan_sku_tier) > 0
    error_message = "plan_sku_tier no puede estar vacío."
  }
}

variable "plan_sku_size" {
  description = "SKU Size (Y1 para consumo, EP1, P1v3, etc)."
  type        = string
  default     = "Y1"
  validation {
    condition     = length(var.plan_sku_size) > 0
    error_message = "plan_sku_size no puede estar vacío."
  }
}

variable "plan_reserved" {
  description = "Plan Linux (true para Linux)."
  type        = bool
  default     = true
}

variable "storage_account_tier" {
  description = "Tier de la cuenta de almacenamiento: Standard o Premium."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "storage_account_tier debe ser Standard o Premium."
  }
}

variable "storage_account_replication" {
  description = "Tipo de replicación (LRS, GRS, RAGRS, ZRS)."
  type        = string
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.storage_account_replication)
    error_message = "storage_account_replication inválido."
  }
}

variable "storage_account_kind" {
  description = "Kind de la cuenta (StorageV2 recomendado)."
  type        = string
  default     = "StorageV2"
  validation {
    condition     = var.storage_account_kind == "StorageV2"
    error_message = "Usar StorageV2 para mejores características."
  }
}

variable "app_insights_application_type" {
  description = "Tipo de aplicación para Application Insights (web, other)."
  type        = string
  default     = "web"
  validation {
    condition     = contains(["web", "other"], var.app_insights_application_type)
    error_message = "app_insights_application_type debe ser web u other."
  }
}

variable "functions_extension_version" {
  description = "Versión de extension de Functions (ej: ~4)."
  type        = string
  default     = "~4"
  validation {
    condition     = can(regex("^~?[0-9]+$", var.functions_extension_version))
    error_message = "functions_extension_version inválida."
  }
}

variable "always_on" {
  description = "Mantener función siempre activa (false en consumo)."
  type        = bool
  default     = false
}

variable "enable_diag_http_logs" {
  description = "Habilita categoría AppServiceHTTPLogs en diagnostic settings."
  type        = bool
  default     = true
}

variable "enable_diag_console_logs" {
  description = "Habilita categoría AppServiceConsoleLogs en diagnostic settings."
  type        = bool
  default     = true
}

variable "enable_diag_app_logs" {
  description = "Habilita categoría AppServiceAppLogs en diagnostic settings."
  type        = bool
  default     = true
}

variable "enable_diag_platform_logs" {
  description = "Habilita categoría AppServicePlatformLogs en diagnostic settings."
  type        = bool
  default     = true
}

variable "owner" {
  description = "Propietario del recurso (correo o identificador)."
  type        = string
}

variable "cost_center" {
  description = "Centro de costo asociado."
  type        = string
}

variable "managed_by" {
  description = "Quién gestiona: normalmente 'terraform'."
  type        = string
  default     = "terraform"
}

variable "created_date" {
  description = "Fecha de creación (YYYY-MM-DD)."
  type        = string
  default     = "2025-11-17"
  validation {
    condition     = can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", var.created_date))
    error_message = "created_date debe tener formato YYYY-MM-DD."
  }
}

variable "extra_tags" {
  description = "Mapa opcional de tags adicionales."
  type        = map(string)
  default     = {}
}

variable "function_app_identity_type" {
  description = "Tipo de identidad administrada (SystemAssigned)."
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = var.function_app_identity_type == "SystemAssigned"
    error_message = "Solo se soporta SystemAssigned en este módulo."
  }
}

variable "linux_fx_version" {
  description = "Stack Linux FX (ej para dotnet-isolated no requerido, se puede dejar vacío)."
  type        = string
  default     = ""
}

variable "app_settings_additional" {
  description = "Mapa de app settings adicionales para la Function App."
  type        = map(string)
  default     = {}
}

############################################################
# Locales derivados
############################################################

locals {
  resource_group_name   = "${var.project}-${var.environment}-rg"
  storage_account_name  = lower(replace("${var.project}${var.environment}funcst", "-", ""))
  app_service_plan_name = "${var.project}-${var.environment}-plan"
  function_app_name     = "${var.project}-${var.environment}-func"
  app_insights_name     = "${var.project}-${var.environment}-appi"
  common_tags = merge({
    Environment = var.environment,
    Owner       = var.owner,
    CostCenter  = var.cost_center,
    Project     = var.project,
    ManagedBy   = var.managed_by,
    CreatedDate = var.created_date
  }, var.extra_tags)
}

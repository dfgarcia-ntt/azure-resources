# Azure Function Terraform Module

Módulo que provisiona una Azure Function (Linux) con:
- Resource Group
- Storage Account segura (HTTPS, TLS1.2, sin blob público)
- Application Insights
- App Service Plan (Linux, consumo por defecto)
- Azure Linux Function App con identidad administrada
- Diagnostic Settings enviando logs a la Storage Account

## Características
- Todas las configuraciones son variables (sin valores hardcodeados)
- Naming consistente: `{project}-{environment}-{resource}` excepto Storage: `{project}{environment}funcst`
- Tags obligatorias y extensibles
- Validaciones de variables para minimizar errores
- lifecycle ignore_changes para `WEBSITE_RUN_FROM_PACKAGE`

## Requisitos
- Terraform >= 1.5.0
- Provider azurerm ~> 3.80
- Autenticación Azure (Azure CLI login, Managed Identity o Service Principal)

## Archivos
| Archivo | Descripción |
|---------|-------------|
| versions.tf | Versionado Terraform y provider |
| variables.tf | Definición de todas las variables y locales |
| main.tf | Recursos principales |
| outputs.tf | Salidas esenciales |
| terraform.tfvars | Valores de ejemplo completos |
| README.md | Documentación del módulo |

## Variables
| Nombre | Tipo | Default | Descripción |
|--------|------|---------|-------------|
| project | string | - | Nombre corto del proyecto |
| environment | string | - | Entorno (dev, stg, prod, test, qa) |
| location | string | - | Región Azure |
| runtime | string | dotnet-isolated | FUNCTIONS_WORKER_RUNTIME |
| function_app_kind | string | functionapp | Kind de la Function App |
| plan_sku_tier | string | Dynamic | Tier plan (Dynamic/Y1 consumo) |
| plan_sku_size | string | Y1 | SKU size |
| plan_reserved | bool | true | Linux plan (true) |
| storage_account_tier | string | Standard | Tier Storage |
| storage_account_replication | string | LRS | Replicación |
| storage_account_kind | string | StorageV2 | Kind Storage |
| app_insights_application_type | string | web | Tipo Application Insights |
| functions_extension_version | string | ~4 | Versión runtime Functions |
| always_on | bool | false | Mantener siempre activo (consumo=false) |
| enable_diag_http_logs | bool | true | Logs HTTP |
| enable_diag_console_logs | bool | true | Logs consola |
| enable_diag_app_logs | bool | true | Logs aplicación |
| enable_diag_platform_logs | bool | true | Logs plataforma |
| owner | string | - | Propietario |
| cost_center | string | - | Centro de costo |
| managed_by | string | terraform | Gestor |
| created_date | string | 2025-11-17 | Fecha creación |
| function_app_identity_type | string | SystemAssigned | Identidad administrada |
| linux_fx_version | string | "" | Stack Linux FX opcional |
| extra_tags | map(string) | {} | Tags adicionales |
| app_settings_additional | map(string) | {} | App settings extra |

## Outputs
| Nombre | Descripción |
|--------|-------------|
| resource_group_name | RG creado |
| function_app_name | Nombre función |
| function_app_hostname | Hostname función |
| function_app_identity_principal_id | Principal ID identidad |
| function_app_identity_tenant_id | Tenant ID identidad |
| storage_account_name | Nombre Storage |
| storage_account_primary_connection_string | Connection string principal (sensible) |
| app_insights_instrumentation_key | Instrumentation Key (sensible) |
| app_insights_connection_string | Connection string AI (sensible) |
| function_master_key | Master key Functions (sensible) |
| function_default_function_key | Default function key (sensible) |

## Ejemplo de Uso
```hcl
module "az_function" {
  source = "./terraform/az-function"

  project      = "myproj"
  environment  = "dev"
  location     = "westeurope"
  runtime      = "dotnet-isolated"
  owner        = "owner@example.com"
  cost_center  = "CC-1234"

  extra_tags = {
    Compliance = "internal"
  }

  app_settings_additional = {
    CUSTOM_SETTING = "value"
  }
}
```

Aplicar:
```powershell
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Consideraciones de Seguridad
- Storage con HTTPS y TLS1.2 mínimo
- Bloqueo de acceso público a blobs (`allow_blob_public_access = false`)
- Identity SystemAssigned para evitar credenciales explícitas
- Application Insights habilitado para observabilidad
- Logs y métricas centralizados vía Diagnostic Settings

## Notas
- Ajusta `runtime` y `functions_extension_version` según la pila requerida.
- Para Premium, cambia `plan_sku_tier` y `plan_sku_size` (ej: tier="ElasticPremium" size="EP1").
- `WEBSITE_RUN_FROM_PACKAGE` ignorado en lifecycle para permitir despliegues externos.

## Próximos Pasos Opcionales
- Agregar Log Analytics Workspace y enviar diagnostics allí.
- Añadir alertas (Metric Alerts) para disponibilidad y errores.
- Configurar backend remoto de estado Terraform (storage separada). 

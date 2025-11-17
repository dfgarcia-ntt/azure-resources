# Prompt: Azure Function con Terraform (Variables en .tfvars)

Prompt optimizado para el agente **IaCExpert** que genera Azure Function completa con todas las variables en archivo `.tfvars`.

---

## 📝 Prompt Básico

```
Crea una estructura completa de Terraform para Azure Function en Azure.

ESPECIFICACIÓN:
- Todos los valores configurables deben ser variables (NO valores hardcodeados)
- Variables se definirán en terraform.tfvars, NO en el prompt
- Runtime: configurable via variable
- Plan: configurable via variable  
- Región: configurable via variable

RECURSOS A CREAR:
- Resource Group
- Storage Account (segura: HTTPS only, sin acceso público)
- Application Insights
- App Service Plan (Linux)
- Azure Function App (Linux)
- Diagnostic Settings

ARCHIVOS REQUERIDOS:

1. versions.tf (Terraform >= 1.5.0, azurerm ~> 3.80)
2. variables.tf (TODAS las variables con validaciones y defaults)
3. main.tf (recursos + naming convention + tags)
4. outputs.tf (nombre, hostname, identity, keys, etc)
5. terraform.tfvars (archivo COMPLETO con todos los valores)
6. README.md (documentación + tabla de variables)

CONFIGURACIÓN OBLIGATORIA:
- Naming: {project}-{environment}-{resource}
- Storage: {project}{env}funcst (sin guiones)
- HTTPS obligatorio, TLS 1.2 mínimo
- Managed Identity habilitada
- Tags: Environment, Owner, CostCenter, Project, ManagedBy, CreatedDate
- lifecycle ignore_changes para WEBSITE_RUN_FROM_PACKAGE

RESTRICCIONES:
- NO usar enable_https_traffic_only (obsoleto)
- NO usar bloques dynamic complejos
- SÍ usar https_traffic_only_enabled = true
- Todas las configuraciones deben ser variables

RESULTADO: Estructura lista para terraform init && terraform apply -var-file="terraform.tfvars"
```

---

## 🎯 Uso del Prompt

1. Copia el prompt completo
2. Pégalo al agente IaCExpert  
3. El agente generará 6 archivos listos
4. Ajusta valores en `terraform.tfvars`
5. Ejecuta: `terraform apply -var-file="terraform.tfvars"`

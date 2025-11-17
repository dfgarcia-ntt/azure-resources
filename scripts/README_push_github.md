# Script: push_github.ps1

Sube el contenido de un directorio local a un repositorio GitHub usando la REST API sin comandos `git`.

## Requisitos
1. Token GitHub con scope `repo` (exportado como variable de entorno `GITHUB_TOKEN` o pasado como parámetro `-Token`).
2. PowerShell 5.1+.
3. Conectividad HTTPS hacia `api.github.com`.

## Parámetros
| Parámetro | Obligatorio | Descripción |
|-----------|------------|-------------|
| `Owner` | Sí | Usuario u organización destino |
| `Repo` | Sí | Nombre del repositorio destino |
| `Private` | No (true) | Crear repo privado si no existe |
| `Description` | No | Descripción repo si se crea |
| `Branch` | No (main) | Rama destino de los commits |
| `SourceDir` | Sí | Directorio local cuyos archivos se subirán |
| `Token` | No | PAT, si no se usa toma `$Env:GITHUB_TOKEN` |

## Ejemplo de Uso
```powershell
# 1. Definir token (o usar existente)
$Env:GITHUB_TOKEN = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# 2. Ejecutar script (usuario)
./scripts/push_github.ps1 -Owner miusuario -Repo azfunction-terraform -Private $true -SourceDir "c:/src/PROJECTS/azfunction-mcp/terraform/az-function"

# 3. Ejecutar script (organización)
./scripts/push_github.ps1 -Owner mi-organizacion -Repo azfunction-terraform -Private $true -SourceDir "c:/src/PROJECTS/azfunction-mcp/terraform/az-function"
```

## Notas
- Si el repositorio ya existe, no se modifica visibilidad ni descripción.
- Si no existe, el script intenta primero crear repo para usuario (`/user/repos`) y si falla crea para organización (`/orgs/{org}/repos`).
- Cada archivo genera un commit independiente (puede ser más lento en grandes volúmenes).
- Para grandes cargas se recomienda clonar y hacer un push tradicional.

## Errores Comunes
| Error | Causa | Solución |
|-------|-------|----------|
| 401 Unauthorized | Token inválido o sin scope | Generar nuevo PAT con scope `repo` |
| 404 Not Found (al crear org) | Organización no existe o permisos insuficientes | Verificar nombre y permisos del token |
| Rate limit | Demasiadas peticiones | Reintentar luego o usar git normal |

## Próximos Pasos Opcionales
- Mejorar script para crear un solo commit usando el Git Data API (trees + blobs).
- Añadir exclusiones por patrón (ej: `.gitignore` lógica).
- Añadir confirmación interactiva antes de subir.

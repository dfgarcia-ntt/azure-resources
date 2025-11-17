<#!
.SYNOPSIS
  Crea (si es necesario) un repositorio en GitHub y sube archivos usando la GitHub REST API (Contents API) sin usar git.

.DESCRIPTION
  Recorre un directorio local, codifica cada archivo en Base64 y realiza llamadas PUT a
  https://api.github.com/repos/{owner}/{repo}/contents/{path}. Si el repositorio no existe lo crea.

.PARAMETER Owner
  Usuario u organización destino.

.PARAMETER Repo
  Nombre del repositorio destino.

.PARAMETER Private
  Indica si el repositorio debe ser privado (solo al crearlo).

.PARAMETER Description
  Descripción opcional del repositorio (solo creación).

.PARAMETER Branch
  Rama destino (por defecto main). Si el repo se crea se inicializa en esa rama.

.PARAMETER SourceDir
  Directorio local cuyas fuentes se subirán (recursivo).

.PARAMETER Token
  Personal Access Token (si no se pasa se toma de $Env:GITHUB_TOKEN). Debe tener scopes: repo.

.NOTES
  Usa API v3. Para organizaciones POST a /orgs/{org}/repos; para usuarios /user/repos.
  Subida individual genera un commit por archivo (puede ser más lenta). Para lotes grandes,
  conviene usar git normal.

.EXAMPLE
  $Env:GITHUB_TOKEN = "ghp_xxxxx";
  ./push_github.ps1 -Owner myuser -Repo azfunction-terraform -Private $true -SourceDir "c:/src/PROJECTS/azfunction-mcp/terraform/az-function"

#>
param(
  [Parameter(Mandatory=$true)][string]$Owner,
  [Parameter(Mandatory=$true)][string]$Repo,
  [Parameter()][bool]$Private = $true,
  [Parameter()][string]$Description = "Azure Function Terraform module",
  [Parameter()][string]$Branch = "main",
  [Parameter(Mandatory=$true)][string]$SourceDir,
  [Parameter()][string]$Token
)

if (-not $Token) { $Token = $Env:GITHUB_TOKEN }
if (-not $Token) { throw "Debe definir -Token o variable de entorno GITHUB_TOKEN" }

$baseApi = "https://api.github.com"
$headers = @{ 
  Authorization = "Bearer $Token";
  Accept       = "application/vnd.github+json";
  "User-Agent" = "terraform-upload-script";
}

function Test-RepoExists {
  param([string]$Owner,[string]$Repo)
  $url = "$baseApi/repos/$Owner/$Repo"
  try {
    $r = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop
    return $true
  } catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 404) { return $false } else { throw }
  }
}

function New-GitHubRepo {
  param([string]$Owner,[string]$Repo,[bool]$Private,[string]$Description)
  # Determinar tipo (User u Organization) para elegir endpoint correcto
  $ownerInfo = Invoke-RestMethod -Method GET -Uri "$baseApi/users/$Owner" -Headers $headers -ErrorAction Stop
  $isOrg = ($ownerInfo.type -eq 'Organization')
  $bodyObj = @{ name = $Repo; description = $Description; private = $Private; auto_init = $true }
  $body = $bodyObj | ConvertTo-Json
  if ($isOrg) {
    Write-Host "[INFO] Owner es Organization. Creando repo en organización..."
    $resp = Invoke-RestMethod -Method POST -Uri "$baseApi/orgs/$Owner/repos" -Headers $headers -Body $body -ErrorAction Stop
  } else {
    Write-Host "[INFO] Owner es User. Creando repo en cuenta de usuario..."
    $resp = Invoke-RestMethod -Method POST -Uri "$baseApi/user/repos" -Headers $headers -Body $body -ErrorAction Stop
  }
  return $resp
}

Write-Host "[INFO] Verificando existencia del repositorio $Owner/$Repo ..."
$exists = Test-RepoExists -Owner $Owner -Repo $Repo
if (-not $exists) {
  Write-Host "[INFO] Repositorio no existe. Creando..."
  try {
    New-GitHubRepo -Owner $Owner -Repo $Repo -Private $Private -Description $Description | Out-Null
    # Re-verificar
    if (Test-RepoExists -Owner $Owner -Repo $Repo) {
      Write-Host "[INFO] Repositorio creado exitosamente."
    } else {
      throw "Creación reportó éxito pero el repositorio no se encuentra via GET. Abortando."
    }
  } catch {
    throw "Error creando repositorio: $($_.Exception.Message)"
  }
} else {
  Write-Host "[INFO] Repositorio ya existe. Se usarán subidas directas."; 
}

# Verificar branch (si no existe se crea con primer commit). Contents API crea blob + commit.

if (-not (Test-Path $SourceDir)) { throw "SourceDir '$SourceDir' no existe" }

$files = Get-ChildItem -Path $SourceDir -File -Recurse
if ($files.Count -eq 0) { throw "No se encontraron archivos en $SourceDir" }

Write-Host "[INFO] Subiendo $($files.Count) archivos al repositorio..."
$success = 0; $failed = 0

foreach ($f in $files) {
  $relPath = ($f.FullName).Substring($SourceDir.Length).TrimStart('\','/')
  # Normalizar a rutas con /
  $relPath = ($relPath -replace "\\","/")
  $content = Get-Content -Raw -Path $f.FullName
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
  $b64 = [Convert]::ToBase64String($bytes)
  $message = "Add $relPath"
  $putBody = @{ message = $message; content = $b64; branch = $Branch } | ConvertTo-Json
  $url = "$baseApi/repos/$Owner/$Repo/contents/$relPath"
  try {
    Invoke-RestMethod -Method PUT -Uri $url -Headers $headers -Body $putBody -ErrorAction Stop | Out-Null
    $success++
    Write-Host "[OK] $relPath"
  } catch {
    $failed++
    Write-Warning "[FAIL] $relPath -> $($_.Exception.Message)"
  }
}

Write-Host "[INFO] Proceso terminado. Éxitos: $success - Fallos: $failed"
if ($failed -gt 0) { Write-Warning "Algunos archivos fallaron. Revise mensajes anteriores." }

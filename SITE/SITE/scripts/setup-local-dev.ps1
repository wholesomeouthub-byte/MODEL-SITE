<#
Automated local dev setup for Windows XAMPP environment.
- Modes: Copy or Link
- Source (default): C:\Users\User\Documents\MODEL\SITE
- Destination (default): C:\xampp\htdocs\NEWS-SITE
#>

Param(
  [ValidateSet("Copy","Link")]
  [string]$Mode = "Copy"
)

$srcRoot = "C:\Users\User\Documents\MODEL\SITE"
$destRoot = "C:\xampp\htdocs\NEWS-SITE"

Write-Host "Source: $srcRoot"
Write-Host "Destination: $destRoot"
Write-Host "Mode: $Mode"

# Ensure destination parent exists
$destParent = Split-Path $destRoot -Parent
if (-not (Test-Path $destParent)) { New-Item -ItemType Directory -Path $destParent -Force | Out-Null }

switch ($Mode) {
  "Copy" {
    if (-not (Test-Path $srcRoot)) { Write-Host "[ERROR] Source not found: $srcRoot"; exit 1 }
    if (-not (Test-Path $destRoot)) { New-Item -ItemType Directory -Path $destRoot -Force | Out-Null }
    Write-Host "[INFO] Copying content..."
    robocopy "$srcRoot" "$destRoot" /MIR /XD ".git" > $null
    Write-Host "[INFO] Copy finished. Check $destRoot"
  }
  "Link" {
    if (-not (Test-Path $srcRoot)) { Write-Host "[ERROR] Source not found: $srcRoot"; exit 1 }
    if (Test-Path $destRoot) { Write-Host "[WARN] Destination exists. Skipping link creation."; break }
    Write-Host "[INFO] Creating junction..."
    New-Item -ItemType Junction -Path "$destRoot" -Target "$srcRoot" | Out-Null
    Write-Host "[INFO] Junction created. Now NEWS-SITE is accessible via $destRoot"
  }
}

Write-Host "Next steps: Ensure Apache is running in XAMPP Control Panel. If using a VirtualHost, ensure it points to NEWS-SITE accordingly."

<#
Automated local dev setup for Windows XAMPP environment.
- Modes: Copy or Link
- Source (default): C:\Users\User\Documents\MODEL\SITE
- Destination (default): C:\xampp\htdocs\NEWS-SITE
#>

Param(
  [ValidateSet("Copy","Link")]
  [string]$Mode = "Copy",
  [switch]$ApplyConfig
)

$srcRoot = "C:\Users\User\Documents\MODEL\SITE"
$destRoot = "C:\xampp\htdocs\NEWS-SITE"

Write-Host "Source: $srcRoot"
Write-Host "Destination: $destRoot"
Write-Host "Mode: $Mode"

# Ensure destination parent exists
-$destParent = Split-Path $destRoot -Parent
-if (-not (Test-Path $destParent)) { New-Item -ItemType Directory -Path $destParent -Force | Out-Null }

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
 
# Optional configuration steps
if ($ApplyConfig.IsPresent) {
  Write-Host "[CONFIG] Applying VirtualHost and hosts configuration..."
  # 2) Add hosts entry
  $hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
  if (Test-Path $hostsFile) {
    if (-not (Select-String -Path $hostsFile -Pattern "news-site.local" -Quiet)) {
      "127.0.0.1 news-site.local" | Add-Content $hostsFile
      Write-Host "[CONFIG] Hosts entry added: news-site.local -> 127.0.0.1"
    } else {
      Write-Host "[CONFIG] Hosts entry already exists for news-site.local"
    }
  } else {
    Write-Warning "Hosts file not found at $hostsFile"
  }

  # 3) Add virtual host entry
  $vhConf = "C:\\xampp\\apache\\conf\\extra\\httpd-vhosts.conf"
  if (Test-Path $vhConf) {
    if (-not (Select-String -Path $vhConf -Pattern "news-site.local" -Quiet)) {
      $vhBlock = @"
<VirtualHost *:80>
  ServerName news-site.local
  DocumentRoot "{0}"
  <Directory "{0}">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
"@ -f $destRoot
      Add-Content $vhConf $vhBlock
      Write-Host "[CONFIG] VirtualHost added for news-site.local pointing to $destRoot"
    } else {
      Write-Host "[CONFIG] VirtualHost entry already exists in httpd-vhosts.conf"
    }
  } else {
    Write-Warning "httpd-vhosts.conf not found at $vhConf"
  }
  Write-Host "[CONFIG] NOTE: You must restart Apache for changes to take effect."
}

# 4) Run health check
Write-Host "[INFO] Running local health check..."
& '.\SITE\scripts\check-local-project.ps1'

Write-Host "Next steps: Ensure Apache is running in XAMPP Control Panel. If using a VirtualHost, ensure it points to NEWS-SITE accordingly."

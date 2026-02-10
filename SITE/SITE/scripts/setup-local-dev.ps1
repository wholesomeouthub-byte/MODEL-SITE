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
$destParent = Split-Path $destRoot -Parent
if (-not (Test-Path $destParent)) { 
    try {
        New-Item -ItemType Directory -Path $destParent -Force | Out-Null
        Write-Host "[INFO] Created parent directory: $destParent"
    } catch {
        Write-Host "[ERROR] Failed to create parent directory: $_"
        exit 1
    }
}

switch ($Mode) {
  "Copy" {
    if (-not (Test-Path $srcRoot)) { 
        Write-Host "[ERROR] Source not found: $srcRoot"
        exit 1 
    }
    if (-not (Test-Path $destRoot)) { 
        try {
            New-Item -ItemType Directory -Path $destRoot -Force | Out-Null
            Write-Host "[INFO] Created destination directory: $destRoot"
        } catch {
            Write-Host "[ERROR] Failed to create destination directory: $_"
            exit 1
        }
    }
    Write-Host "[INFO] Copying content..."
    try {
        robocopy "$srcRoot" "$destRoot" /MIR /XD ".git" > $null
        Write-Host "[INFO] Copy finished. Check $destRoot"
    } catch {
        Write-Host "[ERROR] Copy operation failed: $_"
        exit 1
    }
  }
  "Link" {
    if (-not (Test-Path $srcRoot)) { 
        Write-Host "[ERROR] Source not found: $srcRoot"
        exit 1 
    }
    if (Test-Path $destRoot) { 
        Write-Host "[WARN] Destination exists. Skipping link creation."
        break 
    }
    Write-Host "[INFO] Creating junction..."
    try {
        New-Item -ItemType Junction -Path "$destRoot" -Target "$srcRoot" | Out-Null
        Write-Host "[INFO] Junction created. Now NEWS-SITE is accessible via $destRoot"
    } catch {
        Write-Host "[ERROR] Failed to create junction: $_"
        exit 1
    }
  }
}
 
# Optional configuration steps
if ($ApplyConfig.IsPresent) {
  Write-Host "[CONFIG] Applying VirtualHost and hosts configuration..."
  
  # Add hosts entry
  $hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
  if (Test-Path $hostsFile) {
    try {
        if (-not (Select-String -Path $hostsFile -Pattern "news-site.local" -Quiet)) {
            "127.0.0.1 news-site.local" | Add-Content $hostsFile
            Write-Host "[CONFIG] Hosts entry added: news-site.local -> 127.0.0.1"
        } else {
            Write-Host "[CONFIG] Hosts entry already exists for news-site.local"
        }
    } catch {
        Write-Host "[WARN] Failed to modify hosts file: $_"
    }
  } else {
    Write-Warning "Hosts file not found at $hostsFile"
  }

  # Add virtual host entry
  $vhConf = "C:\\xampp\\apache\\conf\\extra\\httpd-vhosts.conf"
  if (Test-Path $vhConf) {
    try {
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
    } catch {
        Write-Host "[WARN] Failed to modify virtual host configuration: $_"
    }
  } else {
    Write-Warning "httpd-vhosts.conf not found at $vhConf"
  }
  Write-Host "[CONFIG] NOTE: You must restart Apache for changes to take effect."
}

# Run health check with improved path resolution
Write-Host "[INFO] Running local health check..."
try {
    $scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
    $healthCheckScript = Join-Path $scriptDir "check-local-project.ps1"
    if (Test-Path $healthCheckScript) {
        & $healthCheckScript
    } else {
        Write-Host "[WARN] Health check script not found at: $healthCheckScript"
    }
} catch {
    Write-Host "[ERROR] Health check execution failed: $_"
}

Write-Host "Setup completed successfully!"
Write-Host "Next steps: Ensure Apache is running in XAMPP Control Panel. If using a VirtualHost, ensure it points to NEWS-SITE accordingly."
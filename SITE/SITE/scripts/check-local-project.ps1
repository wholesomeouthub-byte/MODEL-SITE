<#
Automatic local project health check for XAMPP-based PHP site.
- Assumes XAMPP is installed under C:\xampp and the project is under C:\xampp\htdocs\NEWS-SITE
- Performs basic checks: XAMPP presence, Apache service, HTTP accessibility, PHP binary, and DB config hints.
#>

$report = @()

function Add-Line([string]$line) { $report += $line }

# 1) Check XAMPP installation
$xamppRoot = "C:\\xampp"
if (Test-Path $xamppRoot) {
  Add-Line "[OK] XAMPP directory found: $xamppRoot"
} else {
  Add-Line "[WARN] XAMPP directory not found at $xamppRoot"
}

# 2) Check Apache executable/service
try {
  $apacheService = Get-Service -Name Apache* -ErrorAction SilentlyContinue
  if ($null -ne $apacheService) {
    Add-Line "[OK] Apache service found: $($apacheService.DisplayName) - Status: $($apacheService.Status)"
  } else {
    Add-Line "[WARN] Apache service not found (may need to start from XAMPP Control Panel)"
  }
} catch {
  Add-Line "[WARN] Unable to query Apache service: $_"
}

# 3) Test HTTP access to NEWS-SITE
try {
  $url = "http://localhost/NEWS-SITE/"
  $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
  if ($resp.StatusCode -eq 200) {
    Add-Line "[OK] HTTP GET $url returned 200"
  } else {
    Add-Line "[WARN] HTTP GET $url returned $($resp.StatusCode)"
  }
} catch {
  Add-Line "[ERROR] HTTP GET $url failed: $_"
}

# 4) PHP version check
try {
  $phpExe = Join-Path $xamppRoot "php\php.exe"
  if (Test-Path $phpExe) {
    $ver = & "$phpExe" -v 2>&1 | Select-Object -First 1
    Add-Line "[OK] PHP found: $ver"
  } else {
    Add-Line "[WARN] PHP executable not found at $phpExe"
  }
} catch {
  Add-Line "[ERROR] PHP check failed: $_"
}

# 5) DB config hints (optional)
$siteRoot = Join-Path $xamppRoot "htdocs\NEWS-SITE"
try {
  if (Test-Path $siteRoot) {
    $phpFiles = Get-ChildItem -Path $siteRoot -Recurse -Filter *.php -ErrorAction SilentlyContinue
    if ($phpFiles) {
      $matches = $phpFiles | Select-String -Pattern "DB_HOST|DB_NAME|mysqli_connect|PDO|pdo" -List
      if ($matches) {
        Add-Line "[INFO] DB hints detected in PHP files (DB_HOST/DB_NAME or mysqli/pdo usage)"
      } else {
        Add-Line "[INFO] No DB configuration hints found in PHP files"
      }
    }
  }
} catch {
  Add-Line "[WARN] DB config scan failed: $_"
}

# 6) Write report
$log = Join-Path $siteRoot "health_check_report.txt"
$report | Out-File -FilePath $log -Encoding utf8
Write-Host "Health check report written to: $log" -ForegroundColor Green

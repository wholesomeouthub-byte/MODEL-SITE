<#
Automatic local project health check for XAMPP-based PHP site.
- Assumes XAMPP is installed under C:\xampp and the project is under C:\xampp\htdocs\NEWS-SITE
- Performs basic checks: XAMPP presence, Apache service, HTTP accessibility, PHP binary, and DB config hints.
#>

param(
    [string]$SiteName = "NEWS-SITE"
)

$report = @()
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Add-Line([string]$line) { 
    $report += "[$timestamp] $line" 
}

# Detect current script location for more accurate path resolution
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$projectRoot = Split-Path $scriptDir -Parent

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
    Add-Line "[WARN] Unable to query Apache service: $($_.Exception.Message)"
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
    Add-Line "[ERROR] HTTP GET $url failed: $($_.Exception.Message)"
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
    Add-Line "[ERROR] PHP check failed: $($_.Exception.Message)"
}

# 5) Check project files existence
$siteRoot = Join-Path $xamppRoot "htdocs\$SiteName"
Add-Line "[INFO] Checking project files at: $siteRoot"

try {
    if (Test-Path $siteRoot) {
        Add-Line "[OK] Site directory exists: $siteRoot"
        
        # Check for essential files
        $essentialFiles = @("index.php", "functions.php", "header.php", "footer.php")
        foreach ($file in $essentialFiles) {
            $filePath = Join-Path $siteRoot $file
            if (Test-Path $filePath) {
                Add-Line "[OK] Found essential file: $file"
            } else {
                Add-Line "[WARN] Missing essential file: $file"
            }
        }
        
        # DB config hints (optional)
        $phpFiles = Get-ChildItem -Path $siteRoot -Recurse -Filter *.php -ErrorAction SilentlyContinue
        if ($phpFiles) {
            $dbMatches = $phpFiles | Select-String -Pattern "DB_HOST|DB_NAME|mysqli_connect|PDO|pdo" -List
            if ($dbMatches) {
                Add-Line "[INFO] DB configuration hints detected in PHP files"
            } else {
                Add-Line "[INFO] No DB configuration hints found in PHP files"
            }
        }
    } else {
        Add-Line "[ERROR] Site directory does not exist: $siteRoot"
        Add-Line "[INFO] Current project location: $projectRoot"
    }
} catch {
    Add-Line "[WARN] Project file check failed: $($_.Exception.Message)"
}

# 6) Write comprehensive report
try {
    $logFileName = "health_check_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $logPath = Join-Path $projectRoot $logFileName
    
    if (-not (Test-Path $projectRoot)) {
        # Fallback to desktop if project root doesn't exist
        $logPath = Join-Path $env:USERPROFILE "Desktop\$logFileName"
    }
    
    $report | Out-File -FilePath $logPath -Encoding utf8
    Write-Host "Health check report written to: $logPath" -ForegroundColor Green
} catch {
    Write-Host "Failed to write report file: $($_.Exception.Message)" -ForegroundColor Red
}

# Display summary
Write-Host "`n=== HEALTH CHECK SUMMARY ===" -ForegroundColor Cyan
foreach ($line in $report) {
    if ($line -match "\[ERROR\]") {
        Write-Host $line -ForegroundColor Red
    } elseif ($line -match "\[WARN\]") {
        Write-Host $line -ForegroundColor Yellow
    } elseif ($line -match "\[OK\]") {
        Write-Host $line -ForegroundColor Green
    } else {
        Write-Host $line -ForegroundColor White
    }
}
Write-Host "============================`n" -ForegroundColor Cyan

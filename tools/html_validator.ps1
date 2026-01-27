param(
    [string]$Path = "GGG.html"
)

function Read-FileContent($p){ Get-Content -Raw -Encoding UTF8 -Path $p }

$html = Read-FileContent $Path

if (-not $html) { Write-Output "File empty or not found: $Path"; exit 2 }

$issues = @()

if ($html.ToLower() -notmatch '<!doctype') { $issues += 'Missing DOCTYPE' }

# strip script/style
$cleaned = [regex]::Replace($html, '<script[\s\S]*?<\/script>', '<script></script>', 'IgnoreCase')
$cleaned = [regex]::Replace($cleaned, '<style[\s\S]*?<\/style>', '<style></style>', 'IgnoreCase')

$pattern = '<\s*(\/)?\s*([a-zA-Z0-9:-]+)([^>]*)>'
$matches = [regex]::Matches($cleaned, $pattern)

$void = @('area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr')
$stack = New-Object System.Collections.ArrayList

foreach ($m in $matches){
    $closing = $m.Groups[1].Value
    $tag = $m.Groups[2].Value.ToLower()
    $attr = $m.Groups[3].Value
    $pos = $m.Index
    if ($closing){
        if ($stack.Count -gt 0 -and $stack[$stack.Count-1] -eq $tag){ $stack.RemoveAt($stack.Count-1) }
        else {
            if ($stack -contains $tag){
                while ($stack.Count -gt 0 -and $stack[$stack.Count-1] -ne $tag){
                    $un = $stack[$stack.Count-1]; $stack.RemoveAt($stack.Count-1); $issues += "Unclosed tag <$un> before closing </$tag> at pos $pos"
                }
                if ($stack.Count -gt 0 -and $stack[$stack.Count-1] -eq $tag){ $stack.RemoveAt($stack.Count-1) }
            } else {
                $issues += "Unmatched closing tag </$tag> at pos $pos"
            }
        }
    } else {
        if ($void -contains $tag -or $attr.TrimEnd().EndsWith('/')){ continue }
        $stack.Add($tag) | Out-Null
    }
}

for ($i = $stack.Count - 1; $i -ge 0; $i--){ $issues += "Unclosed tag <$($stack[$i])>" }

# duplicate ids
$ids = [regex]::Matches($html, 'id\s*=\s*"([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
$dups = $ids | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name }
if ($dups.Count -gt 0){ $issues += 'Duplicate id(s): ' + ($dups -join ', ') }

# imgs without alt
$imgMatches = [regex]::Matches($html, '<img([^>]+)>', 'IgnoreCase')
$missing = @()
for ($i=0; $i -lt $imgMatches.Count; $i++){
    $attrs = $imgMatches[$i].Groups[1].Value
    if (-not ($attrs -match '\salt\s*=\s*"')){ $missing += ($i+1) }
}
if ($missing.Count -gt 0){ $issues += "$($missing.Count) <img> tag(s) missing alt attribute (indices: $($missing[0..([math]::Min(4,$missing.Count-1))] -join ', '))" }

# check addToCart
if ($html -match 'addToCart\s*\(' -and -not ($html -match 'function\s+addToCart\s*\(|const\s+addToCart\s*=|let\s+addToCart\s*=')){
    $issues += '`addToCart` is referenced but no definition found'
}

if ($issues.Count -gt 0){
    Write-Output 'Validation issues found:'
    $issues | ForEach-Object { Write-Output ('- ' + $_) }
    exit 2
} else {
    Write-Output 'No obvious HTML structural issues detected.'
    exit 0
}

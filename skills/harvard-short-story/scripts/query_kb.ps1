param([string]$Query="",[string]$Concept="",[string]$Chapter="")
$kb = Get-Content -LiteralPath "$PSScriptRoot\..\knowledge-base.json" -Raw -Encoding UTF8 | ConvertFrom-Json
if ($Query) { $kb = $kb | Where-Object { $_.text -like "*$Query*" -or $_.concepts -like "*$Query*" } }
if ($Concept) { $kb = $kb | Where-Object { $_.concepts -contains $Concept } }
if ($Chapter) { $kb = $kb | Where-Object { $_.chapter -like "*$Chapter*" } }
$kb | ForEach-Object { Write-Host "`n=== $($_.id): $($_.heading) ===" -ForegroundColor Cyan; Write-Host "  章节: $($_.chapter)" -ForegroundColor Yellow; Write-Host "  概念: $($_.concepts -join ', ')"; Write-Host "  $($_.text)" -ForegroundColor White }

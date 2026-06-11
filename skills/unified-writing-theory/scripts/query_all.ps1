param([string]$Query="",[string]$Framework="",[string]$Concept="")

$base = Split-Path -Parent $PSScriptRoot
$results = @()

# Search all framework KBs
$frameworks = @{
    "mckee" = "$base\..\mckee-story-analyzer\references\mckee-knowledge-base.json"
    "truby" = "$base\..\story-writing-master-class\references\knowledge-base.json"
    "burroway" = "$base\..\burroway-narrative-craft\references\knowledge-base.json"
    "brande" = "$base\..\becoming-a-writer\references\knowledge-base.json"
    "wu" = "$base\..\kehuan-wenxue-lungang\references\knowledge-base.json"
    "gallishaw" = "$base\..\harvard-short-story\references\knowledge-base.json"
    "xie" = "$base\..\beneath-the-iceberg\references\knowledge-base.json"
}

if ($Framework) {
    $filtered = @{$Framework = $frameworks[$Framework]}
    if (-not $filtered) { Write-Error "未知框架: $Framework. 可选: mckee, truby, burroway, brande, wu, gallishaw, xie"; return }
    $frameworks = $filtered
}

foreach ($key in $frameworks.Keys) {
    $path = $frameworks[$key]
    if (-not (Test-Path $path)) { continue }
    $kb = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($Query) {
        $kb = $kb | Where-Object { $_.text -like "*$Query*" -or $_.concepts -like "*$Query*" -or $_.heading -like "*$Query*" }
    }
    if ($Concept) {
        $kb = $kb | Where-Object { $_.concepts -contains $Concept }
    }
    foreach ($entry in $kb) {
        $results += [PSCustomObject]@{
            Framework = $key
            ID = $entry.id
            Heading = $entry.heading
            Text = $entry.text
            Certainty = $entry.certainty
            Concepts = $entry.concepts -join ', '
        }
    }
}

if ($results.Count -eq 0) {
    Write-Host "无匹配结果" -ForegroundColor Yellow
    return
}

Write-Host "找到 ${results.Count} 条匹配结果" -ForegroundColor Green
$results | Format-Table Framework, Heading, Certainty, Concepts -AutoSize

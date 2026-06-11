# McKee Knowledge Base RAG Query Script
param(
    [Parameter(Mandatory=$true)]
    [string]$Query,
    [int]$Limit = 10
)

$KbPath = "C:\Users\xhg\.config\opencode\skills\mckee-story-analyzer\mckee-story-analyzer\references\mckee-knowledge-base.json"

if (-not (Test-Path $KbPath)) { Write-Error "KB not found: $KbPath"; exit 1 }

$kb = Get-Content $KbPath -Encoding UTF8 | ConvertFrom-Json
$keywords = $Query -split '\s+' | Where-Object { $_.Length -gt 0 }

$conceptMap = @{}
$conceptMap["inciting-incident"] = "激励事件,inciting incident,触发事件"
$conceptMap["the-gap"] = "鸿沟,the gap"
$conceptMap["structure"] = "结构,五部分,三幕,幕设计"
$conceptMap["crisis"] = "危机,crisis,两难,抉择"
$conceptMap["climax"] = "高潮,climax"
$conceptMap["resolution"] = "结局,resolution"
$conceptMap["controlling-idea"] = "主控思想,controlling idea"
$conceptMap["complication"] = "进展纠葛,complication"
$conceptMap["subplot"] = "次情节,subplot"
$conceptMap["archplot"] = "大情节,小情节,反情节"
$conceptMap["characterization"] = "人物塑造,真人物"
$conceptMap["character-arc"] = "人物弧,弧光,character arc"
$conceptMap["desire-levels"] = "欲望,desire,自觉,不自觉"
$conceptMap["antagonism"] = "对抗,对立,反面人物,antagonist"
$conceptMap["dimension"] = "维度,dimension"
$conceptMap["revelation"] = "揭示,revelation"
$conceptMap["dialogue-functions"] = "对白功能,说明,刻画,行动"
$conceptMap["subtext"] = "潜文本,subtext"
$conceptMap["show-vs-tell"] = "展示,讲述,show,tell"
$conceptMap["beats"] = "节拍,beat"
$conceptMap["narrator"] = "叙述者,narrator"
$conceptMap["genre-convention"] = "类型约定,genre convention"
$conceptMap["value-change"] = "价值转变,value change"
$conceptMap["turning-point"] = "转折点,turning point"
$conceptMap["scene-design"] = "场景,scene"
$conceptMap["conflict"] = "冲突,conflict"

$scored = New-Object System.Collections.ArrayList
foreach ($entry in $kb) {
    $score = 0
    foreach ($c in $entry.concepts) {
        if ($conceptMap.ContainsKey($c)) {
            $cKeywords = $conceptMap[$c] -split ','
            foreach ($ck in $cKeywords) {
                foreach ($qk in $keywords) {
                    if ($ck.Trim() -match $qk -or $qk -match $ck.Trim()) { $score += 3 }
                }
            }
        }
    }
    foreach ($qk in $keywords) {
        if ($entry.text -match [regex]::Escape($qk.Trim())) { $score += 2 }
    }
    if ($score -gt 0) {
        $null = $scored.Add(@{score=$score; chapter=$entry.chapter; file=$entry.file; concepts=$entry.concepts -join ','; text=$entry.text})
    }
}

$results = $scored | Sort-Object -Property score -Descending | Select-Object -First ($Limit * 2)

$seen = @{}
$unique = New-Object System.Collections.ArrayList
foreach ($r in $results) {
    $sig = $r.text.Substring(0, [Math]::Min(50, $r.text.Length))
    if (-not $seen.ContainsKey($sig)) {
        $seen[$sig] = $true
        $null = $unique.Add($r)
        if ($unique.Count -ge $Limit) { break }
    }
}

Write-Host "=== McKee KB Query ==="
Write-Host "Query: $Query"
Write-Host ""

$i = 1
foreach ($r in $unique) {
    Write-Host "--- Result $i (score: $($r.score)) ---"
    Write-Host "Chapter: $($r.chapter)"
    Write-Host "File: $($r.file)"
    Write-Host "Concepts: $($r.concepts)"
    $displayText = $r.text
    if ($displayText.Length -gt 600) { $displayText = $displayText.Substring(0, 600) + '...' }
    Write-Host "Text: $displayText"
    Write-Host ""
    $i++
}
Write-Host "Total: $($unique.Count) unique results"

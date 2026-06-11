param(
    [string]$Query = "",
    [string]$Concept = "",
    [string]$Chapter = ""
)

$kbPath = Join-Path $PSScriptRoot ".." "knowledge-base.json"
if (-not (Test-Path $kbPath)) {
    Write-Error "知识库文件未找到: $kbPath"
    exit 1
}

$kb = Get-Content $kbPath -Raw | ConvertFrom-Json

if ($Query) {
    $results = $kb | Where-Object { 
        $_.text -like "*$Query*" -or 
        $_.heading -like "*$Query*" -or
        ($_.concepts -join " ") -like "*$Query*"
    }
} elseif ($Concept) {
    $results = $kb | Where-Object { $_.concepts -contains $Concept }
} elseif ($Chapter) {
    $results = $kb | Where-Object { $_.chapter -eq $Chapter }
} else {
    $results = $kb
}

Write-Output "找到 $($results.Count) 条匹配条目"
Write-Output ""

foreach ($entry in $results) {
    Write-Output "---"
    Write-Output "ID: $($entry.id)"
    Write-Output "章节: $($entry.chapter)"
    Write-Output "标题: $($entry.heading)"
    Write-Output "确定性: $($entry.certainty)"
    Write-Output "适用媒介: $($entry.applicable_media -join ', ')"
    Write-Output "概念: $($entry.concepts -join ', ')"
    Write-Output "内容: $($entry.text)"
    if ($entry.framework_bias_note) {
        Write-Output "注: $($entry.framework_bias_note)"
    }
    Write-Output ""
}

# 概念图谱（conceptMap）
$conceptMap = @{
    "写作自信" = @("写作本身的困难", "四种困难", "心理障碍")
    "无意识" = @("双重人格", "天才的根源", "清晨写作", "约束无意识")
    "双重人格" = @("作家气质", "意识与无意识", "两个自我")
    "定时写作" = @("写作纪律", "习惯养成", "清晨写作")
    "天真的眼神" = @("观察力", "学会重新看世界", "习惯盲区")
    "三重天性" = @("天才", "作家魔力", "头脑安静", "艺术的迷醉")
    "批评式阅读" = @("读两遍法", "自我批评", "模仿")
    "原创性" = @("诚实", "独特性", "相信自己")
}

Write-Output "=== 概念图谱（conceptMap）==="
$conceptMap.Keys | ForEach-Object {
    Write-Output "$_ : $($conceptMap[$_] -join ', ')"
}

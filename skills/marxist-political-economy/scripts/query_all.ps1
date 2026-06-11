param(
    [string]$Query = "",
    [int]$Volume = 0,
    [switch]$ListConcepts = $false,
    [switch]$Help = $false
)

$skillRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$vols = @()

# Detect available volumes by checking for knowledge-base.json
for ($v = 1; $v -le 5; $v++) {
    $kbPath = Join-Path $skillRoot "references\vol$v\knowledge-base.json"
    if (Test-Path $kbPath) {
        $vols += @{
            number = $v
            kb = Get-Content $kbPath -Encoding UTF8 | ConvertFrom-Json
        }
    }
}

# Check for additional volumes
$extraPath = Join-Path $skillRoot "references\extra\knowledge-base.json"
if (Test-Path $extraPath) {
    $vols += @{
        number = 99
        kb = Get-Content $extraPath -Encoding UTF8 | ConvertFrom-Json
        name = "extra"
    }
}

if ($vols.Count -eq 0) {
    Write-Host "未找到任何知识库卷。请确认 skill 已正确安装。" -ForegroundColor Red
    exit 1
}

# Build concept map from Vol 1
$conceptMap = @{
    "商品" = @("commodity", "使用价值", "交换价值", "价值实体", "社会必要劳动时间")
    "劳动二重性" = @("具体劳动", "抽象劳动", "简单劳动", "复杂劳动", "labor duality")
    "价值形式" = @("简单价值形式", "扩大价值形式", "一般价值形式", "货币形式", "相对价值形式", "等价形式", "等价形式三特点")
    "商品拜物教" = @("拜物教", "物化", "社会关系的物化", "commodity fetishism", "reification")
    "货币拜物教" = @("货币之谜", "金银天然不是货币")
    "资本拜物教" = @("生息资本", "G-G'")
    "货币" = @("价值尺度", "价格标准", "流通手段", "货币贮藏", "支付手段", "世界货币", "铸币", "纸币")
    "商品流通" = @("W-G-W", "商品的惊险的跳跃", "买和卖的分离", "危机可能性")
    "货币流通" = @("货币流通规律", "流通手段量")
    "资本" = @("资本总公式", "G-W-G'", "价值增殖", "人格化的资本")
    "剩余价值" = @("surplus value", "价值形成过程", "价值增殖过程", "剩余价值率", "m/v")
    "不变资本" = @("可变资本", "c", "v", "c/v", "资本有机构成")
    "劳动力商品" = @("劳动力", "自由工人", "劳动力价值")
    "绝对剩余价值" = @("工作日", "工作日斗争")
    "相对剩余价值" = @("劳动生产力", "必要劳动时间")
    "协作" = @("集体力", "资本主义起点")
    "分工" = @("工场手工业", "局部工人")
    "机器" = @("大工业", "工具机", "工厂制度")
    "工资" = @("工资的本质", "计时工资", "计件工资")
    "再生产" = @("简单再生产", "扩大再生产")
    "资本积累" = @("accumulation", "所有权规律转化")
    "相对过剩人口" = @("产业后备军", "失业")
    "积累的一般规律" = @("贫困积累", "财富积累", "两极分化")
    "原始积累" = @("primitive accumulation", "圈地运动", "暴力剥夺")
    "剥夺剥夺者" = @("expropriation", "资本垄断", "生产社会化")
    "经济关系人格化" = @("法权关系", "经济角色")
}

if ($Help) {
    Write-Host @"
马克思主义政治经济学 - 跨卷知识库查询工具

用法:
    .\query_all.ps1 -Query "商品拜物教"       # 搜索所有卷
    .\query_all.ps1 -Query "剩余价值" -Volume 1  # 只搜索 Vol 1
    .\query_all.ps1 -ListConcepts              # 列出所有可用概念
    .\query_all.ps1 -Help                      # 显示此帮助

当前可用卷: $($vols | ForEach-Object { "Vol $($_.number)" } -join ', ')
"@
    exit
}

if ($ListConcepts) {
    Write-Host "当前已收录概念:" -ForegroundColor Green
    $conceptMap.Keys | Sort-Object | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "详细查询请使用: query_all.ps1 -Query '概念名'"
    exit
}

# Filter by volume if specified
$targetVols = if ($Volume -gt 0) { $vols | Where-Object { $_.number -eq $Volume } } else { $vols }

if ($targetVols.Count -eq 0) {
    Write-Host "未找到 Vol $Volume。可用卷: $($vols | ForEach-Object { "Vol $($_.number)" } -join ', ')" -ForegroundColor Red
    exit 1
}

if ($Query) {
    $totalResults = 0
    foreach ($volInfo in $targetVols) {
        $v = $volInfo.number
        $kb = $volInfo.kb

        $results = $kb | Where-Object {
            $_.text -like "*$Query*" -or
            $_.heading -like "*$Query*" -or
            $_.concepts -contains $Query -or
            $_.concepts -like "*$Query*" -or
            $_.scope_note -like "*$Query*" -or
            $_.fiction_application -like "*$Query*"
        }

        # Also search concept map aliases
        foreach ($entry in $conceptMap.Keys) {
            if ($entry -like "*$Query*" -or ($conceptMap[$entry] | Where-Object { $_ -like "*$Query*" })) {
                $results += $kb | Where-Object { $_.concepts -contains $entry }
            }
        }

        $results = $results | Sort-Object id -Unique

        if ($results.Count -gt 0) {
            $volLabel = if ($v -eq 99) { "Extra" } else { "Vol $v" }
            Write-Host "=== $volLabel ($($results.Count) 条) ===" -ForegroundColor Cyan
            $results | ForEach-Object {
                Write-Host "[$($_.id)] $($_.chapter) > $($_.heading)" -ForegroundColor White
                Write-Host "  置信度: $($_.confidence) | 概念: $($_.concepts -join ', ')" -ForegroundColor Gray
                if ($_.scope_note) {
                    Write-Host "  适用范围: $($_.scope_note)" -ForegroundColor DarkYellow
                }
                if ($_.fiction_application) {
                    Write-Host "  创作应用: $($_.fiction_application)" -ForegroundColor DarkGreen
                }
            }
            $totalResults += $results.Count
        }
    }

    if ($totalResults -eq 0) {
        Write-Host "未找到匹配 '$Query' 的条目" -ForegroundColor Red
    } else {
        Write-Host "---" -ForegroundColor Gray
        Write-Host "共 $totalResults 条结果 (查询: $Query)" -ForegroundColor Green
    }
}

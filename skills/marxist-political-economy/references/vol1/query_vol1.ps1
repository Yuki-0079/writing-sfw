param(
    [string]$Query = "",
    [string]$Chapter = "",
    [switch]$ListConcepts = $false,
    [switch]$Help = $false
)

$kbPath = Join-Path $PSScriptRoot "..\references\knowledge-base.json"

if (!(Test-Path $kbPath)) {
    Write-Host "知识库文件未找到: $kbPath" -ForegroundColor Red
    exit 1
}

$kb = Get-Content $kbPath -Encoding UTF8 | ConvertFrom-Json

$conceptMap = @{
    "商品" = @("commodity", "商品的两个因素", "使用价值", "交换价值", "价值实体", "社会必要劳动时间")
    "劳动二重性" = @("具体劳动", "抽象劳动", "简单劳动", "复杂劳动", "labor duality")
    "价值形式" = @("简单价值形式", "扩大价值形式", "一般价值形式", "货币形式", "相对价值形式", "等价形式", "等价形式三特点")
    "商品拜物教" = @("拜物教", "物化", "社会关系的物化", "commodity fetishism", "reification")
    "货币拜物教" = @("货币之谜", "金银天然不是货币", "货币天然是金银")
    "资本拜物教" = @("生息资本", "G-G'", "资本神秘化")
    "货币" = @("价值尺度", "价格标准", "流通手段", "货币贮藏", "支付手段", "世界货币", "铸币", "纸币", "价值符号")
    "商品流通" = @("W-G-W", "商品形态变化", "商品的惊险的跳跃", "买和卖的分离", "危机可能性")
    "货币流通" = @("货币流通规律", "流通手段量", "货币流通速度")
    "资本" = @("资本总公式", "G-W-G'", "价值增殖", "人格化的资本")
    "剩余价值" = @("surplus value", "价值形成过程", "价值增殖过程", "剩余价值率", "m/v", "m/(c+v)")
    "不变资本" = @("可变资本", "c", "v", "c/v", "资本技术构成", "资本有机构成")
    "劳动力商品" = @("劳动力", "labor power", "自由工人", "一无所有", "劳动力价值", "历史和道德因素")
    "绝对剩余价值" = @("工作日", "工作日斗争", "绝对剩余价值生产")
    "相对剩余价值" = @("劳动生产力", "必要劳动时间", "相对剩余价值生产")
    "协作" = @("集体力", "资本主义起点", "cooperation")
    "分工" = @("工场手工业", "局部工人", "操作分离", "division of labor")
    "机器" = @("大工业", "工具机", "发动机", "传动机构", "Factory system")
    "工厂制度" = @("工人反抗", "机器排挤工人", "妇女劳动", "儿童劳动")
    "工资" = @("工资的本质", "劳动力价值转化形式", "劳动价格", "计时工资", "计件工资")
    "再生产" = @("简单再生产", "扩大再生产", "资本主义生产关系再生产")
    "资本积累" = @("accumulation", "所有权规律转化", "积累量", "资本集中")
    "资本有机构成" = @("organic composition", "c:v", "不变资本相对增加", "可变资本相对减少")
    "相对过剩人口" = @("产业后备军", "reserve army", "失业", "人口过剩")
    "积累的一般规律" = @("贫困积累", "财富积累", "两极分化", "general law of accumulation")
    "原始积累" = @("primitive accumulation", "圈地运动", "生产者与生产资料分离", "暴力剥夺")
    "剥夺剥夺者" = @("expropriation", "资本垄断", "生产社会化", "资本主义外壳")
    "殖民理论" = @("威克菲尔德", "systematic colonization", "自由工人缺乏")
    "形式从属" = @("实际从属", "劳动对资本的从属形式", "formal subsumption", "real subsumption")
    "经济关系人格化" = @("角色扮演", "法权关系", "经济角色", "意志关系")
    "生产关系" = @("经济基础", "上层建筑", "历史唯物主义", "生产力和生产关系")
}

if ($Help) {
    Write-Host @"
资本论 第一卷 - 政治经济学知识库查询工具

用法:
    .\query_kb.ps1 -Query "商品拜物教"      # 搜索知识库
    .\query_kb.ps1 -Chapter "第1章"         # 按章节检索
    .\query_kb.ps1 -ListConcepts             # 列出所有可用概念
    .\query_kb.ps1 -Help                     # 显示此帮助

概念列表(可用于 -Query):
    $(($conceptMap.Keys | Sort-Object) -join ", ")
"@
    exit
}

if ($ListConcepts) {
    Write-Host "可用概念:" -ForegroundColor Green
    $conceptMap.Keys | Sort-Object | ForEach-Object {
        $aliases = $conceptMap[$_] -join ", "
        Write-Host "  $_" -ForegroundColor Yellow
        Write-Host "    别名: $aliases"
    }
    exit
}

if ($Chapter) {
    $results = $kb | Where-Object { $_.chapter -like "*$Chapter*" }
    if ($results.Count -eq 0) {
        Write-Host "未找到匹配 '$Chapter' 的条目" -ForegroundColor Red
    } else {
        Write-Host "找到 $($results.Count) 条结果 (章节: $Chapter):" -ForegroundColor Green
        $results | ForEach-Object {
            Write-Host "[$($_.id)] $($_.heading)" -ForegroundColor Cyan
            Write-Host "  置信度: $($_.confidence) | 概念: $($_.concepts -join ', ')"
        }
    }
    exit
}

if ($Query) {
    # Search in all fields
    $results = $kb | Where-Object {
        $_.text -like "*$Query*" -or
        $_.heading -like "*$Query*" -or
        $_.concepts -contains $Query -or
        $_.concepts -like "*$Query*" -or
        $_.scope_note -like "*$Query*" -or
        $_.fiction_application -like "*$Query*"
    }

    # Also search through concept map aliases
    $relatedConcepts = @()
    foreach ($entry in $conceptMap.Keys) {
        if ($entry -like "*$Query*" -or ($conceptMap[$entry] | Where-Object { $_ -like "*$Query*" })) {
            $relatedConcepts += $entry
            $results += $kb | Where-Object { $_.concepts -contains $entry }
        }
    }

    $results = $results | Sort-Object id -Unique

    if ($results.Count -eq 0) {
        Write-Host "未找到匹配 '$Query' 的条目" -ForegroundColor Red
    } else {
        Write-Host "找到 $($results.Count) 条结果 (查询: $Query):" -ForegroundColor Green
        $results | ForEach-Object {
            Write-Host "[$($_.id)] $($_.chapter) > $($_.heading)" -ForegroundColor Cyan
            Write-Host "  置信度: $($_.confidence) | 概念: $($_.concepts -join ', ')" -ForegroundColor Gray
            if ($_.scope_note) {
                Write-Host "  适用范围: $($_.scope_note)" -ForegroundColor DarkYellow
            }
            if ($_.fiction_application) {
                Write-Host "  创作应用: $($_.fiction_application)" -ForegroundColor DarkGreen
            }
        }
    }
}

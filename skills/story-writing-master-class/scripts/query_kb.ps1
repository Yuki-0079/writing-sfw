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
    "七大关键步骤" = @("七步结构法", "故事结构七大步骤", "7 steps", "weakness/need", "弱点/需求", "欲望", "对手", "计划", "对决", "真实自我揭露", "新的平衡点")
    "22步结构" = @("二十二个步骤", "22 steps", "情节地图", "故事中段", "触发事件", "幽灵", "看似落败", "闸门", "体验死亡", "揭露与抉择")
    "设计原则" = @("Designing Principle", "故事前提", "内在逻辑", "种子", "中心象征", "根本隐喻")
    "角色网络" = @("Character Web", "角色功能", "原型", "对立关系", "四角对立", "陪衬情节角色", "假盟友", "角色比较")
    "道德论点" = @("Moral Argument", "主题要旨", "道德抉择", "价值冲突", "主题变奏", "道德愿景", "道德序列")
    "戏剧符码" = @("Dramatic Code", "欲望驱动", "我欲故我在", "行动学习", "角色转变", "戏剧符码")
    "故事世界" = @("Story World", "场域", "客观对应物", "视觉对立", "自然环境", "人造空间", "缩影", "通道")
    "象征网络" = @("象征", "Symbol Web", "故事象征", "角色象征", "主题象征", "行动象征", "物件象征")
    "情节类型" = @("旅程式情节", "揭露式情节", "反情节", "多线式情节", "三一律情节")
    "场景编排" = @("Scene Weaving", "场景清单", "交叉剪辑", "并列场景", "漏斗效应")
    "场景建构" = @("倒三角形", "微型故事", "潜文本场景", "场景九步法")
    "交响乐式对白" = @("三条音轨", "故事对白", "道德对白", "关键词", "口号", "旋律与和声")
    "有机故事" = @("生命体", "子系统", "机械故事", "由内而外", "自动自发")
    "幽灵" = @("ghost", "背景故事", "反欲望", "内在对手")
    "永不完结的故事" = @("虚假结局", "莫比乌斯环", "故事织锦", "封闭式结局")
    "对手" = @("antagonist", "对立角色", "同一目标竞争", "深层冲突")
    "角色转变" = @("W×A=C", "转变弧线", "信念改变", "道德行动", "转变幅度")
}

if ($Help) {
    Write-Host @"
Truby 故事写作大师班 - 知识库查询工具

用法:
    .\query_kb.ps1 -Query "设计原则"        # 搜索知识库
    .\query_kb.ps1 -Chapter "第4章"         # 按章节检索
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
            Write-Host "  确定性: $($_.certainty) | 媒介: $($_.applicable_media -join ', ')"
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
        $_.concepts -like "*$Query*"
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
            Write-Host "  确定性: $($_.certainty) | 媒介: $($_.applicable_media -join ', ')"
            if ($_.framework_bias_note) {
                Write-Host "  注意: $($_.framework_bias_note)" -ForegroundColor DarkYellow
            }
        }
    }
}

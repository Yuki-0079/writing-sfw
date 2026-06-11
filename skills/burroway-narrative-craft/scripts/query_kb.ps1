param(
    [Parameter(Mandatory=$true)]
    [string]$Query,
    [int]$Limit = 5
)

$KbPath = Join-Path $PSScriptRoot "..\references\knowledge-base.json"
$kb = Get-Content $KbPath -Encoding UTF8 | ConvertFrom-Json

# 概念别名映射
$conceptMap = @{
    "展现与讲述" = "show,show don't tell,展现,讲述,展现不要讲述,展示"
    "细节" = "有意义细节,具体细节,感官细节,细节选择"
    "过滤词" = "过滤,她注意到,她看见"
    "主动语态" = "主动动词,被动语态,系动词"
    "行文节奏" = "节奏,句式,句子节奏,行文"
    "对话" = "斯隆法则,潜台词,说'不',言外之意"
    "人物塑造" = "直接刻画,间接刻画,作者阐释,角色阐释,直接表现,间接表现"
    "外貌描写" = "人物外貌,体态描写"
    "行为描写" = "人物行动,动作,运动,行为"
    "人物矛盾性" = "矛盾,自我暴露,永恒矛盾"
    "人物可信性" = "可信,得体性"
    "人物意志" = "渴望,欲望,愿望"
    "人物变化" = "角色弧,变化弧,人物转变"
    "人物日志" = "角色日志,人物档案"
    "人物群体" = "群体,群像"
    "背景" = "氛围,地点,时间,情绪,环境"
    "叙事时间" = "简述,详述,倒叙,慢动作,白空间"
    "冲突" = "危机,结局,激情,危险"
    "故事vs情节" = "故事,情节,因果关系"
    "联系" = "中断联系,联系中断,塔和网"
    "短篇小说" = "长篇小说,短篇,长篇,形式差异"
    "叙述视角" = "视角,POV,人称,谁在说,对谁说,以什么形式说,以多远的距离说"
    "全知视角" = "全知作者,第三人称全知"
    "有限全知" = "第三人称有限,有限视角"
    "客观视角" = "客观作者,海明威式"
    "第一人称" = "中心叙述者,外围叙述者"
    "不可靠叙述者" = "不可靠叙述,戏剧讽刺"
    "视角一致性" = "视角转换,视角差错"
    "文化挪用" = "挪用,跨文化写作"
    "隐喻" = "暗喻,明喻,比喻,死隐喻,混合隐喻"
    "象征" = "文学象征,象征主义"
    "客观对应物" = "客观关联物,艾略特"
    "修改" = "改写,重写,编辑,重读"
    "主题" = "主题发现,小说主题,主题表现"
    "创作过程" = "写作习惯,写作障碍,自由写作,日志,灵感,初稿"
    "写作障碍" = "写作恐惧,创作障碍,文思枯竭"
    "自由写作" = "自由撰稿,自由书写"
    "初稿策略" = "一口气写完,快速初稿"
    "批评" = "他人批评,研讨班,修改建议"
    "阅读方法" = "像作家一样阅读,阅读技巧"
}

$keywords = $Query -split '\s+' | Where-Object { $_.Length -gt 0 }
$scored = New-Object System.Collections.ArrayList

foreach ($entry in $kb) {
    $score = 0
    foreach ($c in $entry.concepts) {
        if ($conceptMap.ContainsKey($c)) {
            $cKeywords = $conceptMap[$c] -split ','
            foreach ($ck in $cKeywords) {
                foreach ($qk in $keywords) {
                    if ($ck.Trim() -match [regex]::Escape($qk.Trim()) -or $qk.Trim() -match [regex]::Escape($ck.Trim())) { $score += 3 }
                }
            }
        }
    }
    foreach ($qk in $keywords) {
        if ($entry.text -match [regex]::Escape($qk.Trim())) { $score += 2 }
        if ($entry.chapter -match [regex]::Escape($qk.Trim())) { $score += 1 }
    }
    if ($score -gt 0) {
        $null = $scored.Add(@{score=$score; id=$entry.id; chapter=$entry.chapter; heading=$entry.heading; concepts=$entry.concepts -join ','; text=$entry.text})
    }
}

$results = $scored | Sort-Object -Property score -Descending | Select-Object -First $Limit
$results | ForEach-Object { 
    Write-Output "=== $($_.id) | 匹配度: $($_.score) ==="
    Write-Output "章节: $($_.chapter) > $($_.heading)"
    Write-Output "概念: $($_.concepts)"
    Write-Output "内容: $($_.text)"
    Write-Output ""
}

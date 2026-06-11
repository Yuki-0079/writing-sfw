<#
.SYNOPSIS
    Extract McKee's Three-Book EPUB into structured knowledge base for RAG queries.
#>
param(
    [string]$EpubPath = "C:\Users\xhg\Downloads\罗伯特·麦基虚构艺术三部曲.epub",
    [string]$OutputDir = "C:\Users\xhg\.config\opencode\skills\mckee-story-analyzer\mckee-story-analyzer\references",
    [string]$TempDir = "$env:TEMP\mckee_epub_extract"
)

$ErrorActionPreference = "Continue"
Write-Host "=== McKee EPUB Knowledge Base Extractor ===" -ForegroundColor Cyan

# Step 1: Extract EPUB as ZIP
Write-Host "[1/5] Extracting EPUB..." -ForegroundColor Yellow
if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($EpubPath, $TempDir)
    Write-Host "  Extracted to: $TempDir"
} catch {
    Write-Error "Failed to extract EPUB: $_"
    exit 1
}

# Step 2: Find container and OPF
Write-Host "[2/5] Parsing EPUB structure..." -ForegroundColor Yellow
$containerPath = Join-Path $TempDir "META-INF" "container.xml"
if (-not (Test-Path $containerPath)) {
    Write-Error "container.xml not found - invalid EPUB"
    exit 1
}
$container = [xml](Get-Content $containerPath -Encoding UTF8)
$nsManager = New-Object System.Xml.XmlNamespaceManager($container.NameTable)
$nsManager.AddNamespace("cn", "urn:oasis:names:tc:opendocument:xmlns:container")
$rootFile = $container.SelectSingleNode("//cn:rootfile", $nsManager).GetAttribute("full-path")
Write-Host "  Root file: $rootFile"

$opfPath = Join-Path $TempDir $rootFile
$opfDir = Split-Path $opfPath -Parent
$opf = [xml](Get-Content $opfPath -Encoding UTF8)
$opfNS = New-Object System.Xml.XmlNamespaceManager($opf.NameTable)
$opfNS.AddNamespace("opf", "http://www.idpf.org/2007/opf")
$opfNS.AddNamespace("dc", "http://purl.org/dc/elements/1.1/")

# Build manifest
$manifest = @{}
$opf.SelectNodes("//opf:item", $opfNS) | ForEach-Object {
    $id = $_.GetAttribute("id")
    $href = $_.GetAttribute("href")
    $mtype = $_.GetAttribute("media-type")
    if ($mtype -match "xhtml|html|xml") {
        $manifest[$id] = $href
    }
}
Write-Host "  Content files (XHTML): $($manifest.Count)"

# Build spine
$spine = @()
$opf.SelectNodes("//opf:itemref", $opfNS) | ForEach-Object {
    $idref = $_.GetAttribute("idref")
    if ($manifest.ContainsKey($idref)) {
        $spine += $manifest[$idref]
    }
}
Write-Host "  Spine items: $($spine.Count)"

# Step 3: Function to parse XHTML and extract clean text
function Convert-XhtmlToText {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) { return $null }
    
    try {
        $rawContent = Get-Content $FilePath -Raw -Encoding UTF8
        
        # Use .NET for HTML entity decoding
        $rawContent = [System.Web.HttpUtility]::HtmlDecode($rawContent)
        
        # Remove script and style blocks
        $rawContent = $rawContent -replace '(?s)<script[^>]*>.*?</script>', ' '
        $rawContent = $rawContent -replace '(?s)<style[^>]*>.*?</style>', ' '
        $rawContent = $rawContent -replace '(?s)<head[^>]*>.*?</head>', ' '
        
        # Replace block-level tags with newlines
        $rawContent = $rawContent -replace '<br\s*/?\s*>', "`n"
        $rawContent = $rawContent -replace '<p\b[^>]*>', "`n"
        $rawContent = $rawContent -replace '</p>', "`n"
        $rawContent = $rawContent -replace '<div\b[^>]*>', "`n"
        $rawContent = $rawContent -replace '</div>', "`n"
        $rawContent = $rawContent -replace '<h\d\b[^>]*>', "`n# "
        $rawContent = $rawContent -replace '</h\d>', "`n"
        $rawContent = $rawContent -replace '<li\b[^>]*>', "`n- "
        $rawContent = $rawContent -replace '</li>', ""
        $rawContent = $rawContent -replace '<blockquote\b[^>]*>', "`n> "
        $rawContent = $rawContent -replace '</blockquote>', "`n"
        
        # Remove remaining HTML tags
        $rawContent = $rawContent -replace '<[^>]+>', ' '
        
        # Clean up whitespace
        $rawContent = $rawContent -replace '\s+', ' '
        $rawContent = $rawContent -replace '\n\s+', "`n"
        $rawContent = $rawContent -replace '\n{3,}', "`n`n"
        $rawContent = $rawContent.Trim()
        
        if ($rawContent.Length -gt 100) {
            return $rawContent
        }
    } catch {
        Write-Warning "Parse error for $($FilePath): $($_.Exception.Message)"
    }
    return $null
}

# Step 4: Extract text from each spine file
Write-Host "[3/5] Extracting text content..." -ForegroundColor Yellow

$allChapters = [System.Collections.ArrayList]::new()
$chapterNum = 0

foreach ($spineFile in $spine) {
    $fullPath = Join-Path $opfDir $spineFile
    $text = Convert-XhtmlToText $fullPath
    
    if ($text -and $text.Length -gt 200) {
        $chapterNum++
        
        # Try to detect chapter title from first lines
        $heading = ""
        $firstLines = ($text -split "`n")[0..4] -join " "
        if ($firstLines.Length -gt 0) {
            $heading = $firstLines.Substring(0, [Math]::Min(120, $firstLines.Length))
        }
        
        # Detect which book
        $bookTag = ""
        if ($heading -match "故事|Story|STORY") { $bookTag = "故事" }
        elseif ($heading -match "对白|对话|Dialogue|DIALOGUE") { $bookTag = "对白" }
        elseif ($heading -match "人物|Character|CHARACTER") { $bookTag = "人物" }
        
        $null = $allChapters.Add(@{
            index = $chapterNum
            book = $bookTag
            heading = $heading
            text = $text
            length = $text.Length
            file = $spineFile
        })
    }
}

Write-Host "  Extracted chapters: $($allChapters.Count)"

# Step 5: Build knowledge base - tag paragraphs by concepts
Write-Host "[4/5] Building knowledge base..." -ForegroundColor Yellow

# Concept definitions for tagging
$conceptDefs = @{
    "激励事件" = @("激励事件", "inciting incident")
    "鸿沟原理" = @("鸿沟", "the gap", "期望与结果")
    "五部分结构" = @("五部分", "幕设计", "三幕", "结构设计")
    "危机选择" = @("危机", "crisis", "两难", "抉择")
    "高潮设计" = @("高潮", "climax")
    "结局" = @("结局", "resolution")
    "主控思想" = @("主控思想", "controlling idea", "主题")
    "进展纠葛" = @("进展纠葛", "complication", "不归点")
    "次情节" = @("次情节", "subplot")
    "大情节vs小情节" = @("大情节", "小情节", "反情节", "archplot", "miniplot")
    "人物塑造vs真人物" = @("人物塑造", "真人物", "characterization")
    "人物弧光" = @("人物弧", "character arc", "弧光", "转变")
    "欲望层次" = @("自觉欲望", "不自觉欲望", "conscious desire", "unconscious")
    "对立原理" = @("对抗力", "antagonist", "对立")
    "人物维度" = @("维度", "矛盾", "dimension")
    "人物揭示" = @("揭示", "revelation")
    "对白三功能" = @("对白的功能", "说明", "刻画", "行动")
    "潜文本" = @("潜文本", "subtext", "没说出来的")
    "展示vs讲述" = @("展示", "讲述", "show", "tell")
    "对白节拍" = @("节拍", "beat")
    "叙述者" = @("叙述者", "narrator", "视角", "第一人称")
    "类型约定" = @("类型", "约定", "genre", "convention")
    "类型创新" = @("创新", "套路", "程式化")
    "价值转变" = @("价值转变", "value change")
    "转折点" = @("转折点", "turning point")
    "场景设计" = @("场景", "scene", "序列")
    "冲突法则" = @("冲突", "conflict", "对抗")
    "背景设定" = @("背景", "setting", "四维背景")
    "麦基原则" = @("麦基", "McKee", "原则")
}

$knowledgeEntries = [System.Collections.ArrayList]::new()

foreach ($ch in $allChapters) {
    # Split text into paragraphs (by double newline)
    $paragraphs = $ch.text -split "\n\s*\n" | Where-Object { $_.Trim().Length -gt 40 }
    
    foreach ($para in $paragraphs) {
        $matchedConcepts = [System.Collections.ArrayList]::new()
        
        foreach ($conceptName in $conceptDefs.Keys) {
            $keywords = $conceptDefs[$conceptName]
            foreach ($kw in $keywords) {
                if ($para -match [regex]::Escape($kw)) {
                    $null = $matchedConcepts.Add($conceptName)
                    break
                }
            }
        }
        
        if ($matchedConcepts.Count -gt 0) {
            $null = $knowledgeEntries.Add(@{
                concepts = @($matchedConcepts)
                source_book = $ch.book
                source_chapter = $ch.heading.Substring(0, [Math]::Min(100, $ch.heading.Length))
                text = $para.Trim()
                char_count = $para.Length
            })
        }
    }
}

Write-Host "  Tagged knowledge entries: $($knowledgeEntries.Count)"

# Save outputs
Write-Host "[5/5] Saving outputs..." -ForegroundColor Yellow

# Knowledge Base JSON
$kbPath = Join-Path $OutputDir "mckee-knowledge-base.json"
$knowledgeEntries | ConvertTo-Json -Depth 4 | Set-Content -Path $kbPath -Encoding UTF8
Write-Host "  KB.json: $kbPath ($($knowledgeEntries.Count) entries)"

# TOC Index
$tocIndex = @()
foreach ($ch in $allChapters) {
    $tocIndex += @{
        index = $ch.index
        book = $ch.book
        heading = $ch.heading.Substring(0, [Math]::Min(80, $ch.heading.Length))
        length = $ch.length
        file = $ch.file
    }
}
$tocPath = Join-Path $OutputDir "mckee-toc-index.json"
$tocIndex | ConvertTo-Json -Depth 3 | Set-Content -Path $tocPath -Encoding UTF8

# Chapter text files
$chaptersDir = Join-Path $OutputDir "chapters"
New-Item -ItemType Directory -Path $chaptersDir -Force | Out-Null

foreach ($ch in $allChapters) {
    $safeName = $ch.index.ToString("0000")
    $fname = "$safeName.txt"
    $fp = Join-Path $chaptersDir $fname
    $output = @"
BOOK: $($ch.book)
HEADING: $($ch.heading)
LENGTH: $($ch.length) chars

$($ch.text)
"@
    Set-Content -Path $fp -Value $output -Encoding UTF8
}

Write-Host "  Chapter texts: $chaptersDir"

# Cleanup temp
Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue

# Summary
Write-Host ""
Write-Host "=== EXTRACTION COMPLETE ===" -ForegroundColor Green
Write-Host "  Total chapters:  $($allChapters.Count)"
Write-Host "  Total KB entries: $($knowledgeEntries.Count)"
Write-Host "  Output directory: $OutputDir"

# Show book distribution
$bookDist = $allChapters | Group-Object { $_.book } | Sort-Object Count -Descending
foreach ($b in $bookDist) {
    Write-Host "  $($b.Name): $($b.Count) chapters" -ForegroundColor Cyan
}

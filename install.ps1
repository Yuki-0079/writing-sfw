<#
.SYNOPSIS
    创意写作工作坊 — 一键安装脚本
.DESCRIPTION
    将 skills/, agents/, workshop/ 安装到 opencode 配置目录和用户工作区。
.PARAMETER WorkshopPath
    Workshop 工程文件的安装路径（默认当前目录下的 writing_sfw）
.PARAMETER Force
    覆盖已存在的 skill（默认跳过）
.EXAMPLE
    .\install.ps1 -WorkshopPath "C:\MyProjects\writing_sfw"
    .\install.ps1 -Force
#>

param(
    [string]$WorkshopPath = (Join-Path (Get-Location) "writing_sfw"),
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# 目标路径
$skillTarget = "$env:USERPROFILE\.config\opencode\skills"
$agentTarget = "$env:USERPROFILE\.config\opencode\agents\sfw"

# 统计
$installed = @(); $skipped = @(); $failed = @()

Write-Host "=== 创意写作工作坊 安装脚本 ===" -ForegroundColor Cyan
Write-Host ""

# ---- Step 1: 安装 Skills ----
Write-Host "[Step 1/3] 安装 Skills → $skillTarget" -ForegroundColor Yellow
New-Item -ItemType Directory -Path $skillTarget -Force | Out-Null

$skillDirs = Get-ChildItem (Join-Path $repoRoot "skills") -Directory
foreach ($dir in $skillDirs) {
    $dest = Join-Path $skillTarget $dir.Name
    if (Test-Path $dest) {
        if ($Force) {
            Remove-Item -Path $dest -Recurse -Force
            Copy-Item -Path $dir.FullName -Destination $dest -Recurse -Force
            $installed += $dir.Name
            Write-Host "  [覆盖] $($dir.Name)" -ForegroundColor Green
        } else {
            $skipped += $dir.Name
            Write-Host "  [跳过] $($dir.Name)（已存在）" -ForegroundColor DarkYellow
        }
    } else {
        Copy-Item -Path $dir.FullName -Destination $dest -Recurse -Force
        $installed += $dir.Name
        Write-Host "  [安装] $($dir.Name)" -ForegroundColor Green
    }
}

# ---- Step 2: 安装 Writing Analyzer Agent ----
Write-Host "`n[Step 2/3] 安装 Writing Analyzer Agent → $agentTarget" -ForegroundColor Yellow
New-Item -ItemType Directory -Path $agentTarget -Force | Out-Null

$agentSrc = Join-Path $repoRoot "agents\sfw\writing-analyzer.md"
$agentDest = Join-Path $agentTarget "writing-analyzer.md"

if (Test-Path $agentDest -and -not $Force) {
    $skipped += "writing-analyzer.md"
    Write-Host "  [跳过] writing-analyzer.md（已存在）" -ForegroundColor DarkYellow
} else {
    Copy-Item -Path $agentSrc -Destination $agentDest -Force
    $installed += "writing-analyzer.md"
    Write-Host "  [安装] writing-analyzer.md" -ForegroundColor Green
}

# ---- Step 3: 复制 Workshop 工程文件 ----
Write-Host "`n[Step 3/3] 复制 Workshop → $WorkshopPath" -ForegroundColor Yellow
New-Item -ItemType Directory -Path $WorkshopPath -Force | Out-Null

$workshopSrc = Join-Path $repoRoot "workshop"

# 复制所有文件（保留目录结构）
Copy-Item -Path (Join-Path $workshopSrc "*") -Destination $WorkshopPath -Recurse -Force

# 修正 knowledge-registry.json 中的路径
$registryPath = Join-Path $WorkshopPath "memory\knowledge-registry.json"
if (Test-Path $registryPath) {
    $registry = Get-Content $registryPath -Raw -Encoding UTF8
    $registry = $registry -replace '~\.config', "$env:USERPROFILE\.config"
    Set-Content -Path $registryPath -Value $registry -Encoding UTF8
    Write-Host "  [修正] knowledge-registry.json 路径" -ForegroundColor Green
}

Write-Host "  [完成] Workshop 已复制到 $WorkshopPath" -ForegroundColor Green

# ---- 完成摘要 ----
Write-Host ""
Write-Host "=== 安装完成 ===" -ForegroundColor Cyan
Write-Host "  Skills 安装: $($installed.Count) 个" -ForegroundColor Green
Write-Host "  Skills 跳过: $($skipped.Count) 个" -ForegroundColor DarkYellow
Write-Host "  Workshop 位置: $WorkshopPath" -ForegroundColor Cyan
Write-Host ""

# 生成卸载清单
$manifestPath = Join-Path $repoRoot "uninstall_manifest.txt"
@"
# 创意写作工作坊 — 卸载清单
# 由 install.ps1 生成于 $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# 删除以下文件/目录即可卸载
$skillTarget\close-reading-protocol
$skillTarget\mckee-story-analyzer
$skillTarget\story-writing-master-class
$skillTarget\burroway-narrative-craft
$skillTarget\becoming-a-writer
$skillTarget\kehuan-wenxue-lungang
$skillTarget\harvard-short-story
$skillTarget\beneath-the-iceberg
$skillTarget\unified-writing-theory
$skillTarget\das-kapital-knowledge-base
$skillTarget\marxist-political-economy
$agentTarget\writing-analyzer.md
"@ | Out-File -FilePath $manifestPath -Encoding utf8

Write-Host "提示：" -ForegroundColor Cyan
Write-Host "  1. 在 opencode 的新对话中，先加载workshop中的Agent文件："
Write-Host "     '请以 Writing Agent 的身份工作，加载 writing.md'"
Write-Host "  2. 取消安装请运行：Remove-Item -Path （Get-Content uninstall_manifest.txt） -Recurse -Force"
Write-Host "  3. 卸载清单已保存至：$manifestPath"


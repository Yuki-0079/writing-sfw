# 安装指南

## 前置条件

- **opencode**：已安装并可用（确保 `opencode` 命令在 PATH 中）
- **PowerShell 5.1+**：Windows 系统自带
- **Python 3.8+**：仅运行书籍拆解工具时需要

## 自动安装（推荐）

```powershell
git clone https://github.com/your-org/writing-sfw.git
cd writing-sfw
powershell -ExecutionPolicy Bypass -File install.ps1 -WorkshopPath "C:\你的工作目录\writing_sfw"
```

参数说明：
- `-WorkshopPath`：Workshop 工程文件的存放位置，默认当前目录下的 `writing_sfw`
- `-Force`：覆盖已安装的 skill（不指定则跳过已存在项）

## 手动安装

将仓库各部分复制到对应位置：

### 1. 安装 Skill

```powershell
# 将 skills/ 下的每个目录复制到 opencode skills 目录
$target = "$env:USERPROFILE\.config\opencode\skills"
Copy-Item -Path "skills\*" -Destination $target -Recurse
```

### 2. 安装 Writing Analyzer Agent

```powershell
$agentTarget = "$env:USERPROFILE\.config\opencode\agents\sfw"
New-Item -ItemType Directory -Path $agentTarget -Force
Copy-Item -Path "agents\sfw\writing-analyzer.md" -Destination $agentTarget -Force
```

### 3. 设置 Workshop

```powershell
# 复制到你的工作目录
$workshopPath = "C:\你的工作目录\writing_sfw"
Copy-Item -Path "workshop\*" -Destination $workshopPath -Recurse
```

### 4. 更新知识注册表路径

编辑 `$workshopPath\memory\knowledge-registry.json`，将 `~` 或绝对路径替换为实际路径。

## 验证安装

```powershell
# 1. 检查 skill 数量
$installed = Get-ChildItem "$env:USERPROFILE\.config\opencode\skills" -Directory
Write-Output "已安装 $($installed.Count) 个 skill"
Write-Output ($installed.Name -join ", ")

# 2. 检查 Agent
Test-Path "$env:USERPROFILE\.config\opencode\agents\sfw\writing-analyzer.md"

# 3. 检查 Workshop
Test-Path "C:\你的工作目录\writing_sfw\AGENTS.md"
```

## 卸载

```powershell
# 卸载所有本仓库安装的 skill（列在 uninstall_manifest.txt 中）
$manifest = Get-Content "uninstall_manifest.txt"
foreach ($item in $manifest) {
    Remove-Item -Path $item -Recurse -Force -ErrorAction SilentlyContinue
}
```

或逐个删除：

```powershell
$skills = @("close-reading-protocol","mckee-story-analyzer","story-writing-master-class",
            "burroway-narrative-craft","becoming-a-writer","kehuan-wenxue-lungang",
            "harvard-short-story","beneath-the-iceberg","unified-writing-theory",
            "das-kapital-knowledge-base","marxist-political-economy")
foreach ($s in $skills) {
    Remove-Item "$env:USERPROFILE\.config\opencode\skills\$s" -Recurse -Force -ErrorAction SilentlyContinue
}
Remove-Item "$env:USERPROFILE\.config\opencode\agents\sfw\writing-analyzer.md" -Force -ErrorAction SilentlyContinue
```

## 常见问题

**Q：install.ps1 提示权限错误？**
A：以管理员身份运行 PowerShell，或使用 `-ExecutionPolicy Bypass` 参数。

**Q：已有同名的 skill 会怎样？**
A：默认跳过（不覆盖），使用 `-Force` 参数强制覆盖。

**Q：需要修改 opencode 配置吗？**
A：不需要。Agent 和 Skill 自动注册。Workshop 中的 Agent 文件需要在你使用 opencode 时指定加载。


# 技能组装规范 v2

> 供子 agent 在接到模式 A Phase 4（技能组装）任务时读取。定义如何将 KB 打包为可安装的 skill。

---

## 0. 输入与输出

### 输入
- `wip/{book-slug}/knowledge-base.json`（完整 KB）
- `wip/{book-slug}/references/deep/`（深度分析文档）
- `wip/{book-slug}/overview.json`（框架坐标）

### 输出
SKILL.md + scripts/query_kb.ps1 + _meta.json → 安装到 skils 目录

安装路径：`~/.workbuddy/skills/{book-slug}/`

---

## 1. SKILL.md 模板

### 1.1 核心结构

```markdown
---
name: {skill-slug}
description: >
  {一句话描述，包含：基于什么书、覆盖什么内容、适合什么场景。}
---

# Skill: {显示名称}

> {副标题}

## 概述

本 skill 基于{作者}《{书名}》的结构化知识库，提供{领域}的{核心价值}。

### 核心定位

| 维度 | 说明 |
|:-----|:------|
| **领域** | `{domain}` |
| **方法论** | {method} |
| **分析粒度** | {granularity} |
| **理论刚性** | {rigidity} |
| **通用性** | {generality} |

### 知识库统计

| 指标 | 数值 |
|:-----|:----:|
| 知识条目 | **{N} 条** |
| 覆盖章节 | {覆盖情况} |
| 核心概念 | {N}+ 个 |
| 深度分析文档 | {N} 篇 |

---

## 核心概念体系

### {分类1}

| 概念 | 难度 | 关键要点 |
|:-----|:----:|:---------|
| {概念1} | {★☆☆} | {一句话} |
| {概念2} | {★★☆} | {一句话} |

### {分类2}

| 概念 | 难度 | 关键要点 |
|:-----|:----:|:---------|
...

---

## 使用指南

### 适用场景

| 场景 | 说明 |
|:-----|:------|
| {场景1} | {使用方法} |
| {场景2} | {使用方法} |

### 分析流程（如有）

```
{分析流程步骤}
```

### 深度阅读路径

```
{新手路径：3个核心概念}
{进阶路径：深入理论}
{应用路径：创作导向}
```

---

## 交叉参考

| 框架 | 对话方向 |
|:-----|:---------|
| {框架1} | {关联方式} |
| {框架2} | {关联方式} |

### 适用标签

```
#tag1
#tag2
```

---

## 查询方式

```powershell
# 查询知识库
scripts/query_kb.ps1 -Query "{概念名}"

# 按章节检索
scripts/query_kb.ps1 -Chapter "{章节名}"

# 列出所有概念
scripts/query_kb.ps1 -ListConcepts

# 显示帮助
scripts/query_kb.ps1 -Help
```

---

## 边缘情况处理

| 情况 | 处理方式 |
|:-----|:---------|
| {边缘情况1} | {处理方式} |
| {边缘情况2} | {处理方式} |
```

---

## 2. query_kb.ps1 模板

### 2.1 功能要求

必须支持以下查询模式：

| 参数 | 功能 | 示例 |
|:-----|:------|:------|
| `-Query` | 关键词搜索 text 和 concepts 字段 | `-Query "商品拜物教"` |
| `-Chapter` | 按章节筛选 | `-Chapter "第1章"` |
| `-ListConcepts` | 列出所有出现过的概念标签 | `-ListConcepts` |
| `-Help` | 显示帮助信息 | `-Help` |

### 2.2 概念映射（conceptMap）

脚本中必须内置该书的完整概念映射表：

```powershell
$conceptMap = @{
    # 核心概念
    "概念A" = @{
        "aliases" = @("别名1", "别名2")
        "related" = @("相关概念1", "相关概念2")
        "difficulty" = "★★☆"
        "entries" = @("dk-001", "dk-002")
    }
    "概念B" = @{
        "aliases" = @()
        "related" = @("概念A")
        "difficulty" = "★★★"
        "entries" = @("dk-015")
    }
}
```

### 2.3 基本结构

```powershell
param(
    [string]$Query = "",
    [string]$Chapter = "",
    [switch]$ListConcepts,
    [switch]$Help
)

# 路径设置
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$kbPath = Join-Path $scriptDir "..\references\knowledge-base.json"

# 概念映射
$conceptMap = @{ ... }

# 加载KB
$kb = Get-Content $kbPath -Raw | ConvertFrom-Json

# 查询逻辑
if ($Help) { ... }
if ($ListConcepts) { ... }
if ($Query) { ... }
if ($Chapter) { ... }
```

---

## 3. _meta.json 模板

```json
{
  "name": "{skill-slug}",
  "display_name": "{显示名称}",
  "author": "{作者}",
  "translator": "{译者（如有）}",
  "edition": "{版本信息}",
  "version": "1.0.0",
  "description": "{一句话描述}",
  "type": "knowledge-base",
  "domain": "{domain}",
  "framework_coords": {
    "domain": "{domain}",
    "method": "{method}",
    "granularity": "{granularity}",
    "rigidity": "{rigidity}",
    "generality": "{generality}"
  },
  "dependencies": {
    "close-reading-protocol": ">=1.0.0"
  },
  "tags": [
    "{标签1}",
    "{标签2}"
  ],
  "kb_stats": {
    "total_entries": {N},
    "chapter_coverage": "{覆盖情况}",
    "deep_docs": {N},
    "last_updated": "{YYYY-MM-DD}"
  }
}
```

---

## 4. 目录结构

组装完成后，`wip/{book-slug}/` 应形成以下结构：

```
wip/{book-slug}/
├── overview.json                ← Phase 1 产出
├── knowledge-base.json          ← Phase 2 产出
├── references/
│   └── deep/                    ← Phase 3 产出
│       ├── 01-concept-a.md
│       ├── 02-concept-b.md
│       └── ...
├── SKILL.md                     ← Phase 4 产出
├── scripts/
│   └── query_kb.ps1             ← Phase 4 产出
└── _meta.json                   ← Phase 4 产出
```

安装到 skill 目录后：

```
~/.workbuddy/skills/{book-slug}/
├── SKILL.md
├── references/
│   ├── knowledge-base.json
│   └── deep/
│       ├── 01-concept-a.md
│       └── ...
├── scripts/
│   └── query_kb.ps1
└── _meta.json
```

---

## 5. 自检清单

```
□ SKILL.md 是否包含完整的核心概念体系表格？
□ SKILL.md 是否有使用指南（适用场景 + 分析流程）？
□ SKILL.md 是否有交叉参考（至少 2 个其他框架）？
□ SKILL.md 是否有边缘情况处理？

□ query_kb.ps1 是否支持 -Query / -Chapter / -ListConcepts / -Help？
□ query_kb.ps1 的 conceptMap 是否覆盖了全部核心概念？
□ query_kb.ps1 的路径是否使用相对路径？

□ _meta.json 是否填写了所有字段？
□ _meta.json 的 framework_coords 是否与 overview.json 一致？
□ _meta.json 的 dependencies 是否填写？
□ _meta.json 的 tags 是否 ≥ 2 个？

□ knowledge-base.json 是否已从 wip/ 复制到 references/？
□ 深度分析文档是否已从 wip/ 复制到 references/deep/？

□ 目录结构是否符合规范？
□ 所有文件编码是否为 UTF-8？
```

---

## 6. 安装检查

安装完成后，执行以下验证：

```powershell
Test-Path "~/.workbuddy/skills/{book-slug}/SKILL.md"
Test-Path "~/.workbuddy/skills/{book-slug}/_meta.json"
Test-Path "~/.workbuddy/skills/{book-slug}/references/knowledge-base.json"
Test-Path "~/.workbuddy/skills/{book-slug}/scripts/query_kb.ps1"
```

全部通过 ✅ 则安装成功。

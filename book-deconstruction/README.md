# Book Deconstruction Engine

> 书籍→知识库转化引擎。将理论书籍按标准化流程拆解为结构化知识库 skill。

## 概述

这是一个用于将理论书籍（哲学、政治经济学、文化批判、创意写作理论等）转化为结构化知识库的 skill。它定义了完整的四阶段拆解流水线，从原始书籍文本到可安装的知识库 skill，支持跨会话断点续传和旧库升级重构。

### 三种工作模式

| 模式 | 功能 | 适用场景 |
|------|------|---------|
| **模式 A** | 处理新书（四阶段） | 有未处理的新书需要拆解为知识库 |
| **模式 B** | 重构旧库 | 为已有 KB 补充标注字段（confidence、scope_note 等） |
| **模式 C** | 组装主 skill | 将多个单书 KB 整合为跨框架分析系统 |

### 四阶段流水线（模式 A）

```
输入：一本书（PDF/EPUB/TXT）
    │
    ├── Phase 0: 预检
    │
    ├── Phase 1: 总览把握 → overview.json
    │   （加载 close-reading-protocol + overview-extraction.md）
    │
    ├── Phase 2: 逐章拆解 → knowledge-base.json
    │   （加载 close-reading-protocol + chapter-extraction.md）
    │   ← 核心阶段，知识条目 Schema v2 标注
    │
    ├── Phase 3: 专项提炼 → references/deep/*.md
    │   （加载 deep-analysis.md）
    │
    └── Phase 4: 技能组装 → SKILL.md + query_kb.ps1 + _meta.json
        （加载 skill-assembly.md）
              │
              ▼
输出：一个完整的知识库 skill
```

## 依赖

- **close-reading-protocol**：前置阅读协议，解决 LLM "Lost in the Middle" 问题，强制逐块精读 + 举证引用 + 自检复核

## 目录结构

```
book-deconstruction/
├── SKILL.md                              ← 主编排文件（角色定位 + 三种模式 + Schema 标准）
├── references/
│   ├── overview-extraction.md            ← Phase 1 规范（总览提取）
│   ├── chapter-extraction.md             ← Phase 2 规范（逐章拆解，核心）
│   ├── deep-analysis.md                  ← Phase 3 规范（专项提炼）
│   ├── skill-assembly.md                 ← Phase 4 规范（技能组装）
│   ├── batch-labeling.md                 ← 模式 B 规范（旧库重构）
│   └── flow-specification.md             ← 完整流水线规范
├── scripts/
│   ├── parse_epub.py                     ← EPUB 结构分析工具
│   ├── extract_chapters.py               ← EPUB 章节提取工具
│   └── requirements.txt                  ← 依赖说明
└── README.md                             ← 本文件
```

## 知识条目 Schema v2

```json
{
  "id": "book-slug-001",
  "domain": "political_economy | writing_craft | cultural_theory | ...",
  "chapter": "章节标题",
  "heading": "小节标题",
  "concepts": ["concept1", "concept2"],
  "text": "200-600字，基于原文的准确概括或引用",
  "confidence": "high | medium | low | contested",
  "scope_note": "适用范围和边界条件",
  "fiction_application": "理论→创作的桥接（可选）"
}
```

### 领域扩展字段

| domain | 扩展字段 |
|--------|---------|
| writing_craft | certainty, applicable_media, framework_bias_note |
| cultural_theory | critique_application, related_theorists |

## 支持的 Domain

| domain | 适用场景 |
|--------|---------|
| political_economy | 马克思主义政治经济学 |
| writing_craft | 创意写作技法 |
| cultural_theory | 文化理论/批判理论 |
| literary_theory | 文学理论/叙事学 |
| philosophy | 哲学 |
| sociology | 社会学 |
| political_theory | 政治理论 |
| history | 历史学 |
| psychology | 心理学 |
| mixed_theory | 跨学科理论 |

## 安装

### WorkBuddy

```bash
# 复制到用户级 skill 目录
cp -r book-deconstruction ~/.workbuddy/skills/
```

### 其他平台

将 `book-deconstruction/` 目录复制到目标平台的 skill 目录下即可。确保 `close-reading-protocol` skill 也已安装。

## 已产出知识库

本引擎已用于构建以下知识库体系：

### 左翼理论星图（14+ 组件，352+ 条目）

- 资本论三卷（168条）、德意志意识形态（20条）、西方马克思主义（21条）
- 资本主义现实主义（12条）、父权制与资本主义（55条）
- 齐泽克三部曲（75条）、德里达（20条）、亨廷顿（30条）等

### 创意写作理论星图（7+ 组件，2100+ 条目）

- 麦基《故事》《对白》《人物》（1828条）
- 特鲁比《故事写作大师班》（75条）、伯罗薇（71条）
- 布兰德（30条）、吴岩（53条）、盖利肖（24条）、谢开来（28条）

## 版本历史

- **v1.0** (2026-06-28)：从 OpenCode 迁移至 WorkBuddy，整合写作理论与左翼理论两套拆解流程的最优实践
  - chapter-extraction.md 采用优化版本（三层 text 结构、双模板 scope_note、扩展错误清单）
  - 脚本通用化（去除硬编码路径）
  - 路径适配 WorkBuddy

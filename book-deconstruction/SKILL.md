---
name: book-deconstruction
description: >
  书籍→知识库转化引擎。将理论书籍按标准化流程拆解为结构化知识库 skill，
  支持新书处理（四阶段）、旧库重构（标注升级）、主 skill 组装（跨框架整合）。
  适用于创意写作理论、左翼理论、文化批判、哲学等任何人文学科书籍。
  依赖 close-reading-protocol 执行前置阅读协议。
agent_created: true
---

# Book Deconstruction Engine v1

> 书籍→知识库转化引擎。将一本理论书籍拆解为结构化知识库 skill。

## 角色定位

你是专职的书籍→知识库转化引擎。核心职责有三项：

1. **处理新书（模式 A）**：将理论书籍按四阶段流程转化为结构化知识库 skill
2. **重构旧库（模式 B）**：为已有知识库条目补充标注字段（confidence、scope_note 等）
3. **组装主 skill（模式 C）**：将多个单书 KB 整合为统一的跨框架分析系统

## 依赖

- **close-reading-protocol**（必须前置加载）：解决 LLM "Lost in the Middle" 问题，强制逐块精读 + 举证引用 + 自检复核

## 核心参考文档

执行任务前，按需加载以下规范文件（位于本 skill 的 references/ 目录）：

| 文档 | 对应阶段 | 何时加载 |
|------|---------|---------|
| `references/overview-extraction.md` | Phase 1 | 模式 A 总览提取时 |
| `references/chapter-extraction.md` | Phase 2 | 模式 A 逐章拆解时（**核心规范**） |
| `references/deep-analysis.md` | Phase 3 | 模式 A 专项提炼时 |
| `references/skill-assembly.md` | Phase 4 | 模式 A 技能组装时 |
| `references/batch-labeling.md` | 模式 B | 旧库重构时 |
| `references/flow-specification.md` | 全流程 | 需要查看完整流水线规范时 |

---

## 工作模式

### 模式 A：处理新书（四阶段）

严格按阶段顺序执行，每阶段完成后清空上下文，结果写入文件。

#### Phase 0：预检

```
输入：目标书籍文件路径
检查：wip/{book-slug}/ 目录是否已存在
  已存在 → 检查 knowledge-base.json 是否已生成
    ├── 已有完整 KB → 标记完成，跳至 Phase 4
    └── 部分完成 → 从断点继续（读取 kb_checkpoint.json）
  不存在 → 进入 Phase 1
```

#### Phase 1：总览把握

```
输入：书籍的目录 + 序言 + 结语
加载：close-reading-protocol + references/overview-extraction.md

输出写入 wip/{book-slug}/overview.json：
{
  "title": "书名",
  "author": "作者",
  "translator": "译者",
  "domain": "political_economy | writing_craft | cultural_theory | ...",
  "structure_map": [...],
  "framework_coords": {
    "domain": "",
    "method": "",
    "granularity": "",
    "rigidity": "",
    "generality": "",
    "primary_method": ""
  },
  "candidate_concepts": ["概念1", "概念2", ...],
  "estimated_chapters_for_extraction": 0,
  "estimated_entry_count": ""
}

预估每章文本量 → 决定每 session 处理多少章
```

#### Phase 2：逐章拆解（核心阶段）

```
每章独立处理：

输入：章原文 + Phase 1 的 overview.json（摘要版）
加载：close-reading-protocol + references/chapter-extraction.md

执行：
1. 加载 close-reading-protocol，按逐块流程阅读本章
2. 提取知识条目，每条约 200-600 字
3. 按 Schema v2 标注所有字段
4. 追加到 wip/{book-slug}/knowledge-base.json

⚠️ 关键质量控制：
- text 必须包含"定义+例证+理论定位"三层结构
- text 写完后必须用 len() 确认字数（200字中文比想象中多）
- scope_note 必须同时说明适用范围和不适用/需调整的场景
- 禁止跳读、抽样读、只读首尾
```

#### Phase 3：专项提炼

```
输入：完整的 knowledge-base.json + overview.json
加载：references/deep-analysis.md

输出写入 wip/{book-slug}/references/deep/：
- 识别 KB 中出现频率最高的 3-8 个核心概念
- 每个概念写一个 .md 文件，含定义、判定标准、常见错误、交叉参照
```

#### Phase 4：技能组装

```
输入：wip/{book-slug}/ 下的所有产出
加载：references/skill-assembly.md

输出：
- SKILL.md
- scripts/query_kb.ps1（含该书的 conceptMap）
- _meta.json
- 将 knowledge-base.json 复制到 references/
- 将 deep/ 复制到 references/deep/

安装：移动到 ~/.workbuddy/skills/{book-slug}/
更新：memory/progress.md 标记为 ✅ 完成
```

---

### 模式 B：重构旧库（章节上下文感知 v2）

用于为已有知识库升级 schema。核心改进：**先读一章原文理解论述方向，再对该章所有条目做一致性标注**，而非靠关键词匹配。

加载 `references/batch-labeling.md` 执行完整流程。

**Checkpoint 系统**支持跨会话断点续传：
- `wip/patches/checkpoint.json` — 结构化进度清单
- `wip/patches/handoff_log.md` — 自然语言交接日志
- `wip/patches/chapter_context/{chapter}.context.json` — 上下文缓存

---

### 模式 C：组装主 skill（跨框架整合）

将多个单书 KB 整合为统一的跨框架分析系统。

**前置条件**：
1. 至少 2 本书的 KB 已完成并安装
2. 至少 1 个旧库已完成重构
3. `wip/master-skill/` 不存在或内容过期

**流程**：
- Phase C1：环境扫描 → prerequisites.json
- Phase C2：交叉参考文档（framework-comparison.md, debate-guide.md, medium-adaptation.md）
- Phase C3：主 SKILL.md 编写
- Phase C4：组装与安装

---

## Schema v2 标注标准

### 通用核心字段

```json
{
  "id": "{book-slug}-{NNN}",
  "domain": "political_economy | writing_craft | cultural_theory | ...",
  "chapter": "第X章 章名",
  "heading": "节标题",
  "concepts": ["概念标签1", "概念标签2"],
  "text": "200-600字，基于原文的准确概括或引用",
  "confidence": "high | medium | low | contested",
  "scope_note": "适用范围和边界条件",
  "fiction_application": "如何用于创作实践或理论分析"
}
```

### confidence 判定标准

| 等级 | 定义 |
|------|------|
| high | 普遍共识、基本原理、事实性信息 |
| medium | 主流接受但依赖语境 |
| low | 个人观点、推测性、尚待验证 |
| contested | 学术界有直接争议 |

### 领域扩展字段

| domain | 扩展字段 |
|--------|---------|
| writing_craft | certainty, applicable_media, framework_bias_note |
| cultural_theory | critique_application, related_theorists |

完整规范见 `references/chapter-extraction.md`。

---

## Domain 值域表

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

---

## 文本提取工具

| 格式 | 提取方法 |
|------|----------|
| PDF | 用 Read 工具直接读取 |
| EPUB | 用 `scripts/parse_epub.py` 或 `scripts/extract_chapters.py` 提取 |
| txt/md | 直接读取 |

OCR 需求：扫描版 PDF 需先 OCR 转为文本，再进入拆解流程。

---

## 输出目录约定

```
books/                          ← 原始书籍文件（只读）
wip/{book-slug}/                ← 工作进度目录
   overview.json                ← Phase 1 产出
   knowledge-base.json          ← Phase 2 产出
   kb_checkpoint.json           ← Phase 2 断点续传
   references/deep/*.md         ← Phase 3 产出
   SKILL.md                     ← Phase 4 产出
   scripts/query_kb.ps1         ← Phase 4 产出
   _meta.json                   ← Phase 4 产出

~/.workbuddy/skills/{book-slug}/   ← 最终安装位置
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

## 上下文控制规则

| 规则 | 说明 |
|------|------|
| 阶段隔离 | 每阶段完成后清空上下文，结果写入文件 |
| 模板预加载 | 条目格式、标注标准写在提示词中 |
| 大章拆分 | 单章超过 3000 字时分多次处理，中间通过临时文件传递 |
| 断点续传 | Phase 2 中断后，读取 `wip/{book-slug}/kb_checkpoint.json` 恢复 |

---

## 进度自检

每次启动时，执行以下检查：

```
1. 读取 memory/progress.md → 了解当前进度
2. 扫描 books/ 目录 → 列出所有原始书籍
3. 读取 wip/{book-slug}/knowledge-base.json → 检查各书 KB 完成状态
4. 检查 ~/.workbuddy/skills/ → 已安装的 KB skill
5. 如果模式 B 正在进行中：读取 wip/patches/checkpoint.json
6. 汇总状态输出给用户
```

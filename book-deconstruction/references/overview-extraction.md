# 总览提取规范 v2

> 供子 agent 在接到模式 A Phase 1（总览把握）任务时读取。定义如何提取书籍结构图谱、框架坐标、候选概念。

---

## 0. 输入与输出

### 输入
- 书籍的目录（TOC）
- 序言/导言
- 结语/后记
- 任何综括性章节

### 输出
写入 `wip/{book-slug}/overview.json`，完整结构见下方第 1 节。

---

## 1. 输出格式

```json
{
  "title": "书名（完整标题）",
  "author": "作者",
  "translator": "译者（如有）",
  "edition": "版本信息",
  "domain": "书籍所属理论领域",
  "total_pages": 0,
  "estimated_total_chars": 0,

  "structure_map": [
    {
      "part": "篇名（如有）",
      "chapters": [
        {
          "num": 1,
          "title": "第一章标题",
          "sections": ["节标题1", "节标题2"]
        }
      ]
    }
  ],

  "prefaces": ["序言1标题", "序言2标题"],

  "framework_coords": {
    "domain": "",
    "method": "",
    "granularity": "",
    "rigidity": "",
    "generality": "",
    "primary_method": ""
  },

  "candidate_concepts": ["概念1", "概念2"],

  "estimated_chapters_for_extraction": 0,
  "estimated_entry_count": "",
  "notes": ""
}
```

---

## 2. 字段说明

### 2.1 基础元信息

| 字段 | 规则 |
|:-----|:------|
| `title` | 完整书名，含副标题 |
| `author` | 作者全名 |
| `translator` | 译者（翻译作品必填） |
| `edition` | 版本/出版社/年份信息 |
| `domain` | 从 Domain 值域表中选择最匹配的一个 |
| `total_pages` | PDF 或原书总页数 |
| `estimated_total_chars` | 预估总字数 |

### 2.2 Domain 值域表

| domain | 适用场景 |
|:-------|:---------|
| `political_economy` | 马克思主义政治经济学 |
| `writing_craft` | 创意写作技法 |
| `cultural_theory` | 文化理论/批判理论 |
| `literary_theory` | 文学理论/叙事学 |
| `philosophy` | 哲学（本体论/认识论/伦理学） |
| `sociology` | 社会学 |
| `political_theory` | 政治理论 |
| `history` | 历史学 |
| `linguistics` | 语言学 |
| `psychology` | 心理学 |
| `mixed_theory` | 跨学科理论（无法归入单一域时使用） |

### 2.3 structure_map（结构图谱）

以目录为主要依据，按书籍实际结构组织：

```json
{
  "part": "篇名（如有篇，否则省略）",
  "chapters": [
    {
      "num": 1,
      "title": "第一章 标题",
      "sections": ["节1", "节2", "节3"]  // 如果有节级标题
    },
    {
      "num": 2,
      "title": "第二章 标题"
      // sections 可选，无节级标题时省略
    }
  ]
}
```

**规则：**
- 保留作者原有的篇/章/节层级
- 章号用数字，篇名用字符串
- 不省略任何章节（所有章节都要列出来）
- 序言、附录、注释等独立成章的内容也需列出

### 2.4 prefaces（序言/导言列表）

列出所有序言、导言、前言、跋等辅助性文字。

```json
"prefaces": ["第一版序言", "第二版跋", "法文版序言"]
```

### 2.5 framework_coords（框架坐标）

描述本书作为分析工具的理论坐标：

```json
{
  "domain": "political_economy",
  "method": "dialectical_materialism",
  "granularity": "concept → category → law → tendency",
  "rigidity": "systematic",
  "generality": "broad",
  "primary_method": "抽象力（Abstraktionskraft）代替显微镜和化学试剂"
}
```

| 坐标 | 说明 | 可选值 |
|:-----|:------|:--------|
| `domain` | 理论领域 | 见 Domain 值域表 |
| `method` | 核心方法论 | 自述性质，用作者的表述 |
| `granularity` | 分析粒度（由细到粗） | `concept→category→law→tendency` / `scene→sequence→act→whole` / ... |
| `rigidity` | 理论刚性 | `prescriptive`（规定性）/ `descriptive`（描述性）/ `systematic`（系统性）/ `dialectical`（辩证性） |
| `generality` | 通用性 | `narrow`（专精领域）/ `medium`（跨领域部分适用）/ `broad`（多领域可迁移） |
| `primary_method` | 独特的分析方法 | 作者特有的方法论工具 |

### 2.6 candidate_concepts（候选概念）

列出书中出现的全部重要概念，作为后续 Phase 2 拆解的概念标签参考。

- 从目录、序言、索引中提取
- 每个概念用原文术语
- 按出现顺序排列
- 数量不限，但 ≥ 20 个（太少说明没找全）

### 2.7 工作量预估

| 字段 | 说明 |
|:-----|:------|
| `estimated_chapters_for_extraction` | 需要拆解的章节数（包含序言等，不含附录/索引） |
| `estimated_entry_count` | 预估条目数，如"200-300（高颗粒度）"或"60-80" |
| `notes` | 特殊情况说明，如"核心章节密度加倍"、"图片版PDF需OCR"等 |

---

## 3. 自检清单

```
□ 所有章节是否都已列出？不含遗漏？
□ 框架坐标是否完整填写了所有维度？
□ candidate_concepts 是否 ≥ 20 个？
□ domain 是否与书籍实际内容匹配？
□ 如果有译者信息，是否已填写？
□ 如果有篇层级（part），是否正确反映了结构？
```

---

## 4. 输出写入规范

返回 JSON 给主 agent，主 agent 负责写入文件。

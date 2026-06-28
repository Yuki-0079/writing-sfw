# 批量标注规范 v2 - 旧库重构（模式B）

> 供子 agent 在接到模式 B（旧库重构/补充标注字段）任务时读取。定义分组处理流程、全局判断规则、补丁格式、缓存规范。

---

## 0. 核心原则

**先读一章原文理解论述方向，再对该章所有条目做一致性标注**，而非靠关键词匹配。

---

## 1. 数据基础

### 待处理数据结构

```json
[
  {
    "_index": 15,
    "id": "mk-015",
    "chapter": "第7章 故事设计术语",
    "heading": "节标题",
    "concepts": ["概念1", "概念2"],
    "text": "...",
    // 以下为需补充的字段：
    "certainty": null,           // ← 待填
    "applicable_media": null,    // ← 待填
    "framework_bias_note": null  // ← 待填
  }
]
```

### TOC 索引结构

```json
{
  "text/part0013.html": {
    "chapter_file": "0007.txt",
    "heading": "故事设计术语"
  }
}
```

---

## 2. 分组流程

### Step 1：分组

按 `file` 字段将条目分组。

```
分组依据：entry.file 的值
分组大小：大组 ≥ 10 条，小组 < 10 条
```

### Step 2：定位上下文

查 TOC 索引，找到该 part 对应的 chapter 文件和 heading。

```json
{
  "file": "text/part0013.html",
  "chapter": "0007.txt",
  "heading": "故事设计术语"
}
```

### Step 3：检查上下文缓存

检查 `{workdir}/chapter_context/{chapter}.context.json` 是否存在：

- ✅ 存在 → 读取缓存中的全局判断，跳过原文阅读
- ❌ 不存在 → 进入 Step 4 精读原文

### Step 4：精读原文（仅缓存未命中时）

按文件大小分策略：

| 文件大小 | 阅读策略 |
|:---------|:---------|
| ≤ 15 KB | 全文一次精读（按 close-reading-protocol 分块） |
| 15-50 KB | 按自然段落分块（每块 ≤ 5 KB），分 2-4 步读完 |
| > 50 KB | 读 TOC 估算当前 part 在 chapter 中的范围，只读相关段落 |

读完输出 3 个全局判断：

```json
{
  "nature": "介绍历史/共识 | 麦基个人但有业界共识 | 麦基特有理论建构",
  "certainty_mode": "high | medium | debatable",
  "media_mode": "film | novel | hybrid | film+novel",
  "bias_note_template": "本章基于[具体语境]，该主张在[非默认媒介]需适配"
}
```

### Step 5：写入缓存

```json
{
  "chapter_file": "0007.txt",
  "heading": "故事设计术语",
  "analysis": {
    "nature": "麦基特有理论建构（故事三角）",
    "certainty": "debatable",
    "media": "film",
    "bias_note": "本章基于经典好莱坞叙事传统讨论三维人物..."
  },
  "part_files_covered": ["text/part0013.html", "text/part0014.html"]
}
```

### Step 6：标注该组所有条目

基于全局判断，该组全部条目采用一致性标注。

**允许拆分标注的情况：**
- 组内混合了理论性条目和例证性条目
- 组内跨多个子话题，每个子话题的媒介假设不同
- 拆分时必须在补丁中备注理由

### Step 7：输出补丁

```json
[
  {
    "_index": 15,
    "certainty": "debatable",
    "applicable_media": ["film"],
    "framework_bias_note": "本章基于经典好莱坞叙事传统..."
  },
  {
    "_index": 16,
    "certainty": "debatable",
    "applicable_media": ["film"],
    "framework_bias_note": "本章基于经典好莱坞叙事传统..."
  }
]
```

### Step 8：更新 Checkpoint

追加到 `completed` 列表，从 `queued` 中移除该组，更新 `stats`。

---

## 3. 全局判断规则

### 3.1 certainty 判定（基于整章理解）

| 判定 | 含义 | 判断依据 |
|:-----|:------|:---------|
| `high` | 普遍认可的原理 / 历史事实 | 本章陈述的是基本创作原理或介绍其他理论家的共识观点 |
| `medium` | 主流但有个人倾向 | 作者的主流但有个人倾向的观点，多数人会认同但非铁律 |
| `debatable` | 作者特有理论建构 | 作者独创的理论范畴（如故事三角、节拍序列体系、鸿沟原理等） |

### 3.2 applicable_media 判定

| 取值 | 判定依据 | 文本触发特征 |
|:-----|:---------|:-------------|
| `["film"]` | 例证以电影为主 | "银幕""观众""2小时""镜头""电影" |
| `["novel"]` | 例证以小说为主 | "读者""章节""页码""小说" |
| `["tv"]` | 例证以电视剧为主 | "剧集""季""每周""分集" |
| `["film", "novel"]` | 两者兼有 | 混合举例 |
| `["hybrid"]` | 纯理论探讨，无特定媒介 | 不依赖特定媒介假设 |

### 3.3 framework_bias_note 撰写

**仅用于 certainty 为 medium 或 debatable 的条目。**

格式：
> 该主张基于[具体前提/媒介假设]。在[适用条件]时需要调整/适配。

示例：
> 该主张基于经典好莱坞叙事传统。在小情节或反情节作品中，激励事件可能被弱化或完全缺失。

---

## 4. 小组处理规则

小组（< 10 条）多为目录、索引、译注等非正文内容。

| 内容类型 | certainty | applicable_media |
|:---------|:----------|:-----------------|
| 目录 | `high` | `["hybrid"]` |
| 索引 | `high` | `["hybrid"]` |
| 译注 | `medium` | `["hybrid"]` |
| 参考书目 | `high` | `["hybrid"]` |
| 附录（正文延伸） | 视内容性质与所属章一致 | 视内容性质 |

---

## 5. Checkpoint 系统格式

### checkpoint.json

```json
{
  "target_lib": "{库名}",
  "lib_path": "{skils路径}",
  "pipeline": {
    "total_groups": 74,
    "completed": [
      {
        "file": "text/part0013.html",
        "size": 103,
        "chapter": "0007.txt",
        "heading": "故事设计术语",
        "certainty_mode": "debatable",
        "media_mode": "film",
        "done": true
      }
    ],
    "in_progress": null,
    "queued": ["text/part0014.html", "text/part0015.html"],
    "next": {
      "file": "text/part0014.html",
      "size": 80,
      "chapter": "0007.txt",
      "note": "同一章已读过→直接用缓存，无需重读"
    }
  },
  "stats": {
    "groups_done": 1,
    "entries_done": 103,
    "entries_total": 1828
  }
}
```

### handoff_log.md

```markdown
# 旧库重构进度日志

## 会话 N (YYYY-MM-DD)
- 完成：{part文件}（{N}条）→ {chapter文件}「{标题}」
- 上下文缓存：{chapter文件}.context.json（已保存/已命中）
- 下一组：{下一part文件}（{N}条）→ {下一chapter文件}
- 当前进度：{N}/{总组数} 组（{N}/{总条目} 条 = {百分比}%）
```

---

## 6. 自检清单

```
□ 是否已检查上下文缓存？（避免重复读原文）
□ 是否先读原文再标注？（避免关键词猜测）
□ 全局判断的 certainty 是否基于本章整体论述性质？
□ 全局判断的 media 是否基于本章主要例证媒介？
□ 该组内所有条目的标注是否一致？
□ 如果拆分标注，是否在补丁中备注了理由？

□ framework_bias_note 是否仅用于 medium/debatable？
□ framework_bias_note 的格式是否符合模板？

□ 补丁中是否有 _index 字段？（用于定位原 KB 条目）
□ 补丁是否仅包含 certainty / applicable_media / framework_bias_note 三个字段？

□ checkpoint.json 是否已更新 completed / queued / stats？
□ handoff_log.md 是否已追加新日志？
□ 上下文缓存是否已写入 chapter_context/？
```

---

## 7. 新对话接手流程

```
1. 读取 memory/progress.md → 了解重构处于进行中
2. 读取 checkpoint.json → 精确知道完成/待办
3. 读取 handoff_log.md → 了解会话历史
4. 读取 chapter_context/ → 检视可用缓存
5. 从 queued 中取第一个未完成组，检查缓存后开始处理
6. 完成后更新 checkpoint.json + handoff_log.md
```

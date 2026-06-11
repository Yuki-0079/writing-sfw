# 创意写作工作坊 · 项目架构快照

> 生成日期：2026-05-27
> 用途：新对话初始化时读取此文件可快速恢复项目全貌

---

## 一、项目总览

这是一个**创意写作辅助系统**，核心资产是从创意写作书籍中提取的结构化知识库。系统由三个 Agent 协作组成：书籍拆解师（处理书籍→知识库）、Writing Agent（创作）、Editor Agent（质检）。

### 核心文件

| 文件 | 用途 |
|------|------|
| `writing.md` | Writing Agent 定义 |
| `editor.md` | Editor Agent 定义 |
| `书籍拆解师.md` | 书籍拆解师 Agent 定义 |
| `操作指引.md` | 新对话上手文档 |
| `AGENTS.md` | 三 Agent 协作规则 |
| `memory/progress.md` | 进度追踪 |
| `memory/project-snapshot.md` | **本文** 项目架构快照 |

---

## 二、已安装的 Skill（知识库）

### 核心工具技能
- `close-reading-protocol` — 严谨阅读协议（所有深度分析前必须加载）
- `the-storytellers-workbench` — 文学工艺打磨
- `novel-writer-engine` — 小说生产流水线
- `writing-style-iterator` — 写作风格学习

### 创意写作知识库（共7个，2100+条）

| slug | 书名 | 条目 | 核心贡献 | 框架坐标 |
|------|------|:----:|---------|---------|
| `mckee-story-analyzer` | 麦基《故事》《对白》《人物》 | 1828 | 故事结构/人物设计/场景设计（film基准） | prescriptive, film, scene→act |
| `story-writing-master-class` | 特鲁比《故事写作大师班》 | 75 | 22步结构/角色网络/道德论点（长篇系统） | prescriptive, hybrid, sequence→act |
| `burroway-narrative-craft` | 伯罗薇《小说写作：叙事技巧指南》 | 71 | 展现与讲述/对话/视角/人物刻画 | descriptive, novel, sentence→scene |
| `becoming-a-writer` | 布兰德《成为作家》 | 30 | 双重人格/无意识协同/定时写作 | descriptive, hybrid, whole |
| `kehuan-wenxue-lungang` | 吴岩《科幻文学论纲》 | 53 | 作家簇/权力分析/科幻边缘性 | descriptive, hybrid, whole |
| `harvard-short-story` | 盖利肖《哈佛短篇小说写作指南》 | 24 | 兴趣法则/场景五步骤/短篇技法 | prescriptive, novel, scene→whole |
| `beneath-the-iceberg` | 谢开来《在幻想的冰山下》 | 28 | 多体裁文本系统/架空世界/社会化生产 | descriptive, hybrid, whole |

### 跨框架主 Skill
- `unified-writing-theory` — **创意写作理论星图**（整合上述7个库的跨框架分析系统）
  - 包含 3 份交叉参考文档（媒介适配、框架关系、争议指南）
  - 包含跨库查询脚本

### 旧库重构状态
- `mckee-story-analyzer`: 1828条，v2章节上下文感知标注 ✅ 已完成（74/74组100%）

---

## 三、已处理的书籍（8本完成）

| 书名 | 作者 | 格式 | 条目 | 安装为 |
|------|------|:----:|:----:|--------|
| 故事写作大师班 | 特鲁比 | epub | 75 | `story-writing-master-class` |
| 小说写作：叙事技巧指南（第十版） | 伯罗薇 | epub | 71 | `burroway-narrative-craft` |
| 成为作家 | 布兰德 | epub | 30 | `becoming-a-writer` |
| 科幻文学论纲 | 吴岩 | epub | 53 | `kehuan-wenxue-lungang` |
| 哈佛短篇小说写作指南 | 盖利肖 | epub | 24 | `harvard-short-story` |
| 在幻想的冰山下（欧美奇幻文学） | 谢开来 | epub | 28 | `beneath-the-iceberg` |

## 四、未处理的书籍（7本待办）

| 书名 | 作者 | 格式 | 大小 | 备注 |
|------|------|:----:|:----:|:-----|
| 开始写吧！——虚构文学创作 | 艾利斯 | epub | 4.8MB | 写作练习集 |
| 开始写吧！影视剧本创作 | 艾利斯 | epub | 1.3MB | 剧本方向 |
| 开始写吧：非虚构文学创作 | 艾利斯 | epub | 1.2MB | 非虚构方向 |
| 开始写吧!-科幻，奇幻，惊悚小说 | — | pdf | 43MB | ⛔ 图片PDF不能处理 |
| 在幻想的冰山下 | 谢开来 | epub | 1.97MB | ✅ 已处理 |

## 五、工作目录结构

```
C:\Opencode\writing_sfw/
├── books/                    ← 原始书籍文件（只读）
├── wip/                      ← 各书处理进度
│   ├── 故事写作大师班/          ✅ 完成
│   ├── 小说写作：叙事技巧指南/  ✅ 完成
│   ├── 成为作家/              ✅ 完成
│   ├── 科幻文学论纲/          ✅ 完成
│   ├── 哈佛短篇小说写作指南/    ✅ 完成
│   ├── 在幻想的冰山下/        ✅ 完成
│   ├── master-skill/         ✅ 主skill组装完成
│   └── patches/              ← mckee重构补丁
├── memory/                   ← 进度追踪+记忆
│   ├── progress.md           ← 主进度文件
│   ├── project-snapshot.md   ← 本文
│   └── archive/              ← 归档的旧数据
├── writing.md                ← Writing Agent
├── editor.md                 ← Editor Agent
├── 书籍拆解师.md                ← 书籍拆解师 Agent
├── 操作指引.md                  ← 上手文档
├── AGENTS.md                 ← 协作规则
└── 书籍知识库构建流程规范.md      ← 流程规范
```

## 六、关键决策记录

1. **知识库 Schema**：所有新库采用统一的 `certainty/applicable_media/framework_bias_note` 标注体系
2. **主 Skill 设计**：采用"感知层→多视角诊断→辨析模式→三语气"四层架构，不预加载所有 KB
3. **旧库重构策略**：mckee 采用 v2"先读一章原文再标注该章所有条目"的策略，而非 v1 的纯正则批处理
4. **书籍选择优先级**：短篇技法 > 奇幻理论 > 剧本 > 非虚构

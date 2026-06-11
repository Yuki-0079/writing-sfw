# 创意写作工作坊 · Writing Workshop

基于多本创意写作经典的结构化知识库系统，无缝集成 [opencode](https://opencode.ai) 的 Agent + Skill 架构。

## 系统架构

```
用户需求 → [Writing Analyzer] → 标签分析 → 知识注册表匹配 → 加载对应 Skill
                              ↕
               Writing Agent ↔ Editor Agent（创作与质检分离）
                              ↕
              书籍拆解师（书籍→结构化知识库转化）
```

### 三大组件

| 组件 | 位置 | 说明 |
|------|------|------|
| **Workshop**（工程文件） | 用户工作目录 | `AGENTS.md` + 3 个 Agent 定义 + 知识注册表 + 操作指引 |
| **Skills**（知识库） | `~/.config/opencode/skills/` | 11 个知识库/工具 skill，**2100+ 条**结构化知识条目 |
| **Writing Analyzer**（分析 Agent） | `~/.config/opencode/agents/sfw/` | 标签路由驱动的多维创作分析 |

### 标签路由系统（4 维度 × 41 标签）

```
craft_*    写作技法（11子类）    → 结构/人物/对白/场景/视角/文笔/节奏…
world_*    世界观构建（9子类）   → 经济/政治/社会/文化/技术/生态…
domain_*   学科理论（9子类）    → 经济学/政治学/哲学/社会学/心理学…
genre_*    文学类型（12子类）   → 科幻/奇幻/赛博朋克/反乌托邦/纯文学…
```

## 已包含的 Skill

### 创意写作知识库（7 本书，2100+ 条）

| Skill | 来源书 | 条目 | 核心贡献 |
|-------|--------|:----:|----------|
| `mckee-story-analyzer` | 麦基《故事》《对白》《人物》 | 1828 | 故事结构/人物设计/场景设计 [来源](https://github.com/huaigu17/Mckee-Story-Analyzer) |
| `story-writing-master-class` | 特鲁比《故事写作大师班》 | 75 | 22步结构/角色网络/道德论点 |
| `burroway-narrative-craft` | 伯罗薇《小说写作：叙事技巧指南》 | 71 | 展现与讲述/对话/视角 |
| `becoming-a-writer` | 布兰德《成为作家》 | 30 | 双重人格/定时写作/创作心理 |
| `kehuan-wenxue-lungang` | 吴岩《科幻文学论纲》 | 53 | 作家簇理论/科幻边缘性 |
| `harvard-short-story` | 盖利肖《哈佛短篇小说写作指南》 | 24 | 兴趣法则/场景五步骤 |
| `beneath-the-iceberg` | 谢开来《在幻想的冰山下》 | 28 | 架空世界/多体裁文本系统 |

### 元 Skill 与世界观构建

| Skill | 说明 |
|-------|------|
| `unified-writing-theory` | 整合 7 库的跨框架分析系统，支持多视角诊断与辨析 |
| `das-kapital-knowledge-base` | 马克思《资本论》第一卷结构化知识库（61条+5篇深度分析） |
| `marxist-political-economy` | 政治经济学多卷扩展 skill |
| `close-reading-protocol` | 严谨阅读协议（所有深度分析的前置依赖） |

## 快速安装

```powershell
# 前置条件：已安装 opencode + PowerShell 5.1+
git clone https://github.com/your-org/writing-sfw.git
cd writing-sfw
powershell -ExecutionPolicy Bypass -File install.ps1
```

安装脚本会自动：
1. 复制 11 个 skill 到 `~/.config/opencode/skills/`
2. 复制 Writing Analyzer 到 `~/.config/opencode/agents/sfw/`
3. 复制 Workshop 工程文件到指定目录
4. 重写知识注册表中的路径为本机路径

## 快速使用

```text
"请以 Writing Agent 的身份工作，加载 writing.md。"
"请以 Editor Agent 的身份工作，加载 editor.md。"
"请以书籍拆解师的身份工作。先读操作指引.md，执行进度自检。"
"请分析这段小说的场景设计。"          → Writing Analyzer 自动标签路由
"帮我诊断这个角色的动机是否充分。"    → 自动匹配 mckee + unified-writing-theory
"设计一个赛博朋克世界的经济体系。"    → 自动匹配 economic-systems + das-kapital
```

## 书籍拆解师指南

如果你想扩展自己的知识库，`书籍拆解师指南/` 目录包含完整的拆书方法论：
- 标准化的书籍→知识库转化流程（四阶段）
- EPUB 提取工具
- 标签路由系统设计说明

## 致谢

- **麦基知识库原始项目** — [Mckee-Story-Analyzer](https://github.com/huaigu17/Mckee-Story-Analyzer) by [@huaigu17](https://github.com/huaigu17)
- **opencode** — Agent/Skill 框架
- **John Truby, Janet Burroway, Dorothea Brande, John Gallishaw, Robert McKee, 吴岩, 谢开来** — 被拆解书籍的作者
- **Karl Marx** — 《资本论》知识库的理论基础




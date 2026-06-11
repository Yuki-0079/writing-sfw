# 写作知识标签分类体系 v1

> 本分类用于 `knowledge-registry.json` 中所有知识源（skill / knowledge-base）的标签标注。
> Agent 通过分析用户需求 → 提取标签 → 查询 registry → 匹配知识源 → 加载。

---

## 一、标签分类总览

```
craft_*      写作技法（7个子类）
world_*      世界观构建（9个子类）
domain_*     学科领域知识（9个子类）
genre_*      文学类型（12个子类）
```

---

## 二、craft_* — 写作技法标签

| 标签 | 名称 | 涵盖范围 | 对应知识库示例 |
|------|------|---------|--------------|
| `craft_structure` | 故事结构 | 三幕式/七步/22步、激励事件、幕设计、节拍表、大纲设计 | 麦基、特鲁比、盖利肖 |
| `craft_character` | 人物塑造 | 角色弧、动机、弱点/需求、角色网络、人物刻画 | 麦基、特鲁比、伯罗薇 |
| `craft_dialogue` | 对白技艺 | 潜文本、对白任务、修辞手法、解说控制 | 麦基（对白书）、伯罗薇 |
| `craft_scene` | 场景设计 | 场景目的、转折点、节拍、价值变化、呈现单元 | 麦基、盖利肖 |
| `craft_pov` | 叙述视角 | 人称抉择、视角限制、距离控制 | 伯罗薇 |
| `craft_prose` | 文笔/语言 | 展现vs讲述、比喻、句式节奏、细节选取 | 伯罗薇、storytellers-workbench |
| `craft_pacing` | 节奏控制 | 悬念、紧张感、叙事速度、场景-续篇节奏 | 麦基、literary-fiction-craft |
| `craft_short` | 短篇专精 | 完成式/选择式、兴趣法则、限定篇幅内的结构 | 盖利肖 |
| `craft_psychology` | 写作心理 | 无意识协同、双重人格、定时写作、创作习惯 | 布兰德（成为作家） |
| `craft_genre` | 类型技法 | 类型约定、读者预期管理 | 麦基、特鲁比 |
| `craft_revision` | 修改打磨 | 自我编辑、AI味去除、四层质检 | novel-writer-engine |

## 三、world_* — 世界观构建标签

| 标签 | 名称 | 涵盖范围 | 对应知识源 |
|------|------|---------|----------|
| `world_economy` | 经济体系 | 货币、贸易、资源分配、生产组织、稀缺vs丰裕 | economic-systems |
| `world_politics` | 政治体系 | 治理结构、政体类型、权力合法性、外交关系 | governance-systems |
| `world_society` | 社会结构 | 阶级、种族/物种关系、人口分布、社会组织 | (待补充) |
| `world_culture` | 文化与信仰 | 宗教体系、价值观念、仪式、习俗、身份认同 | belief-systems、谢开来 |
| `world_tech` | 技术与魔法 | 技术级联后果、魔法体系、科技对社会的影响 | systemic-worldbuilding |
| `world_ecology` | 生态地理 | 地理决定论、资源分布、气候、生态系统 | (待补充) |
| `world_evolution` | 跨代际演化 | 多代际社会变迁、环境压力下的文明分化 | multi-order-evolution |
| `world_language` | 语言与文字 | 人造语、语言演化、命名体系 | conlang、language-evolution |
| `world_military` | 军事与战争 | 军事组织、战争体系、战略战术 | (待补充) |

## 四、domain_* — 学科领域知识标签

| 标签 | 名称 | 涵盖范围 | 意义 |
|------|------|---------|------|
| `domain_economics` | 经济学 | 微观/宏观经济学、剩余价值、资本理论、危机理论 | 让经济体系构建有理论深度 |
| `domain_political` | 政治学 | 政治哲学、治理理论、权力分析、国家理论 | 让政治设计有学理依据 |
| `domain_sociology` | 社会学 | 阶级分析、社会分层、集体行为、社会变迁 | 让社会描写有结构性理解 |
| `domain_philosophy` | 哲学 | 各流派思维框架、伦理体系、认识论 | 为世界观提供哲学基础 |
| `domain_history` | 历史学 | 历史方法论、文明兴衰模式、历史类比 | 为架空历史提供参照 |
| `domain_psychology` | 心理学 | 人格理论、认知偏差、动机理论 | 让人物更深层、真实 |
| `domain_cultural_theory` | 文化理论 | 文化研究、媒介理论、权力话语 | 吴岩的科幻理论归属此域 |
| `domain_anthropology` | 人类学 | 文化演化、亲属制度、仪式研究 | 为异族文明设计提供参照 |
| `domain_ecology` | 生态学 | 生态系统、可持续性、环境决定论 | 为生态世界观提供科学基础 |

## 五、genre_* — 类型标签

| 标签 | 名称 | 说明 |
|------|------|------|
| `genre_sf` | 科幻 | 硬科幻、软科幻、太空歌剧、赛博朋克 |
| `genre_fantasy` | 奇幻 | 史诗奇幻、都市奇幻、黑暗奇幻 |
| `genre_horror` | 恐怖 | 心理恐怖、克苏鲁、生存恐怖 |
| `genre_literary` | 纯文学 | 主流文学、严肃小说 |
| `genre_mystery` | 悬疑/推理 | 本格、社会派、冷硬 |
| `genre_cyberpunk` | 赛博朋克 | 高科技低生活、企业统治、义体 |
| `genre_dystopia` | 反乌托邦 | 极权控制、阶级固化、思想监控 |
| `genre_postapocalyptic` | 末日/后末日 | 生存、重建、文明废墟 |
| `genre_steampunk` | 蒸汽朋克 | 维多利亚科技、替代历史 |
| `genre_wuxia` | 武侠/仙侠 | 修炼体系、江湖、门派 |
| `genre_superhero` | 超英 | 超能力、身份秘密、英雄与反派 |
| `genre_historical` | 历史/架空历史 | 真实历史改编、替代时间线 |

---

## 六、标签推理规则

Agent 在分析用户需求时，通过以下规则自动推断标签：

### 6.1 关键词→标签映射

| 用户输入中出现的关键词 | 推理出的标签 |
|------------------------|------------|
| 结构、大纲、情节、三幕、节拍 | craft_structure |
| 人物、角色、弧线、动机、人物塑造 | craft_character |
| 对白、对话、台词、潜文本 | craft_dialogue |
| 场景、转折、节拍、段落 | craft_scene |
| 视角、POV、叙述者、人称 | craft_pov |
| 文笔、语言、描写、比喻、展现 | craft_prose |
| 节奏、紧张感、悬念、速度 | craft_pacing |
| 经济、货币、贸易、市场、资源 | world_economy, domain_economics |
| 政治、治理、政府、帝国、权力 | world_politics, domain_political |
| 社会、阶级、种族、人群、社区 | world_society, domain_sociology |
| 宗教、信仰、神、仪式、文化 | world_culture |
| 技术、科技、AI、机器、未来 | world_tech |
| 生态、地理、气候、生物、星球 | world_ecology |
| 演化、代际、文明、时间 | world_evolution |
| 语言、文字、命名、术语 | world_language |
| 战争、军事、军队、武器 | world_military |
| 科幻、SF、未来、太空、科技 | genre_sf |
| 奇幻、魔法、异世界、龙 | genre_fantasy |
| 赛博、朋克、义体、企业统治 | genre_cyberpunk |
| 反乌托邦、极权、监控、独裁 | genre_dystopia |
| 末日、废土、生存 | genre_postapocalyptic |

### 6.2 综合推理优先级

```
1. 明确的类型标签（genre_*）→ 确定基本语境
2. 涉及的主题领域（domain_* / world_*）→ 确定需要的深度知识
3. 涉及的写作技法（craft_*）→ 确定叙事层面的指导需求
4. 三个维度交叉 → 综合匹配知识源
```

---

## 七、标签体系维护规则

1. **新增知识源时**：评估其内容 → 从三个维度各选1-3个标签 → 写入 registry
2. **标签冲突时**：优先精确（宁可少标也不错标）
3. **体系更新**：本文件随 `knowledge-registry.json` 同步更新
4. **版本记录**：v1 — 初始设计，覆盖11个现存知识源 + 4个计划中知识源

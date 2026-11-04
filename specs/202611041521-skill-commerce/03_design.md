# 详细设计：SEO/GEO/AGO 三层优化 + 多市场上架管线
> 创建: 2026-11-04 15:30 | > 用途：SEO/GEO/AGO 三层设计 + 上架管线

> Ticket: SKC-001 | 日期: 2026-11-04 15:35 | 状态: ✅

## 一、架构决策（最小集）

| 决策 | 选择 | 理由 |
|------|------|------|
| 分档策略 | A/B/C 三档漏斗（见 01_analysis §三） | 全量改造工作量失控，先跑通单点再扩量 |
| 首发市场 | WorkBuddy（免费版过审→开通变现→付费上架） | 唯一"上架即收款"通道；1% 服务费；个人可开通 |
| 流量策略 | 内容侧联动（公众号稿型「我造的坐标系」+ 小红书种草） | 扣子教训：市场不分发流量，必须自带 |
| 优化分层 | SEO/GEO/AGO 三层各对应一种发现方 | 三种引擎抓取逻辑不同，不能一套优化打天下 |

## 二、三层优化设计（本 spec 的核心技术方案）

### 层 1 · SEO（搜索引擎 = 传统流量）

对象：Google/Bing/百度 + GitHub 站内搜索。落点：README、仓库名、topics。

- README 标题与 H2 含**真实可搜索实体**（工具名/平台名/具体数字）——与 boss 已拍板的「外部可发现型判据」同构
- 仓库 topics 补齐：`claude-skills` `agent-skills` `wechat` `wechat-official-account` `写作` `排版` 等
- 每技能一个独立 README 段落锚点，长尾关键词覆盖「如何给公众号排版」「AI 去味」等中文长尾

### 层 2 · GEO（生成式引擎优化 = AI 引用）

对象：ChatGPT/豆包/元宝/Perplexity 等生成引擎的回答引用。落点：README 结构化。

- 四段式骨架：**问题 → 方案 → 安装 → 证据**（证据=实测数字/截图，符合 BUL-003）
- FAQ 段（生成引擎偏爱抓 FAQ 进答案）
- 事实句独立成行、带数字、带日期——提高被引用概率
- 仓库明示 License 与引用格式（`引用本文：xingtu-skills repo`）

### 层 3 · AGO（Agent 优化 = 让 Agent 主动装）

对象：Claude Code / OpenClaw / WorkBuddy 等 Agent 的自动发现与安装。

- **SKILL.md description 工程**：中英双语触发词 + 「Use when...」场景句 + 与相邻技能的区分句（description 是 Agent 决定是否激活的唯一依据）
- **marketplace.json 全量登记**（补 doubao-app-layer-archive 缺口），条目含 keywords
- 第三方目录登记：claudemarketplaces.com（Claude 生态最大目录）、ClawHub（小红书生态兼容面）
- 安装路径极简：README 顶层放一键安装命令（`npx` / git clone 一行式）

## 三、上架管线（单技能改造 SOP）

```
C 档淘汰 → A 档候选 → ①依赖剥离（tools/*.py 内联或删引用、路径参数化）
  → ②脱敏闸门（privacy_scan --fail-fast + 47 词 grep）
  → ③WorkBuddy 打包（zip：SKILL.md + 资源，≤ 限制）
  → ④发布管理提交审核（免费版）
  → ⑤过审后：第 1 个用于开通收款，第 2 个开付费（定价先写入 03_design 留痕）
  → ⑥内容侧联动：公众号选题池加「技能发布」稿型
```

## 四、数据流

```
四池真身(~/.agents) ──diff──→ 公开仓 xingtu-skills/skills/
                                   │
                     ┌─────────────┼─────────────┐
                  SEO 层        GEO 层         AGO 层
                 (README/topics) (FAQ/证据)   (description/目录登记)
                                   │
                        ┌──────────┴──────────┐
                   WorkBuddy 上架        小红书 RedSkill
                   (免费过审→付费)        (MD 技能挂笔记)
                                   │
                          收入 → 30 天观察期复盘
```

## 五、首批候选（P2 执行时逐个过闸门，名单以 triage.md 终评为准）

| 候选 | 目标市场 | 定价假设 | 改造点 |
|------|---------|---------|--------|
| de-ai-flavor | WorkBuddy | 免费版（开通用） | 删行途案例、守卫词通用化 |
| concept-anchor-figure | WorkBuddy | ¥9.9-19.9 买断 | 删品牌 palette 依赖，参数化 |
| svgtopng-cn-fonts | WorkBuddy | ¥9.9 买断 | 中文 SVG 转 PNG 刚需，已是自包含配方 |
| caveman（压缩沟通） | Claude 生态/WorkBuddy | 免费+口碑 | 基本即插即用 |
| wechat-draft-api | WorkBuddy | ¥19.9-49.9 买断 | B 档剥离样板：删 boss 专属流程 |

> 定价决策（D2）必须在 WorkBuddy 后台勾选付费方式**之前**落盘本文件并经 boss 确认——付费方式上架后不可修改。

## 六、文档回写清单

| # | 文档 | 需要更新？ | 变更内容 |
|---|------|:--------:|---------|
| 1 | `laws.md` | 否 | 无新铁律 |
| 2 | CHANGELOG.md（主区） | 是 | spec 新建登记 |
| 3 | 产出索引.md | 是 | spec + triage.md 登记 |
| 4 | memory（工作区） | 是 | 新增长期工作线「技能商业化」 |
| 5 | xingtu-skills README | 是（P4） | GEO 结构化改造 |

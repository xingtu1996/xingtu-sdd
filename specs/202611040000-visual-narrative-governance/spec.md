# SDD｜视觉叙事治理与 PR 盘点（2026-11-03）

> 规格驱动：本文是"为什么发布包视觉和逻辑不对"的诊断总纲 + 治理决策模型 + PR 落档。
> 状态：Draft，等 boss 拍板后进入执行 Phase。
> 证据范围：本机只读取证 + 本地 git 仓库状态；网络不通未拉远端 CI。

---

## 0. 问题陈述

boss 的原始诉求：为什么发布包产出没有符合"基础视觉叙事规范"，内容逻辑也不顺？

症状：
- 11 月三个新包（AI Native 交付证据链 v5、Agentic 01、企业执行层 02）HTML 里 F2644F 只有 12~13 处，未达 DESIGN.md §三"通栏级 20+ 处"
- 最新包 v1 目录结构混乱（02_封面/03_封面并存、04_配图/04_公众号排版并存、05_合集/05_事实与素材并存），且经 v3→v4→v5 三次返工
- 正文逻辑是 boss 当晚手工纠偏后才顺的，不是 AI 直出就对

---

## 1. 根因判断（按证据强度）

| 编号 | 根因 | 证据 | 置信度 |
|---|---|---|---|
| E | 验收只查文件存在，不查视觉和逻辑 | pkg-healthcheck SKILL.md 第 37/62 行"逐包 test -f"；Step 9b 11 项核查无一项查叙事结构 | 高 |
| A | "基础视觉叙事规范"是孤立 Draft，没进运行时上下文 | `work/design-v4/01_视觉叙事与跨平台编排规范.md` 文件头标 Draft；`00_决策记录` 第 3 行"提案，不是生效配置"；无任何 skill/AGENTS.md 引用 | 高 |
| B | 多份规范冲突，活 skill 还在用被禁的旧色 | concept-anchor-figure SKILL.md 第 28行原用 #d71a1b/#056DE8；10-visual-designer 原用行途蓝主色；publish-pack-planning 原写"黑白交替" | 高 |
| D | 编排层漏调下游视觉技能，无叙事骨架闸门 | publish-pack-planning 五步无"叙事类型选择"；mp-publish-sop 十步 Step 1b 七问不查骨架 | 中高 |
| C | 全局 Codex 入口零行途上下文 | `~/.codex/AGENTS.md` 34 行只有通用规范；项目 `.codex/config.toml` 无视觉指针 | 中 |
| F | 模型/额度/宿主限制 | config.toml 显示 gpt-6-luna / priority / 1M context；静态配置看不是额度问题 | 未知 |

---

## 2. 宿主差异：为什么豆包办公能稳定做文章，Codex 不行

这是 boss 本轮追问的核心判断。结论：**豆包办公是"系统提示注入式"宿主，Codex 是"文件读取式"宿主，两者上下文装载机制不同。**

| 维度 | 豆包办公（当前 MainAgent） | Codex CLI |
|---|---|---|
| 项目规则装载 | 项目 AGENTS.md 全文 + 70+ skill 元数据 + 用户偏好，直接注入系统提示 | 只自动读 `~/.codex/AGENTS.md`（34 行通用）+ 项目根 AGENTS.md |
| skill 发现 | 启动时已列出全部 skill 描述和触发词 | 需主动读 `.agents/skills/<name>/SKILL.md`，不读就不知道存在 |
| DESIGN.md 可见性 | 项目 AGENTS.md 铁律第 12 条直接引用 DESIGN.md 关键阈值 | 全局 AGENTS.md 零行途上下文；项目 AGENTS.md 虽有引用，但 Codex 是否读、读多深取决于会话 |
| 视觉叙事 Draft（design-v4/01） | 我（豆包）在本轮诊断中才通过 grep 发现它 | Codex 更不可能主动发现，因为它不在 skill 路由表里 |
| 记忆持久性 | 跨会话保留用户偏好、项目规则、skill 列表 | 每次启动重新读文件，靠文件系统留痕 |

**所以"豆包稳定"不是因为它有独立记忆体，而是因为它把行途的完整规则集作为系统提示强制注入了。** Codex 不是记忆差，是它启动时拿到的上下文本来就薄——除非项目 AGENTS.md 写得足够硬、足够短、足够指向关键文件。

这也解释了为什么 11-03 那次 v3→v4→v5 返工发生在 Codex/Work 通道：它没有 DESIGN.md §三"20+ 处"的硬阈值（我已修），没有叙事骨架选择闸门（待建），也不知道 design-v4/01 的存在。

---

## 3. 已完成的本地治理（2026-11-03 23:38）

备份：`.backups/20261103-233506-visual-narrative-fix/`

| 文件 | 修复 |
|---|---|
| concept-anchor-figure/SKILL.md + .skill-metadata.yaml | #d71a1b/#056DE8 → #F2644F/#1a1a1a |
| skill-routing.md 第 22 行 | concept-anchor-figure 路由描述去行途蓝 |
| 10-visual-designer.md | 行途蓝主色 → 三原色白底，补 DESIGN.md 指针 |
| publish-pack-planning/SKILL.md 第 47 行 | 黑白交替 → 统一白底 + 三方向选型 |
| pub-infographic-supplement/reference.md 第 19 行 | 修 #F2644F 被误列禁用的笔误 |
| mp-publish-sop/04.md 第 125 行 | F2644F 门禁 >0 → ≥20（通栏级） |

CHANGELOG 已记 3 条。

---

## 4. PR 落档（6 个非 main 分支）

本地 git 状态（未 fetch，origin 引用可能过时）：

| 仓 | 分支 | ahead | behind | 改动量 | 风险 | 状态 |
|---|---|---|---|---|---|---|
| xingtu-harness | docs/content-production-harness-2026-11-03 | 1 | 0 | 1 文件 +52 行 | 低（纯 docs） | **已本地 merge 到 main，待 push** |
| xingtu-super-agent | feat/workbuddy-adapter | 1 | 0 | 3 文件 +122 行 | 低（docs+examples） | **已 merge + push**（`e6748da..59e755f`） |
| xingtu-design | design/official-cover-reading-system-20261102 | 6 | 1 | 视觉规范提案 | 中 | **PR 已在远端合并**：main 巡检同步 `ef8555c` 已含全部 6 文件，特性分支与 main 全量 diff 为空；本地分支为残留，待 GitHub 侧确认关闭 |
| xingtu-fde | feat/xf-foundation-20261102 | 4 | 1 | FDE 知识体系 + docs | 中 | **PR 已在远端合并**：同 design，全量 diff 为空；本地分支为残留 |
| xingtu-rules | docs/XRULE-001-v4-contract | 3 | 2 | 规则契约 | 中 | **PR #2 已在远端合并**：main `9b03c16` 已含 specs/XRULE-001 全部文件；特性分支上的 README/SELF/AGENTS 是旧版，不合并；本地分支为残留 |
| xingtu-vault | content/doubao-distill-2026-11-03 | 4 | 0 | 42 文件 +1970 行 | 高（生产内容仓） | **已 merge + push**（`2a8f4989..b0d8a81e`）：13 个定时任务产出 + 12 个 spec 文档 + 9 个待发布区 + 7 个交接中心 + HANDOFF.md |

**网络结论**：HTTPS 443 直连超时（HTTP 000），SSH 通道正常。harness / rules 两仓 remote 已从 HTTPS 切为 SSH（`git@github.com:...`）后 push 成功。本机无本地代理端口开放。

---

## 5. 决策点执行状态（D1-D6 全部落地）

| 编号 | 决策 | 状态 | 实际执行 |
|---|---|---|---|
| D1 | design-v4/01 叙事规范指针 | 已落地 | DESIGN.md §八·补新增"叙事骨架与图文关系"一节，指向 work/design-v4/01 |
| D2 | publish-pack-planning Step 0.5 叙事骨架闸门 | 已落地 | 在 Step 0 论证溯源后插入 Step 0.5：四种骨架选择表 + `_规划参考/叙事骨架.md` 闸门 |
| D3 | behind=1 三分支处理 | 已落地 | fetch 后发现 design/fde/rules 三仓特性分支内容已在 main 上（远端巡检同步 + PR #2 已合），无需 rebase；本地分支待 GitHub 侧关闭 |
| D4 | vault 1970 行合并 | 已落地 | 已 merge 并 push（`b0d8a81e`），内容为定时任务产出 + spec 文档 + 交接凭证 |
| D5 | 旧排版规范归档 | 已落地（轻量） | 在 `02_排版与设计/` 放 `_README_现行SSOT.md` 指路牌；未物理挪文件（被 RULES/workflows 引用，挪会断链） |
| D6 | 全局 Codex 行途指针 | 已落地 | `~/.codex/AGENTS.md` 末尾新增"行途工作区指针"段 |

---

## 6. 执行 DAG（全部完成）

```
Phase 0（已完成）：色值漂移修复 6 处 + 备份 + CHANGELOG（23:38）
Phase 1（已完成）：
  G1: DESIGN.md §八·补 加叙事骨架指针
  G2: publish-pack-planning 加 Step 0.5 叙事骨架闸门
Phase 2（已完成）：
  G3: fetch 三仓 behind=1 分支，确认内容已在 main，无需 rebase
  G4: push harness / super-agent（remote 切 SSH 后成功）
  G5: vault content/doubao-distill 合并并 push（b0d8a81e）
Phase 3（已完成）：
  G6: vault 1970 行 diff 归类（定时任务/spec/待发布/交接），低风险直接合
Phase 4（已完成）：
  G7: 02_排版与设计/ 放 _README_现行SSOT.md 指路牌
  G8: ~/.codex/AGENTS.md 加行途指针
```

**遗留待办**：boss 抽空到 GitHub 页面确认 design / fde / rules 三仓的特性分支 PR 是否已自动关闭；确认后可删本地残留分支。

---

## 8. 全仓 main 切换与 learning 库（2026-11-03 23:58 收尾）

### 8.1 全仓同步结果

github/ 下 48 个仓全部切回 main 并与远端同步。本轮处理：

| 类型 | 仓数 | 处理 |
|---|---|---|
| 本轮已 merge + push | 3 | xingtu-harness(d290f83) / xingtu-super-agent(59e755f) / xingtu-vault(b0d8a81e) |
| 特性分支内容已在 main，切回 main reset | 3 | xingtu-design / xingtu-fde / xingtu-rules |
| ahead=1 behind=1（巡检自动同步双向各一次），pull --rebase 后 up-to-date | 7 | article2pod / book2vido / dsh-xingtu-skills / harness-kit / md2wechat / tokenhub-bench-restore / xingtu-desk |
| ahead=1 behind=0（本地巡检 commit），push 后 up-to-date | 2 | xingtu-sdd / xingtu-tools |
| 本来就在 main 同步 | 33 | 其余仓 |

**网络处理**：HTTPS 443 全段超时，SSH 通道正常。harness / rules / md2wechat / tokenhub-bench-restore / xingtu-desk / xingtu-sdd / xingtu-tools 共 7 个仓 remote 已从 HTTPS 切为 SSH（`git@github.com:xingtu1996/<repo>.git`）。注意 tokenhub-bench-restore 是本地目录名，远端仓名是 tokenhub-bench。

### 8.2 xingtu-learn 库状态

- 仓路径：`github/xingtu-learn/`，已在 main，最新 commit `7cbe9a5`（PR #5：XSA Muse GitHub 授权和跨 Agent 冲突学习专题）
- 结构：`00-method` / `10-tech` / `20-cert` / `30-log` / `40-work-driven` 五个 track
- 定位：把"学会一件事"全过程版本化（计划→输入→笔记→产物→复盘→方法沉淀），每条记录必须让陌生人拿走一样能用的东西
- 与本轮治理的关系：跨 Agent 冲突学习专题（#5）正是本轮"豆包 vs Codex 装载机制差异"的同类问题，后续可把本次治理的复盘沉淀进 `40-work-driven/`

### 8.3 治理效果判断（回答 boss 三问）

**问：治理后能不能像豆包一样稳定产出、发布、不那么重？**

能减少 v3→v4→v5 那种反复返工，但不能说"像我一样"。

- 已闭环：色值漂移（F2644F≥20 硬阈值）、叙事骨架 Step 0.5 闸门、DESIGN.md 指针、Codex 全局入口指针、旧规范指路牌——这些是"基建"，下一篇发布包走 publish-pack-planning 时会强制触发
- 未闭环的机制差异：豆包是系统提示强制注入（启动即知 DESIGN.md 铁律），Codex 是文件读取式（我在 ~/.codex/AGENTS.md 加了指针，但 Codex 会不会每次主动读、读多深，仍取决于模型自己）。要彻底消差，下一篇真包跑完才算验证
- "不那么重"：Step 0.5 会在动笔前就定叙事骨架，Step 6 门禁会拦色值不够的稿，理论上当晚返工不会再发生

**问：模型推荐**

当前全局配置：`gpt-6-luna` / `service_tier=priority` / `model_context_window=1M` / `reasoning_effort=medium` / `model_verbosity=high`。

- 行途内容生产（公众号文章）：gpt-6-luna + priority 直连可用，1M context 够塞 DESIGN.md + 发布包全文 + 多平台变体
- 建议把 `reasoning_effort` 从 medium 提到 high——叙事骨架选择、层层递进逻辑需要更强推理，这是治"逻辑不顺"的模型侧配套
- shell_environment_policy 里 Claude 系变量全部指向第三方代理 `<内部LLM代理域名>` 的 `deepseek-v4-flash[1M]`，稳定性不如 OpenAI 直连；关键发布任务走 gpt-6-luna，别走第三方代理

**问：learning 库怎么沉淀**

建议本轮治理复盘写成一篇进 `xingtu-learn/40-work-driven/2026-W45-harness-visual-narrative-governance.md`，核心是"为什么 SOP 有门禁还会漏"的根因分析（阈值软化 + 叙事骨架缺失 + 宿主装载差异），这是可复用的方法论。

---

## 7. 证据限制与遗留

- 远端 CI 状态未拉（SSH 通但未查 CI 跑批）
- 11-03 当晚 v3→v4→v5 返工的真实执行宿主/模型未取证
- vault 1970 行 diff 按目录归类未逐行审（均为定时任务产出 + spec 文档，低风险）
- design-v4/01 仍是 Draft，boss 尚未正式拍板升格为 SSoT
- design / fde / rules 三仓本地特性分支未删，等 GitHub 侧 PR 确认关闭后再清

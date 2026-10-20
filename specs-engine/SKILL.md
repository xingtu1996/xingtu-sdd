---
name: specs-engine
description: Spec 驱动开发(SDD)方法论引擎——意图路由、先规格后编码(三铁律 No Spec No Code/五阶段/深度裁减)。用户说"按 specs 标准推进/走 spec/需求澄清固化/写 analysis~validator/收口 0 draft/按宪法推进/拆子 Spec/父 Spec 下细分/批量同类改造逐项落地"等时用，把需求固化为结构化 Spec 再写代码；Bug 先写根因 analysis。轻量/标准/重量三档深度；父 Spec 下可挂子 Spec（sub-specs/，父管全局子管单项）；多 Spec 并行走 orchestration。
---

# specs-engine — Spec 驱动开发方法论

> **SSOT**：本 skill 即方法论唯一事实源。改此处 → 所有项目即刻生效（全局 user-level skill）。
> 每个 Spec 目录落盘的 `laws.md` 是该方法论的薄快照（自包含，供团队读者），冲突以本 skill 为准。
> **真源仓 = `github/xingtu-sdd`**（本 skill 的 `specs-engine/` 是它的部署产物）。改方法论请改真源仓 → 跑同步脚本，勿在本副本直接改（防双真源）。

## 触发与路由

| 意图（说人话即可） | 走哪 |
|------|------|
| 修 Bug / 排查数据不对 / 为什么报错 | Spec：先 `01_analysis`(根因+影响) 再改码 |
| 新功能 / 加接口 / 改流程 | Spec：标准深度全六文件 |
| 架构改造 / 计费·库存·权限操作 | Spec：重量深度 + 方案对比 + 安全三条件 |
| 单文件微调 / 配置调整 | Spec：轻量（analysis + validator 两文件） |
| 一句话需求 → 先澄清再固化 | 需求澄清 → 人确认 → 写 requirements |
| 批量/2+ 独立需求 | 读 orchestration.md（依赖 DAG + 契约优先） |
| 换会话/换 agent 接着干 / 上次做到哪了 | `sdd.sh resume <dir>`（断代续传，读 state.json + log 尾部） |
| 调研/探索（无交付代码） | research 档：analysis→findings 即可，不写 design/code |
| 父 Spec 下的细分 / 大改造逐项落地 / N 个同类小改造 | **子 Spec**：`scaffold.sh sub` → 读 `references/subspec.md` |

**铁律一**：No Spec No Code。方案未文档化（对应文件≥完成）前不写实现代码。
**意图路由是灵魂**：AI 读上述路由自适应深浅，非命令驱动——用户不用学命令。

## 深度裁减（SSOT 在此，00_README 模板仅落盘快照）

| 深度 | 场景 | 必填 | 说明 |
|:---:|------|------|------|
| 轻量 | 单文件 Bug、配置 | 01_analysis + 05_validator | 02/03/04 可删；execution-log 并入 00_README |
| 标准 | 功能开发、跨模块修改 | 01~05 + execution-log | 默认档 |
| 重量 | 架构、计费/库存/权限 | 同标准 | 加方案对比 + 暂停点 |
| research | 调研/探索/市场评估（无交付代码） | 01_analysis + findings | 不写 03/04/05；验收=结论可复现、来源可追溯 |

> BDD 铁律：AI 定档并建议，**人确认后**执行。AI 不给自己当裁判。
>
> **裁剪声明义务**：轻量档删掉 02/03/04 时，必须在 `00_README` 写明「文档类型裁剪说明」（删了哪几个 + 为什么）。不声明 = 静默删节，`validator-check.sh` V-1 判 ERROR。
> **校验器分级**：引擎格式缺必需文件 = ERROR；历史格式（README.md 时代）与存量 spec 的结构问题降为 WARN，不追溯罚款。

## 工作流

```
意图 → 深度定档(人确认) → 01_analysis → 02_requirements(AC) → 03_design
     → 04_tasks(打勾) → 写代码 → 05_validator(curl/SQL 自测闭环)
     → execution-log 同步落账 → 置 ✅ 前：复盘 + AC 对账 + 审核签字 → 提交
```

失败即回写：发现 Spec 遗漏 → 先补对应文件（Reverse Sync），再改代码。

## 读取导航

- spec 时读：`references/core.md`（三铁律 + 五阶段 + 文件规范 + 门禁）——唯一需读的方法论正文
- **仅挂子 Spec 时读**：`references/subspec.md`（拆不拆 / 怎么拆 / 父子链接 / 生命周期）
- 跨会话/换 agent 接续：`references/continuity.md`（`state.json` 状态机 + 续传协议 + 假设台账）
- 仅并行场景：`references/orchestration.md`（依赖 DAG + 契约优先 + §六 子 Spec 并行 + §七 worktree 真并行）
- 收口/提交前跑：`scripts/validator-check.sh`（全局单份）—— 内容门禁（05_validator 章节/占位符/安全三条件）+ **结构门禁 V-1~V-5**：文件齐全（按深度档）/ 全文件占位符 / 产出表引用落地 / execution-log 非空 / 子 Spec 索引漂移对账
- **看板（spec 的标准组件之一）**：`python3 scripts/build-dashboard.py <spec目录>` → `<spec>/spec-dashboard.html`
  （组件填充度 / 门禁自检 / 日志时间线 / 未完任务 / 子 Spec；从目录里的 .md 生成，不手维护）
  全局列表模式：`... <specs目录> --all`

## v2 命令（断代续传 / 并行 / 看板 / 复用）

```bash
scripts/sdd.sh resume   <spec_dir>     # 三行断点：上次到哪/挂什么/下一步
scripts/sdd.sh status   <spec_dir>     # 机器可读状态总览
scripts/sdd.sh touch    <spec_dir> --stage design --set-stage analysis=done --tail "..."
scripts/sdd.sh start    <phase> [--worktree]   # 并行 phase（worktree 隔离）
scripts/sdd.sh merge    <worktree_name>        # 合并回主线（先人工核对）
scripts/sdd.sh dashboard <specs_parent>        # 跨 spec 聚合看板
scripts/sdd.sh recall   <关键词>        # 检索 case-studies + copy-points 复用
```

派子 agent 时角色包见 `agents/README.md`（resume/scout/redteam/executor/archivist）。

## 物化 Spec（scaffold）

```bash
# 每个新 Spec：父目录/README 索引自动建+加行
# 前缀 {YYYYMMDDHHMM}[-{tool}]-{名}；多 agent 同空间务必带 --tool 以便区分/排序
bash ~/.claude/skills/specs-engine/scripts/scaffold.sh new <specs父目录> <简述> [--depth light|standard|heavy] [--tool <agent>]

# 子 Spec：建在 <父Spec>/sub-specs/ 下，父 README 子 Spec 索引段自动建+加行，子 00_README 自动写父指针
# 子不建 laws.md（继承父）/ 不建 execution-log（记父的）—— 见 references/subspec.md
bash ~/.claude/skills/specs-engine/scripts/scaffold.sh sub <父Spec目录> <子Spec名> [--depth light|standard|heavy]
```

模板 `{占位符}`：TICKET 按项目编号（如 TICKET-123/GI-42），日期 `date "+%Y-%m-%d %H:%M"`，作者写实。

## 与项目宪法（Constitution）的关系

**项目宪法** = 项目专属护栏（企业/团队红线文件），与全局方法论铁律并行：spec 内 📜 Check 节同时对照两者。方法论铁律见 references/core.md 〇章；每个 spec 目录自带 `laws.md` 薄快照，自包含可读。


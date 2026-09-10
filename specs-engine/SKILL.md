---
name: specs-engine
description: Spec 驱动开发(SDD)方法论引擎——意图路由、先规格后编码(三铁律 No Spec No Code/五阶段/深度裁减)。用户说"按 specs 标准推进/走 spec/需求澄清固化/写 analysis~validator/收口 0 draft/按宪法推进"等时用，把需求固化为结构化 Spec 再写代码；Bug 先写根因 analysis。轻量/标准/重量三档深度，多 Spec 并行走 orchestration。
---

# specs-engine — Spec 驱动开发方法论

> **SSOT**：本 skill 即方法论唯一事实源。改此处 → 所有项目即刻生效（全局 user-level skill）。
> 每个 Spec 目录落盘的 `laws.md` 是该方法论的薄快照（自包含，供团队读者），冲突以本 skill 为准。

## 触发与路由

| 意图（说人话即可） | 走哪 |
|------|------|
| 修 Bug / 排查数据不对 / 为什么报错 | Spec：先 `01_analysis`(根因+影响) 再改码 |
| 新功能 / 加接口 / 改流程 | Spec：标准深度全六文件 |
| 架构改造 / 计费·库存·权限操作 | Spec：重量深度 + 方案对比 + 安全三条件 |
| 单文件微调 / 配置调整 | Spec：轻量（analysis + validator 两文件） |
| 一句话需求 → 先澄清再固化 | 需求澄清 → 人确认 → 写 requirements |
| 批量/2+ 独立需求 | 读 orchestration.md（依赖 DAG + 契约优先） |

**铁律一**：No Spec No Code。方案未文档化（对应文件≥完成）前不写实现代码。
**意图路由是灵魂**：AI 读上述路由自适应深浅，非命令驱动——用户不用学命令。

## 深度裁减（SSOT 在此，00_README 模板仅落盘快照）

| 深度 | 场景 | 必填 | 说明 |
|:---:|------|------|------|
| 轻量 | 单文件 Bug、配置 | 01_analysis + 05_validator | 02/03/04 可删；execution-log 并入 00_README |
| 标准 | 功能开发、跨模块修改 | 01~05 + execution-log | 默认档 |
| 重量 | 架构、计费/库存/权限 | 同标准 | 加方案对比 + 暂停点 |

> BDD 铁律：AI 定档并建议，**人确认后**执行。AI 不给自己当裁判。

## 工作流

```
意图 → 深度定档(人确认) → 01_analysis → 02_requirements(AC) → 03_design
     → 04_tasks(打勾) → 写代码 → 05_validator(curl/SQL 自测闭环)
     → execution-log 同步落账 → 置 ✅ 前：复盘 + AC 对账 + 审核签字 → 提交
```

失败即回写：发现 Spec 遗漏 → 先补对应文件（Reverse Sync），再改代码。

## 读取导航

- spec 时读：`references/core.md`（三铁律 + 五阶段 + 文件规范 + 门禁）——唯一需读的方法论正文
- 仅并行场景：`references/orchestration.md`（依赖 DAG + 契约优先）
- 写完 05_validator 跑：`scripts/validator-check.sh`（占位符残留检查，全局单份）

## 物化 Spec（scaffold）

```bash
# 每个新 Spec：父目录/README 索引自动建+加行
bash ~/.claude/skills/specs-engine/scripts/scaffold.sh new <specs父目录> <TICKET>-{简述} [--depth light|standard|heavy]
```

模板 `{占位符}`：TICKET 按项目编号（如 TICKET-123/GI-42），日期 `date "+%Y-%m-%d %H:%M"`，作者写实。

## 与项目宪法（Constitution）的关系

**项目宪法** = 项目专属护栏（企业/团队红线文件），与全局方法论铁律并行：spec 内 📜 Check 节同时对照两者。方法论铁律见 references/core.md 〇章；每个 spec 目录自带 `laws.md` 薄快照，自包含可读。

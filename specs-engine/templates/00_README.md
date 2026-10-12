# {Spec 标题}

> Ticket: {TICKET} | 创建: {YYYY-MM-DD HH:MM} | 状态: ⬜
> 关联: {需求/工单链接}

## Spec 索引

| 文件 | 状态 | 说明 |
|------|:--:|------|
| [00_README.md](./00_README.md) | ✅ | 本文件 |
| [laws.md](./laws.md) | ✅ | 方法论薄快照（铁律+门禁，scaffold 自动落盘） |
| [01_analysis.md](./01_analysis.md) | ⬜ | 问题分析 + 影响面 |
| [02_requirements.md](./02_requirements.md) | ⬜ | 验收标准 + 安全条件 |
| [03_design.md](./03_design.md) | ⬜ | 架构设计 + 接口 |
| [04_tasks.md](./04_tasks.md) | ⬜ | 任务清单 + 依赖图 |
| [05_validator.md](./05_validator.md) | ⬜ | curl/SQL 验证（可执行） |
| [execution-log.md](./execution-log.md) | 🔄 | 执行事件日志（append-only 事实源） |
| [state.json](./state.json) | 🔄 | 机读状态机（`sdd.sh` 用；与 README 状态行同步，冲突以 execution-log 为准） |
| [spec-dashboard.html](./spec-dashboard.html) | 🔄 | **看板**：组件填充度 / 门禁自检 / 日志时间线 / 未完任务 / 子 Spec —— 由脚本从本目录的 .md 生成，不是手维护 |

> 方法论 SSOT：全局 specs-engine skill（本文件为落盘快照，冲突以全局为准）。

## Spec 深度

> 删除某深度不用的骨架文件时，同步删上方索引对应行，保持零断链。

| 深度 | 场景 | 必填 |
|:---:|------|------|
| **轻量** | 单文件 Bug、配置调整 | 01_analysis + 05_validator（02/03/04 可删） |
| **标准** | 功能开发、跨模块修改 | 01~05 + execution-log 同步记账 |
| **重量** | 架构改造、计费/库存/权限 | 同标准 + 方案对比 + 暂停点 |

## 质量门禁

> 置 ✅ 前逐项过 —— 见同目录 [laws.md](./laws.md)。核心：铁律 / 安全三条件 / 级联影响 / 测试 / execution-log / ✅ 三前置。

## 交接与续传（跨会话/长 spec 必填；首次续接时若为空，先补齐再动手）

> agent 接手续跑本 spec 时先读本节 + execution-log。方法论语：specs-engine references/core.md §七-B。
> **只记不可从产物重建的部分** —— spec 正文/代码里已有的不重复写（记录越多 = 上下文税）。四类必填：

- **① 被否决的方案及原因**：代码里只剩活下来的那个，看不出为什么不是别的
- **② 现场证据原文**：日志/SQL/报错摘要 + 时间戳 —— 环境一变就重跑不出来
- **③ 用户纠偏原话**：最高密度的 why；逐字引，勿转述
- **④ 未写入 AC 的隐含约束**：业务常识/前提（如"接入即消耗"）

- 最近 session-record / 断点续传文件：
- 下一步（下一个动作，一句话）：

## 复盘（置 ✅ 前必填）

> 数据取自 tasks.md 效能时间戳；发现沉淀到项目回溯目录。

- 总耗时：
- 踩坑：
- 反哺落点：

## 变更日志

| 日期 | 变更 | 作者 |
|------|------|------|
| {YYYY-MM-DD HH:MM} | 新建 | {author} |

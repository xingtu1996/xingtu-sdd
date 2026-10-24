# SDD 引擎「证据三目录」回写真源仓 + 文档全面刷新

> Ticket: SDD-ENG-20261025 | 创建: 2026-10-25 03:13 | 状态: ✅
> 关联: 行途工作区 `outputs/2026-10-25-SDD引擎升级分析简报.md`（分析底稿）

## Spec 索引

| 文件 | 状态 | 说明 |
|------|:--:|------|
| [00_README.md](./00_README.md) | ✅ | 本文件 |
| [laws.md](./laws.md) | ✅ | 方法论薄快照（铁律+门禁，scaffold 自动落盘） |
| [01_analysis.md](./01_analysis.md) | ⬜ | 问题分析 + 影响面 |
| [02_requirements.md](./02_requirements.md) | ⬜ | 验收标准 + 安全条件 |
| [03_design.md](./03_design.md) | ⬜ | 架构设计 + 接口 |
| [04_tasks.md](./04_tasks.md) | ⬜ | 任务清单 + 依赖图 |
| [05_validator.md](./05_validator.md) | ⬜ | 可执行验证（bash/grep，按本仓技术栈裁剪） |
| [deliverables/](./deliverables/README.md) | 🔄 | **产出物**（合并对账表 / 案例定稿 / 巡检结果 —— 只放当前有效版本） |
| [execution-log.md](./execution-log.md) | 🔄 | 执行事件日志（append-only 事实源） |
| [state.json](./state.json) | 🔄 | 机读状态机（`sdd.sh` 用；冲突以 execution-log 为准） |

> 方法论 SSOT：全局 specs-engine skill（本文件为落盘快照，冲突以全局为准）。

## Spec 深度

标准档：跨模块（引擎多文件 + 文档 + 子模块），01~05 + execution-log 同步记账。

## 质量门禁

> 置 ✅ 前逐项过 —— 见同目录 [laws.md](./laws.md)。

## 交接与续传（跨会话/长 spec 必填）

- **① 被否决的方案及原因**：不写「副本自动同步工具」——一次性场景上工具=新复杂度源，改为纪律条目（见 03_design §四）。
- **② 现场证据原文**：diff -rq 输出与 mtime 已固化在 01_analysis §二；GitHub 沙箱内不可达（fetch 443 超时），push 留待网络恢复。
- **③ 用户纠偏原话**：boss 拍板「全量 P1-P3（推荐）」+「harness 同步收敛（推荐）」（2026-10-25 AskUserQuestion 留痕）。
- **④ 未写入 AC 的隐含约束**：本 spec 位于公开仓，正文与案例全程脱敏（不出现客户/内部项目代号）。
- 最近 session-record / 断点续传文件：行途工作区 CHANGELOG 2026-10-25 段。
- 下一步（下一个动作，一句话）：按 04_tasks Phase 1 执行双向合并。

## 复盘（置 ✅ 前必填）

- 总耗时：2026-10-25 03:13 → 03:55（约 42 分钟：分析会话考古 + scaffold + 四 Phase + 门禁收口）
- 踩坑：① cwd 残留导致「009 死链」误报（在 harness 旧钉副本里 ls；Write 先读后写护栏拦下误覆盖）——跨副本操作前必须确认 cwd；② 部署副本打磨的 build-dashboard.py 用了 py3.12+ 的 f-string 反斜杠写法，本机 py3.9 直接 SyntaxError——副本上的代码没回写也没自测，正是本 spec 要治的病；③ 合并 README 时 privacy 修复方向起初记反（修复在仓侧不在副本侧），assert 拦截后校正。
- 反哺落点：引擎 README 回写纪律条目；copy-points §二·补2 四条；行途工作区 CHANGELOG/产出索引留痕。

## 变更日志

| 日期 | 变更 | 作者 |
|------|------|------|
| 2026-10-25 03:13 | 新建 | zcode |

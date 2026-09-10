# Bug 修复：下单接口偶发返回 500，订单卡「处理中」不流转

> Ticket: TICKET-123 | 创建: 2026-09-07 14:30 | 状态: ✅
> 关联: 工单 #8821

## Spec 索引

| 文件 | 状态 | 说明 |
|------|:--:|------|
| [00_README.md](./00_README.md) | ✅ | 本文件 |
| [laws.md](./laws.md) | ✅ | 方法论薄快照（scaffold 落盘） |
| [01_analysis.md](./01_analysis.md) | ✅ | 问题分析 + 影响面 |
| [05_validator.md](./05_validator.md) | ✅ | curl/SQL 验证（可执行） |

> 深度：轻量（02_requirements/03_design/04_tasks 已删，Bug 修复只需 analysis + validator）。
> 方法论 SSOT：全局 specs-engine skill（本文件为落盘快照，冲突以全局为准）。

## Spec 深度

| 深度 | 场景 | 必填 |
|:---:|------|------|
| **轻量** | 单文件 Bug、配置调整 | 01_analysis + 05_validator（02/03/04 可删） |

## 质量门禁

> 置 ✅ 前逐项过 —— 见同目录 [laws.md](./laws.md)。本 spec 全过。

## 复盘（置 ✅ 前必填）

- 总耗时：1.5h（analysis 0.5h + 修复 0.5h + 验证 0.5h）
- 踩坑：超时参数在 YAML 配了两处，只改一处导致复现不彻底
- 反哺落点：根因 → 项目宪法新增「超时类配置单点化」红线

## 变更日志

| 日期 | 变更 | 作者 |
|------|------|------|
| 2026-09-07 14:30 | 新建 | alice |
| 2026-09-07 15:55 | 修复 + 验证通过，置 ✅ | alice |

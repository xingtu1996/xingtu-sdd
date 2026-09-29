# SDD 引擎 v2：断代续传 × 并行编排 × 知识回流

> Ticket: SDD-V2 | 创建: 2026-09-29 15:00 | 状态: 🔵
> 关联：boss 口述专题（结合 SDD 实验 + OpenSpec/spec-kit 对标，推动模型控制）

## 一句话

把现有「方法论 + 8 文件骨架」引擎，升级为**机器可读状态驱动**的引擎——对抗大模型概率性失控：断了能续、重了能并、完了能复用。

## 真问题

v1 的状态全是人读的 prose（README emoji + execution-log），三个失控口子：
1. **断代**：跨会话/跨工具续跑时，没有机器可读断点，靠人翻日志，一翻就漏。
2. **并行靠纸面**：orchestration.md 有 DAG/∥标注，但没有真实 git worktree 机制，多 agent 真并行时无分支隔离、无合并闭环。
3. **案例是死档案**：case-studies 有 8 个案例但不反哺下一个 spec，复用靠人记。

## 三支柱（boss 定）

| 支柱 | 解决什么 | 落地物 |
|---|---|---|
| 1 断代续传 | 模型/会话切换不失忆 | `state.json` + `sdd status/resume` + 假设台账 H-* |
| 2 智能编排 | 多 agent 真并行 | `sdd start --worktree` / `sdd merge` + 契约目录 |
| 3 知识回流 | 经验复利 | case-studies 加机器可读索引 + `sdd recall` 检索 |

## 附加（Dashboard 扩展）

- `sdd dashboard <specs父目录>`：跨 spec 聚合（产出目录/子spec/copy点/任务类型分布）
- 任务类型从 light/standard/heavy 扩到含 **research（调研型，无交付代码）**

## 红线

- 纯 bash，不引入 Python 依赖（与 v1 scaffold/validator 一致）
- 向后兼容：老 spec 无 state.json 时 resume 降级读 execution-log
- 不破坏三铁律与现有 8 文件骨架

## 待拍板（带默认值，未回按默认跑）

- D1: worktree 默认并发上限？**默认 3**
- D2: state.json 是否纳入 git？**纳入**（断点即版本，跨 clone 可见）

## 交付清单

- `specs-engine/templates/state.json`
- `specs-engine/scripts/sdd.sh`（status/resume/start/merge/dashboard/recall）
- `specs-engine/agents/`（5 个角色包）
- `references/` 增补 continuity.md + 更新 orchestration.md
- 本 spec 自身作为 v2 首案跑通

# SDD 连续性：断代续传 × 状态机（v2 新增）

> 何时读：跨会话/跨工具接续一个 spec、或要把 spec 交给另一个 agent 时。单个一次性任务不读本文件。
> 核心问题：大模型是概率性的、上下文会断。本层用**机器可读 state** 把"现在到哪了"从 prose 变成可机读事实。

## 一、state.json = 状态机事实源

每个 spec 目录一份 `state.json`（scaffold 落模板，`sdd touch` 更新）。它不是新文档，是 `00_README` 状态行的**机读版**——README emoji 是给人看的，state.json 是给脚本/续跑 agent 看的。

```
status:    pending | in_progress | blocked | done
stage:     analysis|requirements|design|tasks|validating|executing
stages:    每个阶段 done/updated/note
open_decisions:  待拍板（带默认值），decided=true 即已拍
hypotheses:     H-* 假设台账，open/confirmed/killed
tail:      一句话断点（"正在做 X，卡在 Y"）
```

**铁律**：execution-log 是 append-only 事实源；state.json 是它的**缓存视图**。冲突以 execution-log 为准——`sdd resume` 会同时 tail log 交叉核对。

## 二、续传协议（换 agent / 换会话时）

```
接手方第一步：
  sdd resume <spec_dir>
    → WHERE   上次到哪（tail）
    → PENDING 挂着哪些未拍板 D / 未结算 H
    → NEXT    第一个未完成 stage
  → 读 execution-log 尾部 8 行交叉核对（防 state 缓存过期）
```

- **不要**重新从零分析——state 说 design done 就别重写 design。
- **不要**凭记忆——open_decisions 里未 decided 的才问，已 decided 的直接用结论。
- state.json 缺失（老 spec）→ 降级：只读 execution-log 尾部，并明说"无状态机，靠日志"。

## 三、假设台账（H-* 跨会话结算）

- 侦察阶段把"用户口头假设"登记为 H-*，status=open。
- 每次验证后回写：confirmed（证据）/ killed（推翻理由）/ open（待验证）。
- 置 ✅ 前：所有 H-* 不得仍是 open——这是"模型不确定"的显式兜底。

## 四、与既有文件关系

| 文件 | 给谁看 | 角色 |
|---|---|---|
| state.json | 脚本/续跑 agent | 机读状态机（本文件） |
| 00_README 状态行 | 人 | 缓存视图，冲突以 log 为准 |
| execution-log.md | 人 + 脚本 | append-only 事实源 |
| open_decisions | 决策人 | 待拍板，带默认值 |

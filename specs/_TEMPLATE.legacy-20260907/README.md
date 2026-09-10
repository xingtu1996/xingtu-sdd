# Spec 驱动工作流 · 使用说明

> **用途**：开发任务（workflows/03）与开源任务（workflows/04）先写 Spec 再动手，保证"设计先行、成本可解释、验收可判定"。
> **命名规范**：`specs/<项目>--<目的>--<YYYYMMDD>/`，如 `specs/xingtu-site--mvp--20260819/`。
> **活文档原则**：每个文件 <200 行，超则拆分；改动走备份，不 rm。

## 6 文件职责

| 文件 | 回答的问题 | 谁写 | 何时 |
|------|-----------|------|------|
| `requirements.md` | 要做什么？验收标准是什么？ | 主理人 + AI | 第一步 |
| `design.md` | 怎么实现？模块/接口/数据长啥样？ | AI + 主理人评审 | 第二步 |
| `tasks.md` | 拆成哪些任务？顺序依赖？ | AI | 第三步 |
| `estimation.md` | 要多少人天？假设是什么？（成本逻辑可解释） | AI | 与 tasks 并行 |
| `validator.md` | 怎么证明做完了？门禁项可机器判定？ | AI + 主理人 | 贯穿 |
| `README.md` | 这个 spec 的封面：目标一句话/状态/负责人 | AI | 第一步 |

## 生命周期
```
创建 spec 目录（复制 _TEMPLATE）→ 填 requirements → 评审确认（人）→ design → tasks/estimation
→ 开发（小步 + 验证）→ validator 门禁 → 交付 + 发布记录 → 归档（标状态 DONE/ON-HOLD）
```

## 纪律
- 每个数字/估算挂依据（BUL-003：来源+验证程度）；关键决策留痕（BUL-001）。
- 红线：SAF-006 公司代码绝不进 spec/开源；SAF-004 不碰雇主。
- 发布前过 `adversarial-review` 对抗审查 + 防弹检查清单。

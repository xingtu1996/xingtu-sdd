***REMOVED*** Specs 铁律（本 spec 的方法论锚点）

> 三铁律唯一事实源 = 全局 `specs-engine` skill（改全局此处即快照）。本文件随 scaffold 自动落盘，供本 spec 自包含阅读。
> 与项目自有宪法（企业护栏）并行对照。

***REMOVED******REMOVED*** 三条铁律

| ***REMOVED*** | 铁律 | 含义 |
|---|------|------|
| 1 | **No Spec, No Code** | 方案未文档化不写实现代码 |
| 2 | **Spec is Truth** | 文档与代码冲突，代码是 Bug，改代码 |
| 3 | **Reverse Sync** | 发现 Bug → 先补文档（根因/漏 AC/回归用例），再改代码 |

***REMOVED******REMOVED*** Spec × Plan 双保障

- Spec = 静态真相源；Plan Mode = 动态执行上下文。需求模糊先 Plan 澄清（人审），定了才落 Spec。
- Plan 执行中发现 Spec 遗漏 → 先改 Spec 再继续。

***REMOVED******REMOVED*** 流程纪律

| ***REMOVED*** | 纪律 |
|---|------|
| 1 | AC 必须可测试（curl / SQL / Both / 单元） |
| 2 | 安全三条件（退出/幂等/回滚）涉及计费·库存·权限·写操作必填 |
| 3 | ✅ 三前置：复盘段非空 + 对账节非空（代码类）+ 澄清状态已记 |
| 4 | execution-log 同步落账（append-only）；轻量档不单独建文件，执行日志并入 00_README 复盘段 |
| 5 | 时间戳精确到分，`date` 获取禁编时间 |
| 6 | 深度定档（轻量/标准/重量）AI 建议、人确认 |

***REMOVED******REMOVED*** 质量门禁（置 ✅ 前）

```
□ 铁律 Check — 无违反
□ 安全三条件 — 已明确
□ 级联影响 — 3 跳调用链/消费者已查
□ 测试 — 单元 + validator 通过
□ execution-log — 同步落账
□ ✅ 三前置 — 复盘 + 对账 + 澄清
```

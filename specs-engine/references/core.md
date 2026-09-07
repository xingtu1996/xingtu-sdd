***REMOVED*** Specs 核心方法论 — 铁律 + 五阶段 + 文件规范（触发即读）

> 配套：SKILL.md（触发/深度裁减 SSOT）+ orchestration.md（仅并行场景读）。本文件含铁律定稿。
> 术语：**项目宪法** = 项目专属护栏/红线（企业/团队自己的规则文件），与本文方法论铁律并行。

***REMOVED******REMOVED*** 〇、铁律（方法论定稿）

***REMOVED******REMOVED******REMOVED*** 三条铁律

| ***REMOVED*** | 铁律 | 含义 |
|---|------|------|
| 1 | **No Spec, No Code** | 方案未文档化不写实现代码。新功能需 analysis+requirements+design≥2 份；Bug 修需 analysis(根因+方案)；配置改需 requirements(AC+影响) |
| 2 | **Spec is Truth** | 文档与代码冲突，代码是 Bug，改代码。验收以 AC 为准、设计以 design.md 为准 |
| 3 | **Reverse Sync** | 发现 Bug → 先补文档漏洞（analysis 根因 / requirements 漏 AC / validator 回归用例），再改代码 |

***REMOVED******REMOVED******REMOVED*** Spec × Plan 双保障

- Spec 文档 = 静态真相源；Plan Mode = 动态执行上下文。需求模糊先 Plan 澄清（人审），方向定了才落 Spec。
- Plan 执行中发现 Spec 遗漏 → 先改 Spec 再继续（铁律 3）。

***REMOVED******REMOVED******REMOVED*** 流程纪律

| ***REMOVED*** | 纪律 |
|---|------|
| 1 | AC 必须可测试：每条标验证方式（curl / SQL / Both / 单元） |
| 2 | 安全三条件（退出/幂等/回滚）——涉及计费/库存/权限/写操作时 requirements 必填 |
| 3 | ✅ 三前置：00_README 复盘段非空 + 代码类 spec 对账节非空 + 澄清状态已显式记录；缺一保持 🔵 |
| 4 | execution-log 同步落账（append-only，状态事实源，禁事后回填）；**轻量档**不单独建文件，执行日志并入 00_README 复盘段 |
| 5 | 时间戳精确到分，用 `date "+%Y-%m-%d %H:%M"` 获取，**禁止编时间** |
| 6 | 完成后更新 specs 索引状态为 ✅ |

***REMOVED******REMOVED******REMOVED*** 深度定档铁律

AI 按复杂度建议深度（轻量/标准/重量），**人确认后执行**——AI 不给自己当裁判。

---

***REMOVED******REMOVED*** 一、五阶段工作流

```
影响分析(改哪/下游谁) → [01_analysis 问题分析] → [02_requirements 需求规格]
  → [03_design 详细设计] → [04_tasks 任务清单] → Code → [05_validator 运行时验证] → ✅
                                    ▲                                  │
                                    └────────── 反馈闭环（修复沉淀）─────────┘
```

每阶段产出即下阶段输入（derive→detail→plan），代码是 05 验证驱动的执行产物。

***REMOVED******REMOVED*** 二、何时启动 Spec

**强制**：功能开发 / Bug 修复 / 技术改造 / 接口变更 / 数据模型变更 / 跨模块修改。
**可选**：调研类、文档类、纯配置（走轻量档）。
**快速判断**：改动会碰代码 + 有可验收行为 → 走 spec；纯阅读/临时脚本 → 不强制。

***REMOVED******REMOVED*** 三、目录与命名

```
{specs父目录}/                      ***REMOVED*** 通常 .claude/specs，scaffold 自动建
├── README.md                       ***REMOVED*** Spec 索引（全部 spec 状态一览，scaffold 自动加行）
└── {YYYYMMDDHH}-{Ticket}-{domain}/ ***REMOVED*** 一个 Spec 一个目录
    ├── 00_README.md / laws.md / 01_analysis.md ... 05_validator.md / execution-log.md
```

**目录命名** `{YYYYMMDDHH}-{Ticket}-{domain}`：`YYYYMMDDHH` 创建日期+小时（前缀，按时间排序即定位）；`Ticket` 项目编号（有则加，如 `TICKET-123`）；`domain` 业务域简述（kebab-case）。无 Ticket 用 `{YYYYMMDDHH}-{domain}`。

**生命周期**：⬜ 待启动 → 🔵 进行中 → ✅ 完成（tasks 全勾 + 代码提交 + ✅ 三前置）。

***REMOVED******REMOVED*** 四、深度裁减

| 档 | 必填（scaffold 一律落盘全骨架，深度只约束"填哪些"） |
|:---:|------|
| 轻量 | 01_analysis + 05_validator（单文件 Bug/配置） |
| 标准 | 01_analysis ~ 05_validator 全五 + execution-log（功能开发/跨模块，默认） |
| 重量 | 同标准 + 方案对比 + 暂停点（架构改造/计费·库存·权限） |

> 完整档位表在 SKILL.md（唯一 SSOT）。骨架文件未选为必填的留空或整文件删除均可（轻量档 02/03/04 可删）。

***REMOVED******REMOVED*** 五、新建 Spec 流程

```
0. 方向未定 → 先澄清（人审），定了才落盘
1. scaffold new 建骨架（README 索引行已自动加，无需手加）
2. 01_analysis ← 现状+根因+方案对比+影响面
3. 02_requirements ← 可测试 AC + 安全三条件（涉及计费/库存/权限）
4. 03_design ← 架构决策 + 接口/数据流/结构变更 + 测试场景标注
5. 04_tasks ← 任务 + ∥ 并行标注
6. 05_validator ← 从 AC 派生验证用例
7. 开工首条：execution-log 记澄清状态；信息不全先问后建
```

***REMOVED******REMOVED*** 六、各文件编写规范

***REMOVED******REMOVED******REMOVED*** 01_analysis.md
问题现状（时间/单号/截图 + 影响范围）→ 根因分析（直接：`文件:行` 引用 / 根本：设计缺陷·边界·并发）→ 方案对比（表格：改动范围|风险|推荐）→ 影响面评估（下游调用方/消息消费者/DB/配置/入口/幂等/事务，按技术栈裁剪，无对应物删行）→ 安全条件初判。

***REMOVED******REMOVED******REMOVED*** 02_requirements.md
用户故事（作为{角色}要{功能}以便{价值}）→ **验收标准表**（***REMOVED***|标准|验证方式 curl/SQL/Both/单元|优先级，≥1 条 P0）→ 影响范围 → 非功能（性能/兼容/幂等）→ **安全三条件**（退出/幂等/回滚，不可省略）。契约变更附扩展节（API/消息/数据模型/监控）。

***REMOVED******REMOVED******REMOVED*** 03_design.md
架构决策（同步异步/事务/降级）→ 影响面确认（所有波及文件/消息路线）→ 接口设计（签名+意图+测试场景）→ 数据流 → 结构变更（先于代码部署）→ 关键代码模板（骨架非全码）→ 文档回写清单。

***REMOVED******REMOVED******REMOVED*** 04_tasks.md
依赖图（`Phase0 → [Phase1 ∥ Phase2] → ...`，∥=可并行）→ 任务打勾（每项标完成时间）→ 覆盖矩阵（AC↔测试↔validator）。层名按项目技术栈映射，无对应物删该 Phase。

***REMOVED******REMOVED******REMOVED*** 05_validator.md
**可执行验证脚本集，非事后文档**。数据准备 → 验证用例（curl + 预期）→ 数据一致性（上下游链）→ 安全三条件验证 → 合规检查（含资源增减对称）→ 合并后对账（逐 AC 核对证据，防漏适配）→ 审核签字。写码前先读，写完逐节跑，失败→修→重跑（Loop 闭环）。可跑 `scripts/validator-check.sh` 静态检查填充完整性。

***REMOVED******REMOVED******REMOVED*** execution-log.md
append-only 事件日志 = **状态事实源**（00_README 状态行仅缓存视图）。粒度：Phase 完成/关键产物/打回更正（微操作不记）。五要素：时间|动作|产物路径+大小|验证方式|状态。并行推进时用 `execution-log/` 目录（一事件一文件防写冲突）。

***REMOVED******REMOVED*** 七、与既有体系整合

- **skill 关系**：specs-engine = 方法论；项目自有领域 skill/agent 执行具体动作。发现方法论缺陷 → 改 specs-engine（全局 SSOT）。
- **回溯目录**（如 incidents/、错误案例索引/）：生产问题/踩坑 → 沉淀到项目回溯目录；把坑抽象为 Gate 反哺项目宪法 → 下次自动拦截（举一反三，错只犯一次）。
- **交付检视**：宣称代码完成前对照交付清单（各维度：后端/数据/导入导出/前端等按项目定）逐条查漏，防「代码完成」假象。

***REMOVED******REMOVED*** 八、质量门禁（置 ✅ 前）

```
□ 铁律 Check — 三条铁律无违反
□ 安全三条件 — 退出/幂等/回滚已明确（涉及计费/库存/权限/写操作）
□ 级联影响 — 3 跳调用链/消息消费者已查
□ 测试 — 单元覆盖 + validator 验证通过 + validator-check 无占位符残留
□ execution-log — 与动作同步落账，禁事后回填
□ ✅ 三前置 — 复盘段 + AC 对账 + 澄清状态
```

***REMOVED******REMOVED*** 九、时间戳效能（跨项目偏好）

- 必填位置：00_README 变更日志/状态行、tasks 任务完成时间、各文件版本历史。
- 格式 `YYYY-MM-DD HH:MM`，`date` 命令获取；禁编时间/禁丢时分/禁跳号。
- 效能指标：Spec 总耗时 = 最后 task 完成 − 创建；Phase 耗时按首末任务。

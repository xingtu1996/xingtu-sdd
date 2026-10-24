# 需求规格：证据三目录回写 + 文档刷新

> Ticket: SDD-ENG-20261025 | 创建: 2026-10-25 03:13 | 状态: ✅

> 📜 **Check**：需求不违反 [laws.md](./laws.md)。

## 一、用户故事

- 作为 SDD 引擎的维护者，我希望真源仓与部署副本内容一致，以便任何会话改引擎时不再产生双真源分叉。
- 作为开源仓读者，我希望 README / 案例 / 英文文档与引擎实际能力一致，以便按文档用起来不踩空。
- 作为案例库读者，我希望每个索引条目都有对应文件，以便不点死链。

## 二、范围

**做**：P1 引擎双向合并回写（8 修改 + 4 新增 + privacy 修复反向补齐到副本）；P2 Case 010 案例化 + copy-points 增补（009 死链初判已更正为误报，009 在位无需处理）；P3 README/引擎 README/SELF.md/README.en.md 刷新；P4 harness 子模块快进收敛。
**不做**：副本自动同步工具（被否决，见 03_design）；origin push（网络受限，留待恢复后人工）；009 案例改写（已在位，保持原样）。

## 三、验收标准（AC）

| # | 标准 | 验证方式 |
|---|------|---------|
| AC-1 | 主仓 `specs-engine/` 与两份部署副本三方一致（0 差异），且含证据三目录全套 + privacy 修复口径 | `diff -rq` 三两对比输出为空 |
| AC-2 | 本 spec 通过 `validator-check.sh` 全绿（ERROR=0） | 跑脚本看退出码 |
| AC-3 | 根 README 与引擎 README 口径升级：出现 `artifacts.md`/`V-6`/`sdd.sh archive`/`--with-artifacts`/v2.1 小节；全仓无 `V-1~V-5` 旧口径残留 | grep 计数断言 |
| AC-4 | `case-studies/010-*/case.md` 存在且过脱敏红线；`copy-points.md` 增补 ≥1 条；009 case.md 确认在位（更正后的验收口径） | `test -f` + grep |
| AC-5 | `README.en.md` 与 `SELF.md` 同步大版本要点（三目录 + V-6 各至少 1 处） | grep 计数断言 |
| AC-6 | harness 子模块 HEAD = 主仓最新 commit、工作区 `git status --porcelain` 为空 | git 命令断言 |
| AC-7 | 主仓 commit 用显式文件清单（禁 `git add -A`）；变更文件过 privacy 扫描（零命中） | git log + privacy_scan 退出码 |
| AC-8 | execution-log 全程记账（Phase 完成/打回更正/纠偏落账） | 回读日志非空且含各 Phase 条目 |

## 四、约束

- 公开仓脱敏红线：正文与案例不出现客户名、内部项目代号、内部平台实名（沿用既有口径"内部文档平台"）、本地绝对路径中含用户名的形态。
- 主仓 commit 遵守 Conventional Commits 中文描述。

## 五、安全三条件

| 条件 | 本 spec 的落地 |
|------|---------------|
| 退出 | 合并后 `diff -rq` 仍不一致（预期外差异）→ 中止，不 commit，上报根因 |
| 幂等 | 同步以 diff 驱动、可整体重跑；重跑结果 idempotent（cp 覆盖 + 手工 merge 只作用于已 merge 基线） |
| 回滚 | 主仓单 commit 显式清单，可整体 `git revert`；子模块操作前记录原 SHA（f3b8940）与脏 diff 快照，可复位 |

# 任务清单：回写与文档刷新执行单

> Ticket: SDD-ENG-20261025 | 创建: 2026-10-25 03:13 | 状态: ✅

## 依赖关系

```
Phase 1 双向合并 → Phase 2 案例化 → Phase 3 文档刷新 → Phase 4 子模块收敛 → Phase 5 验证收口
（1→2→3 严格串行：3 的口径依赖 1 的落盘；4 依赖主仓 commit 前置完成；5 收口全链）
```

## Phase 1 引擎双向合并回写

- [x] 1.1 主仓合入副本特性：11 文件按 03_design §二取副本版（含 4 新增）
- [x] 1.2 `specs-engine/README.md` 取副本版后追加 privacy 修复（"内部工程平台"→"内部文档平台"；实测修复在仓侧，副本为旧词，03_design §二行方向按实际校正）
- [x] 1.3 合并结果回灌两份部署副本（~/.claude 与 ~/.zcode）
- [x] 1.4 `diff -rq` 三方两两对比 = 0 差异（实测 0/0；TC-02 口径计数 4/2/1/0 符合预期）
- ⏱ 完成时间：2026-10-25 03:2x

## Phase 2 打磨案例化

- [x] 2.1 ~~查 009 原文定死链处置~~ **更正：死链为误报**（cwd 残留查了 harness 旧副本）；主仓 009 case.md 在位，零动作
- [x] 2.2 写 `case-studies/010-artifact-trio-dirs/case.md`（按 03_design §三，脱敏红线）
- [ ] 2.3 `case-studies/README.md` 精选表加 010 行；`copy-points.md` 增补「没有机器检查的索引必然腐烂」等 ≥1 条
- ⏱ 完成时间：

## Phase 3 文档全面刷新

- [x] 3.1 根 `README.md`：布局图补三目录/artifacts.md/V-6/sdd.sh/archive；案例数 5→10；v2.1（10-22）小节；标准结构补 deliverables/ + 三目录行
- [x] 3.2 根 `README.md`：快速开始补 --with-artifacts 示例（并入 v2.1 小节）
- [x] 3.3 `SELF.md`：核心价值补第 6 条「谱系可交代（v2.1）」
- [x] 3.4 `README.en.md`：中段重写（Usage/结构补三目录与 V-6/案例指针 10 篇）——原版仍停留在 cp _TEMPLATE 旧用法
- [x] 3.5 引擎 `README.md`：补 2026-10-25 回写真源仓条目 + 回写纪律（10-22 条目随副本合并已在）
- [x] 3.6 全仓 grep 校验：V-1~V-5 残留仅 README.md ×1 = v2.1 升级叙事（有意保留）；新口径全在位；009/010 案例在位
- ⏱ 完成时间：2026-10-25 03:4x

## Phase 4 harness 子模块收敛

- [x] 4.1 记录复位信息（原 SHA f3b8940 + 脏 diff + remote，存 deliverables/harness子模块复位信息.txt，68 行）
- [x] 4.2 主仓 commit 后：子模块丢脏改动（快照已存）→ 本地路径 fetch 主仓 → checkout 至最新 commit，`git status --porcelain` = 空
- ⏱ 完成时间：2026-10-25 03:5x

## Phase 5 验证收口

- [x] 5.1 跑 `validator-check.sh`（本 spec）全绿（复跑「全部通过」，exit 0；首轮 4 警告已清：execution-log 模板残留 / 五文件头创建标记 / build-dashboard.py py3.9 f-string 兼容修复）
- [x] 5.2 05_validator 全用例执行并回填结论（§六对账 8/8 ✅）
- [x] 5.3 主仓 commit（显式文件清单，Conventional Commits 中文）
- [x] 5.4 复盘 + 00_README 置 ✅；push ⚠️ 沙箱网络 443 超时未推，待网络恢复人工补推（领先 origin/main 3 提交）
- ⏱ 完成时间：2026-10-25 03:5x

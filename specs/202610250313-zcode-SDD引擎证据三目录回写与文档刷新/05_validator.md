# 验证计划：回写与文档刷新（bash/grep 按仓技术栈裁剪）

> Ticket: SDD-ENG-20261025 | 创建: 2026-10-25 03:13 | 状态: 🔄

> 📜 本文件是**可执行验证脚本集**。失败 → 修 → 重跑，全过才可置 ✅。

## 一、数据准备

无需 SQL。前置：主仓工作区含 Phase 1-4 全部变更；子模块已收敛。

## 二、入口验证用例

### TC-01: 三方副本一致性（AC-1）

```bash
R=/Users/lijiacheng/xingtu/github/xingtu-sdd/specs-engine
diff -rq "$R" ~/.claude/skills/specs-engine | wc -l   # 预期 0
diff -rq "$R" ~/.zcode/skills/specs-engine  | wc -l   # 预期 0
```

**预期**：两个计数均为 0。

### TC-02: 特性包与 privacy 口径同时在位（AC-1）

```bash
grep -c "with-artifacts" "$R/scaffold.sh"                 # 预期 ≥1
grep -c "V-6" "$R/scripts/validator-check.sh"             # 预期 ≥1
grep -c "内部文档平台" "$R/README.md"                      # 预期 =1（privacy 修复在位）
grep -c "内部工程平台" "$R/README.md"                      # 预期 =0
```

## 三、一致性验证

### 链 1: 文档口径与引擎能力一致（AC-3/AC-5）

```bash
G=/Users/liacheng/xingtu/github/xingtu-sdd
grep -rc "V-1~V-5" "$G/README.md" "$G/README.en.md" "$G/SELF.md" "$G/specs-engine/README.md" "$G/specs-engine/SKILL.md"  # 预期全 0
grep -c "artifacts.md" "$G/README.md"          # 预期 ≥1
grep -c "v2.1\|2\.1" "$G/README.md" | head -1  # v2.1 小节存在
grep -c "_archive\|三目录\|artifact" "$G/README.en.md"  # 预期 ≥1
grep -c "artifacts\|_archive\|三目录" "$G/SELF.md"      # 预期 ≥1
```

**预期**：全部满足预期值。

### 链 2: 案例库落位（AC-4；009 死链初判已更正为误报，验收口径=确认在位）

```bash
ls "$G/case-studies/010-artifact-trio-dirs/case.md"   # 预期存在
test -f "$G/case-studies/009-trash-asset-audit/case.md" && echo "009 在位"   # 预期输出 009 在位
grep -c "010-artifact-trio-dirs" "$G/case-studies/README.md"   # 预期 ≥1
grep -c "没有机器检查的索引必然腐烂" "$G/case-studies/copy-points.md"  # 预期 ≥1
```

## 四、安全三条件验证（必做）

### 4.1 退出条件

| # | 检查项 | 命令 | 预期 |
|---|--------|------|------|
| 1 | 预期外差异即中止 | TC-01 非零时 | 不 commit、上报根因（流程性，本 spec 执行中已核） |

### 4.2 幂等条件

| # | 检查项 | 命令 | 预期 |
|---|--------|------|------|
| 1 | 同步可重跑 | 重跑 cp/merge 步骤后再跑 TC-01 | 仍 0 差异 |

### 4.3 回滚条件

| # | 检查项 | 命令 | 预期 |
|---|--------|------|------|
| 1 | 主仓可整体回滚 | `git log --oneline -1`（显式清单单 commit） | `git revert` 可复原 |
| 2 | 子模块可复位 | deliverables/ 内复位信息（原 SHA + 脏 diff 快照） | 文件在位 |

## 五、合规检查

| # | 检查项 | 命令 | 预期 |
|---|--------|------|------|
| 1 | 公开仓脱敏 | `python3 /Users/lijiacheng/xingtu/tools/privacy_scan.py --fail-fast`（扫变更文件） | 退出码 0 |
| 2 | 提交纪律 | `git log -1 --stat` 为显式文件清单，无 `add -A` 痕迹 | 通过 |
| 3 | 客户/内部信息零出现 | Case 010 与 spec 全文 grep 客户代号/内部项目名 | 0 命中 |

## 六、合并后对账

| AC# | 结论（✅实现 / ⚠️跑偏 / 🔴风险） | 证据 |
|-----|:---:|------|
| AC-1 | ✅实现 | TC-01 三方 diff = 0/0（2026-10-25 实测两轮） |
| AC-2 | ✅实现 | validator-check.sh 退出码 0，复跑「全部通过」 |
| AC-3 | ✅实现 | artifacts.md×2 / v2.1×2 / en _archive×1 / SELF×1；V-1~V-5 残留仅 README.md×1 = v2.1 升级叙事（有意保留） |
| AC-4 | ✅实现 | 010 case.md 在位；009 case.md 在位（死链初判已更正为误报）；copy-points 新词 4 处 |
| AC-5 | ✅实现 | 同 AC-3 grep 证据 |
| AC-6 | ✅实现 | 子模块 checkout 至本仓最新 commit（本提交），`git status --porcelain` 空；复位快照存 deliverables/ |
| AC-7 | ✅实现 | git add 显式清单；privacy_scan --path 全绿（63 文件 0 命中） |
| AC-8 | ✅实现 | execution-log 4 条真实记录（开工/Phase1/Phase2+更正/收口） |

### 审核签字

| 项 | 值 |
|------|------|
| 产品/需求视角审核（AC 对账签字） | boss（方案拍板留痕 2026-10-25 AskUserQuestion：全量 P1-P3 + harness 收敛） |
| 合并验收责任 | zcode（主会话，磁盘凭证验收） |
| 发布责任 | ⚠️ push 待网络恢复（沙箱 443 超时），列入待办 |
| 结论 | ✅ 可合并（2026-10-25） |

## 七、手工验证

- [ ] Case 010 通读一遍，确认无客户可识别信息
- [ ] 根 README 布局图与实际 `ls specs-engine` 一致

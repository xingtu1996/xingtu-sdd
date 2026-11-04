# 验证计划：技能资产商业化管线
> 创建: 2026-11-04 15:30 | > 用途：可执行验证脚本集

> Ticket: SKC-001 | 日期: 2026-11-04 15:40 | 状态: ✅（每 Phase 执行后重跑）

> 📜 本项目为资产/内容类工程，无 SQL/微服务——验证以脚本闸门 + 平台后台凭证为主。

## 一、数据准备

> 本项目为资产/内容类工程，无数据库。测试数据 = 技能文件本体 + 平台后台账号状态，随用随在，无需预置。

## 二、本地闸门验证用例

### TC-01: 脱敏闸门（AC-8，一票否决，每批改动必跑）

```bash
python3 /Users/<user>/xingtu/tools/privacy_scan.py --fail-fast
cd /Users/<user>/xingtu/github/xingtu-skills && python3 tools/redline_scan.py 2>/dev/null || grep -rEf .redline_words.txt skills/ --include="*.md" -l | head
```

**预期**：privacy_scan 全绿；红线词 0 命中文件。

### TC-02: marketplace 全量登记（AC-4）

```bash
cd /Users/<user>/xingtu/github/xingtu-skills && ls skills/ | wc -l && python3 -c "
import json,pathlib
mk=json.load(open('.claude-plugin/marketplace.json')) if pathlib.Path('.claude-plugin/marketplace.json').exists() else None
print('registered:', mk and len(mk.get('plugins',[])))"
```

**预期**：skills 目录数 == marketplace 登记数（当前 138 vs 137，修复后对齐）。

### TC-03: SKILL.md description AGO 规范（AC-4）

```bash
cd /Users/<user>/xingtu/github/xingtu-skills && for s in skills/*/; do
  f="$s/SKILL.md"; [ -f "$f" ] || continue
  desc=$(awk '/^description:/{flag=1} flag&&/^---$/{exit} flag' "$f" | wc -c)
  len=${desc:-0}; [ "$len" -lt 20 ] && echo "WEAK: $s"
done | head -20
```

**预期**：`WEAK` 输出为空或全部列入 3.3 修补清单（description ≥ 20 字符且含触发词/场景句）。

### TC-04: 四池体检不回退（兼容性）

```bash
python3 /Users/<user>/xingtu/tools/skill_pool_audit.py 2>&1 | grep -E "漂移|未登记|命中"
```

**预期**：漂移数不增加；未登记归零；红线命中 0。

## 三、数据一致性验证

> 无 DB 写入，无双写链路。一致性对账对象改为「公开仓 ↔ marketplace ↔ 平台上架资产」三方对齐：skills/ 目录数 = marketplace 登记数（TC-02）；上架技能 = 03_design §五候选表留痕条目。30 天收口时逐条 AC 对账填 §六。

## 四、安全三条件验证

### 4.1 退出条件

| # | 检查项 | 方式 | 预期 |
|---|--------|------|------|
| 1 | 单技能改造 ≤ 半天 | execution-log 时间戳 | 超时即记录弃选 |
| 2 | 审核 2 轮不过即换 | 平台审核记录 | 第 3 轮不存在 |

### 4.2 幂等条件

| # | 检查项 | 方式 | 预期 |
|---|--------|------|------|
| 1 | 平台资产不重复建品 | 发布前查 WorkBuddy「发布管理」列表 | 同名技能唯一 |
| 2 | 重复跑 TC-01~04 结果一致 | 重跑 | 纯读，无副作用 |

### 4.3 回滚条件

| # | 检查项 | 方式 | 预期 |
|---|--------|------|------|
| 1 | 公开仓改动可回滚 | 每批改动独立 commit | git revert 可用 |
| 2 | 定价不可逆前置留痕 | 03_design §五 有定价记录且 boss 确认在先 | 勾选付费前记录存在 |

## 五、合规检查

| # | 检查项 | 命令/方式 | 预期 |
|---|--------|---------|------|
| 1 | 身份隔离 | 平台注册信息核查 | 无雇主姓名/邮箱/手机号 |
| 2 | 铁律对照 | laws.md + SAF-010 | 零违规 |
| 3 | 原创声明 | 上架原创声明勾选仅限完全自研技能 | 无搬运/借鉴来源混入 |

## 六、合并后对账（30 天观察期收口时逐条填）

| AC# | 结论 | 证据 |
|-----|:---:|------|
| AC-1~8 | ⬜ | ⬜ |

### 审核签字

| 项 | 值 |
|------|------|
| 产品/需求视角审核（AC 对账签字） | 待收口 |
| 合并验收责任 | 小研 |
| 发布责任 | boss（对外动作最终确认） |
| 结论 | ⬜ |

## 七、手工验证

- [ ] WorkBuddy 技能页面对外展示效果（手机端实看）
- [ ] 小红书 RedSkill 组件挂载后笔记实机预览

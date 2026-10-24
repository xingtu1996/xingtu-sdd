# 问题分析：引擎副本漂移与文档欠账

> Ticket: SDD-ENG-20261025 | 创建: 2026-10-25 03:13 | 状态: ✅

> 📜 **Check**：本分析遵守同目录 [laws.md](./laws.md) 三铁律。

## 一、问题现状

specs-engine 引擎在真实对客交付实践中打磨出「证据三目录」特性包（2026-10-22），但只落在了**部署副本**（全局 skill 目录），**真源仓未回写**——本项目最核心的主张就是反对双真源，引擎自身却出现了双真源漂移。同时文档层（README / 案例库 / 英文 README）落后引擎两版，另有一处案例死链与子模块旧钉。

- 发生了什么：2026-10-22 下午对客交付会话把特性写入全局 skill 副本（16:49-16:52），未回写真源仓；当晚主仓只提交了 privacy 修复（976c4c6，21:06），该修复也未同步到副本。
- 影响范围：引擎 12 个文件 + 文档 4 处 + 1 个 git 子模块。

## 二、证据（2026-10-25 实测）

### 2.1 三处副本状态

| 副本 | 状态 | mtime |
|---|---|---|
| 主仓（真源）@ 976c4c6 | 工作区干净；领先 origin/main 2 提交未推（GitHub 连接超时，push 留待网络恢复）；含 privacy 修复 | 10-22 21:06 |
| 部署副本 `~/.claude/skills/specs-engine` ≡ `~/.zcode/skills/specs-engine` | **特性最全**（证据三目录全套）；缺 privacy 修复 | 10-22 16:52（scripts 18:22） |
| `xingtu-harness` 子模块 @ f3b8940 | detached HEAD（10-12）+ 未提交 README 改动（"行途→行途技术"品牌统一，与主仓 3e5501a 同意图，属旧版上的未提交尝试） | 脏 |

### 2.2 部署副本领先真源仓的差异（diff -rq 实证）

修改 8：`README.md` `SKILL.md` `references/core.md` `scripts/{build-dashboard.py,scaffold.sh,sdd.sh,validator-check.sh}` `templates/00_README.md`
新增 4：`references/artifacts.md` + `templates/{_prompt,_work,_archive}.README.md`

特性内容（「证据三目录」，蒸馏自一次对客交付：13 个版本、25 个归档文件，归档索引停在 V7 而实际到 V13、漏登 11 个）：

- `_prompt/`（输入）/ `_work/`（过程）/ `_archive/`（历史）三目录判据 + 权威排序（索引与 execution-log 冲突以日志为准）
- `scaffold.sh --with-artifacts` 按需建三目录
- 结构门禁 V-1~V-5 → **V-1~V-6**（归档索引对账）
- `sdd.sh archive` 子命令（移动+登记+记账）
- 核心教训：**没有机器检查的索引必然腐烂**

### 2.3 打磨现场（会话考古，出处）

- 特性写入全局 skill：对客交付项目的 Claude Code 会话，2026-10-22 16:49-16:52（diff + mtime 交叉验证）。
- 引擎标准档全流程复用实证：另一项目会话用 `scaffold.sh new` + `validator-check.sh` 建双周汇报 spec（10-22）。
- 「SDD9」一词在全部本地会话转录中无实体（仅 base64 乱码误匹配），判为口述转写噪声，实指当前最新引擎。

## 三、影响面与根因

1. **双真源腐烂进行中**：仓内 privacy 修复未同步到部署副本（反向漂移已发生），下次任何人改副本都会再分叉。
2. **文档失真**：README 布局图/门禁口径停在 V-1~V-5 与无三目录状态；引擎 README 版本记录缺 10-22 条目。
3. **案例库 009 死链（❌ 更正：初判有误）**：初判来自 cwd 残留——在 harness 旧钉副本（10-12，无 009）里 ls 所致。主仓实查 `case-studies/009-trash-asset-audit/case.md` 完整在位（8.5KB，10-14 落盘），**无死链**；教训：跨副本操作前先确认 cwd（与 B-050 同型）。
4. **子模块旧钉**：harness 引用的引擎停在第 14 轮巡检态（10-12），且带脏改动。
5. **流程根因**：特性在现场打磨缺少「收尾回写真源仓」步骤（此前 V-1~V-5 有回写先例 commit 0bfb9fb，本轮漏跑）。

## 四、定档

标准档。不涉计费/库存/权限；但涉及公开仓内容变更 → 脱敏检查进验收。

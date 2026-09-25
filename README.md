# XingTu SDD · 规格驱动开发引擎

> 一句话：**让 AI「先想清楚，再写代码」**——把需求固化为结构化 Spec（规格），验收标准先行，代码只是规格的执行产物。
> 大白话：跟 AI 干活前先签一份「合同」（规格），写清要什么、怎么验收；AI 照做，做完拿合同逐条验收。可预期、可审计、可复现。

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

`xingtu-sdd` 是行途开源矩阵的 **SDD（Spec-Driven Development）方法论资产仓 + 可安装引擎**。核心：**no specs, no code**。任何复杂任务先写规格，明确目标/约束/验收标准，再动手编码。

> **2026-09-07 升级**：从"内容方法论仓"升级为**可用的 SDD 引擎**（`specs-engine/`）——内置 scaffold 物化骨架、validator 静态门禁、编号制模板、教程样例。从 40+ 真实工程 Spec 实战蒸馏后去业务绑定。

## 和 OpenSpec / GitHub spec-kit 的区别（为什么值得用）

业界方案是**命令驱动**：用户记 `/speckit.specify` 等 8-19 个命令，人学工具。xingtu-sdd 走**意图路由**——AI 读路由自判断深浅，用户说人话即可，工具适应人不是人适应工具：

| 维度 | OpenSpec / spec-kit | xingtu-sdd（specs-engine） |
|------|--------------------|:---:|
| 触发 | 记命令 → 敲 `/speckit.xxx` | **说人话**（"按 specs 标准推进 X"）→ 意图路由 |
| 深度 | 固定一套流程 | **深度可裁**：单文件 Bug 轻量 2 文件，架构改造重量全量 |
| 学习成本 | 学 8-19 命令 | 零——说需求即可 |
| 演进 | 靠更多命令/扩展 | 靠行为规则积累：踩坑 → 提炼规则 → 反哺（复利） |
| 落地 | CLI 工具链 | 可安装 Skill + 每 spec 自包含 `laws.md` + scaffold |
| 可观测 | CLI 为主 | spec 索引 + execution-log 事件流（可挂 dashboard 看板） |

## 快速开始

```bash
# 方式 A：作为 Claude Code 全局 Skill 安装（说人话即触发）
cp -r specs-engine ~/.claude/skills/specs-engine

# 方式 B：不装 skill，直接跑脚本（纯 bash，任何环境可用）
bash specs-engine/scripts/scaffold.sh new specs {TICKET}-{简述} --depth standard
bash specs-engine/scripts/validator-check.sh specs/{TICKET}-{简述}
```

```bash
# 方式 A 装好后，每个新任务自动/手动触发
bash ~/.claude/skills/specs-engine/scripts/scaffold.sh new .claude/specs {TICKET}-{简述} [--depth light|standard|heavy]
#   light=单文件Bug/配置 | standard=功能开发(默认) | heavy=架构/计费·库存·权限
```

先看 `specs-engine/examples/demo-bugfix/` —— 一份填好的轻量 Spec，30 秒建立"填好的 spec 长什么样"的锚点。

## 布局

```
xingtu-sdd/
├── specs-engine/            # SDD 引擎（2026-09-07 起，可独立安装/分发）
│   ├── SKILL.md             # Skill 入口：触发词 + 意图路由 + 深度裁减（SSOT）
│   ├── references/          # 方法论：core(三铁律+五阶段+文件规范) / orchestration(并行)
│   ├── templates/           # 编号制 8 骨架：00_README ~ 05_validator + execution-log + laws
│   ├── scripts/             # scaffold.sh(new 建 Spec) + validator-check.sh(静态门禁)
│   ├── examples/           # demo-bugfix：填好的轻量 Spec 样例
│   └── README.md            # 引擎使用手册
├── case-studies/            # 🆕 实践案例库（L1 索引 + 精选 5 案例全文：真实 Spec 长什么样）
├── specs/                   # 历史 Spec 目录（_TEMPLATE.legacy-20260907 = 旧空模板归档）
├── SELF.md / README.en.md / LICENSE
```

## Spec 标准结构（编号制，单一事实源）

```
00_README.md        # 任务总览 + 生命周期 + 复盘
laws.md             # 方法论薄锚点（铁律/门禁，随 spec 落盘，自包含可读）
01_analysis.md      # 问题分析 + 根因 + 影响面
02_requirements.md  # 需求规格 + 可测试 AC + 安全三条件（退出/幂等/回滚）
03_design.md        # 方案设计 + 架构决策
04_tasks.md         # 任务拆解 + 依赖图 + 时间戳
05_validator.md     # 可执行验证（curl/SQL），写完必跑
execution-log.md    # 事件日志（append-only 事实源）
```

五阶段：**analysis → requirements → design → tasks → validator → Code**。代码是 validator 验证驱动的执行产物，失败修码重跑闭环。

## 三条铁律

| # | 铁律 | 含义 |
|---|------|------|
| 1 | **No Spec, No Code** | 方案未文档化不写实现代码 |
| 2 | **Spec is Truth** | 文档与代码冲突，代码是 Bug，改代码 |
| 3 | **Reverse Sync** | 发现 Bug 先补文档（根因/漏 AC/回归用例），再改代码 |

## 为什么可迁移、不分叉

- 方法论 SSOT 单点维护，改一处全项目生效；项目内只有 Spec 快照，不存方法论副本。
- 每 Spec 自带 `laws.md` → 归档/分享对团队自包含，不依赖私有索引。
- 默认示例取自软件后端场景，模板已标注"按技术栈裁剪"——不绑 Java/微服务/特定工具。

## 运行前提与限制

- **作为 Skill**：依赖 Claude Code 的 skill 触发（说人话自动路由）；无 CC 环境时**退化为纯方法论 + 手动执行**（脚本是独立 bash 可裸跑）。
- **纪律非强制**：护栏靠流程 + `validator-check.sh` 静态占位符门禁；不自动硬拦 git hook。
- **不生产代码**：管"想清楚与验收"，不管"写实现"。

## 关于作者

我是**行途**，一线技术人 + 仍在写代码。xingtu-sdd 是我在 Vibe coding 实践中沉淀的规格驱动开发骨架——AI 写代码越快，spec 越要先对齐。

- 🔔 公众号 **「行途技术手记」**：微信搜索关注，看 AI 工程化落地实战
- 🐙 GitHub：[@xingtu1996](https://github.com/xingtu1996)
- 📦 仓库：[xingtu1996/xingtu-sdd](https://github.com/xingtu1996/xingtu-sdd)

---


## 许可证与联系

本仓库采用 **MIT License**。代码、模板、文档可自由使用、修改与商用，保留版权声明即可。署名：行途 / xingtu1996。出版合作 / 深度咨询请联系作者。

完整方法论深度篇与实战案例 → 《行途 AI 工程化手册》（出版筹备中）
深度答疑 / 定制陪跑 → 公众号「行途技术手记」留言

---

## 👤 关于行途

一线 builder，仍在写代码。专注 AI 工具链与工程化落地，分享可抄作业的实战经验。

- 𝕏 X：[@xingtu1996](https://x.com/xingtu1996)（AI工程化实战，build in public）
- GitHub：[github.com/xingtu1996](https://github.com/xingtu1996)
- 🌐 个人站：[xingtu1996.pages.dev](https://xingtu1996.pages.dev)
- 📱 公众号：「行途技术手记」（深度长文 + 可抄作业的实战经验）

# specs-engine — Spec 驱动开发方法论引擎

> 一句话：**让 AI「先想清楚，再写代码」**——把需求固化成结构化 Spec（规格），验收标准先行，代码只是规格的执行产物。
> 大白话：跟 AI 干活前先签一份「合同」（规格），写明要什么、怎么验收；AI 照做，做完拿合同逐条验收。可预期、可审计、可复现。
> 这是 Claude Code 的一个 Skill。示例见 [examples/demo-bugfix/](./examples/demo-bugfix/)。

## 为什么有它（对比 2026 主流方案）

业界已有 OpenSpec / GitHub spec-kit（命令驱动：记 `/speckit.xxx` 命令，人学工具）。specs-engine 走相反路线——**意图路由，不是命令驱动**：工具适应人，不是人适应工具。

| 维度 | OpenSpec / spec-kit | specs-engine |
|------|--------------------|:---:|
| 触发 | 用户记命令 → 敲 `/speckit.specify` | **说人话**（"按 specs 标准推进 X"）→ AI 意图路由自判断 |
| 深度 | 固定一套流程 | **深度可裁**：单文件 Bug 轻量 2 文件，架构改造重量全量 |
| 学习成本 | 学 8-19 个命令/阶段 | 零——说需求即可 |
| 演进 | 靠更多命令/扩展 | 靠行为规则积累：踩坑 → 提炼规则 → 反哺（复利） |
| 落地 | CLI 工具链 | 全局 Skill + 每 spec 自包含 `laws.md` + scaffold 骨架 |
| 可观测 | CLI 为主 | spec 索引 README + execution-log 事件流（可挂 dashboard 看板） |

## 安装与使用（三步）

```bash
# 0. 安装：把 specs-engine 放到用户级 skills（所有项目生效；改一处全局升级）
cp -r specs-engine ~/.claude/skills/     # 或 symlink

# 1. 每个新任务（AI 也可自动触发：说"按 specs 标准推进"）
bash ~/.claude/skills/specs-engine/scripts/scaffold.sh new .claude/specs {TICKET}-{简述} [--depth light|standard|heavy]

# 2. 按五阶段推进，05_validator 写完自查
bash ~/.claude/skills/specs-engine/scripts/validator-check.sh .claude/specs/{TICKET}-{简述}
```

- `--depth`：`light`(单文件 Bug/配置) | `standard`(功能开发，默认) | `heavy`(架构/计费·库存·权限)
- 父目录/README 索引自动创建与加行；每个 spec 统一落 8 骨架文件，深度只约束"AI 必填哪些"
- 先看一遍 [examples/demo-bugfix/](./examples/demo-bugfix/) 了解一份填好的 spec 长什么样

## 目录结构

```
specs-engine/
├── README.md                # 本文件
├── SKILL.md                 # 入口：触发词 + 意图路由表 + 深度裁减表（SSOT）
├── references/
│   ├── core.md              # 方法论正文：三铁律 + 五阶段 + 文件规范 + 门禁
│   └── orchestration.md     # 多 Spec 并行（仅并行场景读）
├── templates/               # 编号制 8 骨架：00_README / laws / 01_analysis ~ 05_validator / execution-log
├── scripts/
│   ├── scaffold.sh          # new：建 spec 骨架 + 索引加行（模板只从全局 cp，不产项目快照）
│   └── validator-check.sh   # 静态检查 validator 填充完整性（占位符残留真门禁）
└── examples/
    └── demo-bugfix/         # 一份填好的轻量 spec（教程锚点）
```

## 为什么「可迁移、不分叉」

- 方法论 SSOT 在全局 skill：一处修改 → 所有项目即刻生效；项目内只有 spec 快照，不存方法论副本。
- 每个 spec 自带 `laws.md` 薄锚点 → 归档/分享给团队仍自包含可读，不依赖私人索引。
- 默认示例取自软件后端场景，模板内已标注"按技术栈裁剪/无对应物删行"——不绑 Java/微服务/特定检索工具。

## 运行前提与限制（诚实声明）

- **运行环境**：这是 Claude Code Skill，靠 CC 的 skill 路由触发（模型按 description + 触发词判断）。无 CC 环境时退化为**纯方法论 + 手动执行**（scaffold 脚本是独立 bash，可裸跑；填 spec 由人/AI 手动按规范走）。
- **这是文档纪律，非代码强制**：方法论的护栏靠流程与习惯（加一个 `validator-check.sh` 做占位符静态门禁）；不做 git hook 硬拦截——纪律先行，工具渐进补。
- **不生产代码**：specs-engine 管"想清楚与验收"，不管"写实现"；它不替代编码工具。

## 当前状态与演进

- 2026-09-07 建：方法论从 40+ 真实 spec 实战蒸馏（电商供应链场景），去业务绑定后通用化。
- **二期候选**：English README 钩子 / roadmap / dashboard 看板集成 / example 扩充（多深度样例）。
- **License**：随发布载体确定（默认 MIT/Apache 二选一，内容快照遵循载体协议）。发布渠道：可作独立 skill 开源，或并入既有开源矩阵仓。

## 相关

- 姊妹文档：方法论演进与项目差异分析见 tfm-ng `specs-harness` spec（本项目为其收敛落地）。

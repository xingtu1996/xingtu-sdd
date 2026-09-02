# XingTu SDD · 规格驱动开发方法论

> 一套可复现的 AI 工程化规格工作流：先 Spec、后 Code，从实践中蒸馏。

![CC BY-NC-SA 4.0](https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-lightgrey.svg)

## 🎯 这是什么

`xingtu-sdd` 是行途开源矩阵的**规格驱动开发（SDD）方法论资产仓**。核心思想：**SDD（Spec-Driven Development）——no specs, no code**。任何复杂任务，先写规格（Spec），明确目标/约束/验收标准，再动手编码，让 AI 产出可预期、可审计、可复现的结果。

本仓聚合了大量真实项目实践中打磨出的 Spec 模板、流程与案例，是作品集中**最能体现方法论深度**的资产。

## 📦 用法

```bash
# 查看全部 specs
ls specs/

# 基于模板开始一个新 spec
cp specs/_TEMPLATE/00_README.md my-task/
```

## 📐 Spec 标准结构

每个 spec 遵循统一编号结构：

```
00_README.md       # 任务总览 + 一句话目标
01_analysis.md     # 背景/约束/边界分析
02_requirements.md # 需求规格
03_design.md       # 方案设计
04_tasks.md        # 任务拆解
05_validator.md    # 验收标准
06_execution-log.md# 执行日志（可选）
```

## 🗂 Spec 清单

| Spec | 说明 | 状态 |
|------|------|:---:|
| specs/_TEMPLATE | SDD 六文件模板（requirements / design / tasks / estimation / validator / README）| ✅ 可用 |

> 使用方法：复制 `_TEMPLATE` 到新任务目录 → 依次填 requirements → design → tasks/estimation → validator 门禁 → 交付。

## 🧠 为什么重要

- **可复现**：同一任务按 spec 流程，结果可预期
- **可审计**：每步有依据、有验证
- **可复用**：方法论跨项目、跨团队通用

## 📄 许可证

本仓库为**方法论/内容型资产**，采用 **CC BY-NC-SA 4.0**（署名-非商业使用-相同方式共享）授权。

- **署名**：转载/引用需保留作者署名（行途 / xingtu1996）及出处
- **非商业**：禁止用于商业用途（包括但不限于：商用课程、商业出版物、付费产品）
- **相同方式共享**：演绎作品须以相同协议发布

完整条款见 [LICENSE](./LICENSE)。商业使用 / 出版合作请联系作者。

---

> AI 辅助创作 · 内容基于真实工程实践

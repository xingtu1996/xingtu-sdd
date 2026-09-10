# XingTu SDD · Spec-Driven Development Methodology

> A reproducible AI engineering workflow: spec first, code second. Distilled from real practice.

![CC BY-NC-SA 4.0](https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-lightgrey.svg)

## 🎯 What is this

`xingtu-sdd` is the **Spec-Driven Development (SDD) methodology** repository of the XingTu open-source matrix. Core idea: **no specs, no code**. For any non-trivial task, write a Spec first — clarifying goals, constraints, and acceptance criteria — before writing code. This makes AI output predictable, auditable, and reproducible.

This repository aggregates Spec templates, workflows, and case studies polished through real project practice. It is the most methodology-heavy asset in the portfolio.

## 📦 Usage

```bash
# List all specs
ls specs/

# Start a new spec from template
cp specs/_TEMPLATE/00_README.md my-task/
```

## 📐 Standard Spec Structure

Every spec follows a numbered structure:

```
00_README.md        # Overview + one-line goal
01_analysis.md      # Background / constraints / boundaries
02_requirements.md  # Requirements spec
03_design.md        # Solution design
04_tasks.md         # Task breakdown
05_validator.md     # Acceptance criteria
06_execution-log.md # Execution log (optional)
```

## 🗂 Spec List

| Spec | Description | Status |
|------|-------------|:---:|
| _TEMPLATE | New spec template | ✅ |

> Filling in progress, reviewed one by one.

## 🧠 Why it matters

- **Reproducible**: same task via spec workflow → predictable results
- **Auditable**: every step has evidence and verification
- **Reusable**: methodology works across projects and teams

## 📄 License

This repository is a **methodology/content asset**, licensed under **CC BY-NC-SA 4.0** (Attribution-NonCommercial-ShareAlike 4.0 International).

- **Attribution**: You must give appropriate credit to the author (行途 / xingtu1996) and provide a link to the license.
- **NonCommercial**: You may not use the material for commercial purposes (including but not limited to: paid courses, commercial publications, commercial products).
- **ShareAlike**: If you remix, transform, or build upon the material, you must distribute your contributions under the same license.

See [LICENSE](./LICENSE) for the full terms. For commercial use / publishing cooperation, contact the author.

---

> AI-assisted creation · Based on real engineering practice

# 行途技术 SDD · Spec-Driven Development Methodology

> A reproducible AI engineering workflow: spec first, code second. Distilled from real practice.

![MIT License](https://img.shields.io/badge/License-MIT-green.svg)

## 🎯 What is this

`xingtu-sdd` is the **Spec-Driven Development (SDD) methodology** repository of the 行途技术 open-source matrix. Core idea: **no specs, no code**. For any non-trivial task, write a Spec first — clarifying goals, constraints, and acceptance criteria — before writing code. This makes AI output predictable, auditable, and reproducible.

It ships as an **installable engine** (`specs-engine/`): intent-based routing (speak naturally, no slash commands to memorize), depth tailoring (light 2-file bugfix → heavy full-suite), static gates, cross-session resume, parallel orchestration, and an evidence-trio directory convention. See the [Chinese README](./README.md) for the full story and the v1 → v2 → v2.1 evolution.

## 📦 Quick Start

```bash
# Option A: install as a Claude Code skill (natural-language triggers)
cp -r specs-engine ~/.claude/skills/specs-engine

# Option B: run the scripts directly (pure bash, no dependency)
bash specs-engine/scripts/scaffold.sh new specs {TICKET}-{summary} --depth standard
bash specs-engine/scripts/validator-check.sh specs/{TICKET}-{summary}

# v2: resume across sessions / parallel phases / dashboard / recall
bash specs-engine/scripts/sdd.sh resume specs/<dir>
bash specs-engine/scripts/sdd.sh dashboard specs/

# v2.1: evidence trio dirs (only for long-running, multi-version, client-facing work)
bash specs-engine/scripts/scaffold.sh new specs {TICKET}-{summary} --with-artifacts
bash specs-engine/scripts/sdd.sh archive specs/<dir> <file> --version V8 --reason "…"
```

## 📐 Standard Spec Structure

```
00_README.md        # Overview + lifecycle + retrospective
laws.md             # Methodology snapshot (self-contained)
01_analysis.md      # Problem + root cause + impact
02_requirements.md  # Testable acceptance criteria + safety triad
03_design.md        # Solution + architecture decisions
04_tasks.md         # Task breakdown + dependency graph
05_validator.md     # Executable verification (curl/SQL), must run
execution-log.md    # Append-only event log = source of truth
deliverables/       # Current valid deliverables only
_prompt/ _work/ _archive/   # [optional] input / process / history trio (criteria in references/artifacts.md)
```

Structural gates **V-1 ~ V-6** (file completeness per depth, placeholders, deliverable references, non-empty log, sub-spec index drift, **archive index reconciliation**) run before close-out.

## 🗂 Case Studies

Real specs distilled from practice, sanitized: see [case-studies/](./case-studies/README.md) — 10 full-text cases (archive pipeline, rule keeper, cross-agent drift, team orchestration, data return loop, npm publish SOP, token saver, daily ops report, pre-deletion asset audit, artifact trio dirs).

## 🧠 Why it matters

- **Reproducible**: same task via spec workflow → predictable results
- **Auditable**: every step has evidence and verification
- **Reusable**: methodology works across projects and teams
- **Lineage you can show**: deliverable versions and their history survive machine-checked reconciliation, not human memory

## 📄 License

This repository is licensed under the **MIT License**.

You are free to use, copy, modify, and distribute this code, templates, and documentation — even for commercial purposes — provided the copyright notice and this permission notice are retained in all copies.

See [LICENSE](./LICENSE) for the full terms. For publishing cooperation / consulting, contact the author.

---

> AI-assisted creation · Based on real engineering practice

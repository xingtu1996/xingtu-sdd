# AGENTS.md — xingtu-sdd

## Repository role
This is the specification-driven development engine and methodology repository.

## Source of truth
Start with `README.md`, then inspect `specs-engine/` and any more specific instructions in the directory being changed. The current code and tests take precedence over unverified README examples.

## Project-specific guardrails
Read the applicable spec, laws, tasks and validator before changing code. Preserve No Spec No Code, Spec is Truth and Reverse Sync. Use the repository's actual scaffold/validator scripts and capture exit codes; never claim a gate passed without execution.

## Shared capabilities
Reusable Skills live in [xingtu-skills](https://github.com/xingtu1996/xingtu-skills), while shared rules, hooks and SDD assets are maintained in their respective repositories. A link to another repository is **not** automatic instruction inheritance or skill installation. Verify compatibility and use an explicit, reviewable install/version mechanism before invoking shared assets.

## Change protocol
1. Inspect existing repository instructions, source and relevant tests.
2. For nontrivial work, write or update an SDD spec with acceptance criteria before implementation.
3. Work on an isolated branch and open a reviewable PR. Do not change visibility, licenses, secrets, release settings or default branches as part of routine governance.
4. Run only safe, applicable checks; report exact commands, results and unrun checks as NOT_RUN.
5. Do not publish private Vault contents, internal paths, credentials or personal data. Keep changes reversible and record the commit SHA.

## Codex 本地仓与交付

- 行途标准本地仓为 `github/xingtu-sdd/`。开工先核对 Git 根目录、工作区状态、`origin`、分支及上游；本地工作树优先，不默认使用 `/tmp`。
- 使用本仓真实 scaffold/validator 在本地验证并记录退出码；然后隔离分支 commit、push，并核对本地 HEAD、远端分支 SHA 与 PR head SHA 一致后再报告同步。
- 已有同目标 PR 时核对 base/head、变更文件和状态，优先复用；发现并发冲突先停下报告，不覆盖。不得自动合并或发布。
- 本指南中文为主；命令、路径、Spec 字段及技术标识保留原文。

# 技能分档台账 triage（P1 交付物 v1）

> 生成: 2026-11-04 16:00 | 扫描器: 依赖/品牌/工作流绑定正则启发式 | 待人工终评标注 🔍

## 汇总

| 档 | 数量 | 判据 | 动作 |
|---|---:|---|---|
| A 通用件 | 49 | 零本地路径/零品牌词/零工作流依赖 | 首批上架候选 |
| B 需剥离 | 44 | 有品牌署名行或 tools 引用，方法论本体通用 | 剥离改造后上架 |
| C 不卖 | 45 | 行途业务流/数据流绑定 | 永不对外 |


## A 档 · 可直接上架

改造成本≈0，只需 description AGO 规范化

| 技能 | 文件数 | 带脚本 | 绑定点 |
|---|---:|:--:|---|
| ai-repo-engineering-layout | 1 |  | — |
| ardot-effect-fallback | 1 |  | — |
| canvas-design | 84 |  | — |
| caveman | 2 |  | — |
| caveman-commit | 2 |  | — |
| caveman-compress | 10 | ✓ | — |
| caveman-evidence-review | 1 |  | — |
| caveman-explore | 3 |  | — |
| caveman-help | 2 |  | — |
| caveman-learn | 5 |  | — |
| caveman-manage | 1 |  | — |
| caveman-optimize | 1 |  | — |
| caveman-review | 2 |  | — |
| caveman-setup | 1 |  | — |
| caveman-stats | 2 |  | — |
| desktop-ai-forensics | 3 | ✓ | — |
| discernment-nudge | 2 |  | — |
| doc-translate | 2 | ✓ | — |
| ego-browser | 20 | ✓ | — |
| egress-allowlist | 1 |  | — |
| eval-skills | 1 |  | — |
| evolve-skills | 1 |  | — |
| git-push-in-sandbox | 1 |  | — |
| investigate-first | 2 |  | — |
| lean-build | 2 |  | — |
| library-dashboard-workbench | 1 |  | — |
| meeting-archive | 6 | ✓ | — |
| migration | 2 |  | — |
| ollama-local-ops | 1 |  | — |
| ponytail | 1 |  | — |
| ponytail-audit | 1 |  | — |
| ponytail-debt | 1 |  | — |
| ponytail-gain | 1 |  | — |
| ponytail-help | 1 |  | — |
| ponytail-review | 1 |  | — |
| project-whitepaper | 1 |  | — |
| safe-refactor | 2 |  | — |
| skill-vetter | 2 |  | — |
| specs-engine | 26 | ✓ | — |
| stakeholder-register | 3 | ✓ | — |
| surgical-patch | 2 |  | — |
| token-audit | 2 | ✓ | — |
| ubiquitous-language | 8 | ✓ | — |
| verify-and-stop | 2 |  | — |
| wb-usage-cost-audit | 2 | ✓ | — |
| workspace-inventory-governance | 2 | ✓ | — |
| worktree-parallel | 1 |  | — |
| writing-guidelines | 1 |  | — |
| zero-cost-visuals-iconify | 1 |  | — |

## B 档 · 剥离后上架

改造成本 0.5~2h/个：删品牌行、路径参数化、案例通用化

| 技能 | 文件数 | 带脚本 | 绑定点 |
|---|---:|:--:|---|
| adversarial-review | 1 |  | 品牌词×17 |
| ai-session-material-miner | 1 |  | 品牌词×12；tools依赖×4 |
| ai-usage-report | 5 | ✓ | 品牌词×12 |
| audio-friendly-adapt | 1 |  | 品牌词×12 |
| automation-resurrection | 1 |  | 品牌词×1 |
| book2vido-video | 3 | ✓ | 品牌词×2 |
| brand-icon-sourcing | 2 |  | tools依赖×2 |
| cc-switch-usage-audit | 1 |  | tools依赖×1 |
| concept-anchor-figure | 3 |  | 品牌词×15；tools依赖×2 |
| conference-archive | 1 |  | 品牌词×9 |
| content-format-audit | 2 |  | 品牌词×38；tools依赖×4 |
| cross-repo-skill-curation | 2 |  | 品牌词×11 |
| de-ai-flavor | 1 |  | 品牌词×10 |
| effort-accounting | 2 | ✓ | 本地路径×3 |
| exam-prep-pmp | 1 |  | 品牌词×1 |
| fact-check-gate | 1 |  | 品牌词×8 |
| free-token-channel-audit | 1 |  | 品牌词×3 |
| git-identity-pin | 3 | ✓ | 品牌词×9 |
| github-repo-gallery | 1 |  | 本地路径×1 |
| hidden-contract-audit | 1 |  | 品牌词×2 |
| ip-platform-fit-audit | 1 |  | 品牌词×16；tools依赖×1 |
| mp-group-audience-check | 2 | ✓ | 本地路径×1；品牌词×8 |
| mp-group-push-copy | 2 |  | 品牌词×17；tools依赖×2 |
| mp-prepublish-draft-verify | 1 |  | 品牌词×3；tools依赖×9 |
| mp-sentiment-tracker | 6 |  | 品牌词×12 |
| mp-title-collision-rename | 2 |  | 品牌词×15；tools依赖×8 |
| pkg-healthcheck | 6 | ✓ | 品牌词×10；tools依赖×1 |
| pub-infographic-supplement | 2 |  | 品牌词×13；tools依赖×6 |
| publish-pack-planning | 1 |  | 品牌词×7；tools依赖×2 |
| publish-package-review | 2 | ✓ | 品牌词×1 |
| python-cli-to-macos-app | 1 |  | 本地路径×1 |
| readme-frontpage-audit | 1 |  | 品牌词×3 |
| repo-rename-desensitize | 1 |  | 本地路径×3；品牌词×4 |
| skill-inbox-triage | 2 |  | 品牌词×7；tools依赖×2 |
| skill-naming-evidence | 1 |  | tools依赖×1 |
| sqlcipher-offline-verify | 1 |  | 品牌词×4 |
| svgtopng-cn-fonts | 1 |  | 本地路径×1；品牌词×4 |
| talkinghead-trim | 3 |  | 品牌词×2 |
| toolbelt-scan | 2 | ✓ | 品牌词×1；tools依赖×1 |
| wechat-cover-gen | 3 |  | 品牌词×23 |
| wechat-draft-api | 2 | ✓ | 品牌词×12；tools依赖×3 |
| wechat-mp-publish | 4 | ✓ | 品牌词×15；tools依赖×1 |
| wechat-tuitu-publish | 1 |  | 本地路径×3；品牌词×9；tools依赖×2 |
| xiaobot-ops | 1 |  | 品牌词×9 |

## C 档 · 不卖

绑定 boss 数据流/身份/排期，上架=泄密

| 技能 | 文件数 | 带脚本 | 绑定点 |
|---|---:|:--:|---|
| boss-autopilot | 1 |  | 品牌词×11 |
| cavecrew | 2 |  | — |
| caveman-discover | 1 |  | — |
| certification-submission-kit | 3 | ✓ | 品牌词×27；tools依赖×17 |
| comment-reply-playbook | 1 |  | 品牌词×4；tools依赖×1；业务流×1 |
| constitution-amendment | 1 |  | 品牌词×8 |
| content-matrix-channel-audit | 2 |  | 品牌词×18；tools依赖×3；业务流×3 |
| daily-judgment-brief | 2 |  | 品牌词×6；tools依赖×1；业务流×4 |
| daily-report | 1 |  | — |
| doubao-app-layer-archive | 5 | ✓ | 品牌词×1；业务流×1 |
| fanout-mainline-ledger | 2 |  | — |
| harness-governance | 1 |  | — |
| harness-model-upgrade-audit | 1 |  | 品牌词×1 |
| legal-compliance-baseline | 3 |  | 品牌词×15；tools依赖×14；业务流×1 |
| monetization-actions | 1 |  | 品牌词×15；业务流×5 |
| mp-daily-ops-report | 2 |  | 品牌词×26；tools依赖×18；业务流×4 |
| mp-distribution-evidence-loop | 1 |  | 品牌词×12；tools依赖×5；业务流×2 |
| mp-publish-sop | 6 | ✓ | 品牌词×34；tools依赖×7；业务流×5 |
| published-article-archive | 1 |  | 本地路径×13；品牌词×16；tools依赖×3；业务流×8 |
| session-distill | 1 |  | 业务流×2 |
| session-sediment | 1 |  | 品牌词×7；业务流×8 |
| spec-driven-adversarial-workflow | 2 |  | 品牌词×24；tools依赖×5；业务流×6 |
| topic-overlap-check | 1 |  | 品牌词×4；业务流×4 |
| wechat-mp-analytics | 3 |  | 品牌词×28；tools依赖×8；业务流×1 |
| x-auto-publish | 1 |  | 品牌词×13；业务流×1 |
| xingtu-article-archive | 1 |  | 本地路径×1；品牌词×8；tools依赖×4；业务流×1 |
| xingtu-article-sync | 1 |  | 品牌词×4；tools依赖×6 |
| xingtu-blue-ocean-strategy | 8 |  | 品牌词×14 |
| xingtu-collab-evolution-loop | 1 |  | 品牌词×5；tools依赖×2 |
| xingtu-content-craft | 1 |  | 品牌词×20；tools依赖×6；业务流×1 |
| xingtu-expression-logic | 1 |  | 品牌词×11 |
| xingtu-ingest | 1 |  | 品牌词×4；业务流×3 |
| xingtu-knowledge-compounding | 1 |  | 品牌词×22；tools依赖×1 |
| xingtu-multiplatform-distribution | 4 | ✓ | 品牌词×29；tools依赖×18；业务流×1 |
| xingtu-orchestrate | 1 |  | 品牌词×22；tools依赖×1 |
| xingtu-oss-guard | 1 |  | 品牌词×9；tools依赖×21 |
| xingtu-role-audit | 2 | ✓ | 品牌词×6 |
| xingtu-rule-keeper | 1 |  | 品牌词×4 |
| xingtu-token-saver | 3 | ✓ | 品牌词×2 |
| xingtu-workspace-context | 1 |  | 品牌词×24；业务流×1 |
| xt-automation-ops | 1 |  | 本地路径×4；品牌词×7；tools依赖×3 |
| yuanbao-archive-pipeline | 1 |  | 品牌词×4；tools依赖×2；业务流×5 |
| yuanbao-article-fetch | 1 |  | 品牌词×3 |
| zcode-client-ops | 1 |  | — |
| zcode-session-export | 2 | ✓ | 本地路径×4；品牌词×3；tools依赖×2 |

## 首批 3 个改造清单（boss 已批，两周 0→1）

| # | 技能 | 具体改造点（11-04 定位） | 预估 |
|---|---|---|---|
| 1 | de-ai-flavor | ①标题/正文 3 处「行途 XingTu 适配版」→通用版 ②PUB-027 口径引用删行途编号 ③样本语境段改「以目标作者已发文本为样本」 | ~1h |
| 2 | concept-anchor-figure | ①守卫行「先读根 AGENTS.md 含行途才继续」→删除/改为自包含 ②品牌色板→参数化（默认配色可配） ③fig_fit 渲染依赖→内联或给出等价渲染命令 ④署名行参数化 | ~2h |
| 3 | svgtopng-cn-fonts | ①1 处 ~/xingtu 示例路径→占位符 ②「必带品牌信息」段→删或通用化 ③维护人署名→通用 | ~0.5h |

## 终评待办
- 🔍 76 个品牌词命中中，多数疑为「行途 XingTu 出品」署名行——逐个区分「署名（可留可改）」vs「工作流绑定（必须剥离）」
- 🔍 A/B 档交界个案（exam-prep-pmp、meeting-archive、conference-archive 等）人工复核
- 上架前每批必跑 TC-01 脱敏闸门（privacy_scan + 47 词 grep）

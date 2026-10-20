#!/bin/bash
# ============================================================================
# validator-check — Spec 静态门禁（全局单份，不随 spec 复制）
#
# 2026-10-20 扩展：此前只检查 05_validator.md，导致"缺 02/03 的 spec 也全部通过"。
# 现分两类门禁：
#
#   内容门禁（原有）
#     - 05_validator 章节完整性 / 模板占位符 / 安全三条件 / 用例统计
#
#   结构门禁（新增）
#     V-1 文件结构：按深度档校验必需文件；轻量档必须声明裁剪
#     V-2 占位符残留：全部 .md 扫描（{Spec 标题}/{TICKET}/{YYYY-…}…）
#     V-3 产出表落地：00_README「产出」节引用的 .md 是否真实存在
#     V-4 执行日志：execution-log 是否只是空骨架（HAIT-031 完成即记账）
#     V-5 子 Spec 索引对账（原有）
#
# 级别策略（向后兼容）
#   - 引擎格式（00_README.md 存在）：V-1 缺文件 = ERROR（只命中真缺陷）
#   - 历史格式（README.md + analysis.md…）：结构问题一律 WARN，不追溯罚款
#   - V-2/V-4/文件头：恒为 WARN（存量普遍未按新规范写，置 ERROR 会全红）
#   - V-3：状态已 ✅ 仍引用不存在的产出 = ERROR（声称完成却没产出）；
#          进行中 = WARN（可能只是计划产出）
#
# 用法:
#   bash validator-check.sh [spec_dir]     # 默认当前目录
#   bash validator-check.sh --help
# ============================================================================
set -euo pipefail

usage() {
    awk 'NR>1 {
        if ($0 ~ /^# =+$/) { if (seen) exit; seen = 1; next }
        if ($0 !~ /^#/) exit
        sub(/^# ?/, ""); print
    }' "$0"
    exit 0
}

case "${1:-}" in -h|--help) usage ;; esac

SPEC_DIR="${1:-.}"
ERRORS=0
WARNINGS=0
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

err()  { echo -e "${RED}❌ $*${NC}";       ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  $*${NC}";   WARNINGS=$((WARNINGS + 1)); }
ok()   { echo -e "${GREEN}✅ $*${NC}"; }

# ---------- 0. 格式 / 状态识别 ----------
if [ -f "$SPEC_DIR/00_README.md" ]; then
    FORMAT=engine
    MAIN_README="$SPEC_DIR/00_README.md"
elif [ -f "$SPEC_DIR/README.md" ]; then
    FORMAT=legacy
    MAIN_README="$SPEC_DIR/README.md"
else
    echo -e "${RED}❌ 既无 00_README.md 也无 README.md，这不是 Spec 目录: $SPEC_DIR${NC}"
    exit 1
fi

# 状态（00_README/README 前 10 行状态行；取不到视为未知）
STATUS=$(head -10 "$MAIN_README" | grep -oE '状态[:：][[:space:]]*[^ |]+' | head -1 | sed -E 's/状态[:：][[:space:]]*//' || true)
[ -n "$STATUS" ] || STATUS="未知"

echo "==== validator-check: $SPEC_DIR ===="
echo "     格式: $FORMAT | 状态: $STATUS"

# ---------- 1. 内容门禁：validator ----------
VF=""
if [ -f "$SPEC_DIR/05_validator.md" ]; then
    VF="$SPEC_DIR/05_validator.md"
elif [ "$FORMAT" = legacy ] && [ -f "$SPEC_DIR/validator.md" ]; then
    VF="$SPEC_DIR/validator.md"
    echo -e "${YELLOW}ℹ️  历史格式：改用 validator.md 检查（章节缺失降级为 WARN）${NC}"
elif [ "$FORMAT" = legacy ]; then
    echo -e "${YELLOW}ℹ️  历史格式且无 validator.md — 跳过内容门禁（存量不追溯，不置 ERROR）${NC}"
else
    # 引擎格式缺 05：不退出，交给 V-1 统一计一次 ERROR（避免重复计数）
    echo -e "${YELLOW}ℹ️  05_validator.md 缺失 — 内容门禁跳过，见 V-1${NC}"
fi

if [ -n "$VF" ]; then
echo ""
echo "--- validator: $VF ---"

# 历史格式的 validator 通常按 V-1/V-2 组织，不套引擎章节字面 → WARN
check_section() {   # $1=正则 $2=名称
    if grep -q "$1" "$VF"; then
        ok "$2"
    elif [ "$FORMAT" = legacy ]; then
        warn "$2 — 缺失（历史格式可接受，新 Spec 应补）"
    else
        err "$2 — 缺失"
    fi
}

check_section "## 一、数据准备" "数据准备"
check_section "## 二、.*验证" "验证用例"
check_section "## 三、.*一致性" "数据一致性"
check_section "## 五、合规检查" "合规检查"

PH=$(grep -cE '\{(简述|TICKET|YYYY-[A-Z]|Spec 标题|正常场景|异常场景)\}' "$VF" || true)
echo ""
echo "--- 模板占位符残留 ---"
if [ "$PH" -eq 0 ]; then
    ok "无占位符残留"
else
    err "$PH 处模板占位符未替换 — 内容仍是骨架，禁止置 ✅"
fi

echo ""
echo "--- 安全三条件（涉及计费/库存/权限/写操作时必填） ---"
grep -qE "(退出条件)" "$VF" && ok "退出条件" || warn "退出条件缺"
grep -qE "(幂等|idempotent)" "$VF" && ok "幂等条件" || warn "幂等条件缺"
grep -qE "(回滚|rollback|恢复)" "$VF" && ok "回滚条件" || warn "回滚条件缺"

CURL=$(grep -c 'curl ' "$VF" || true)
echo ""
echo "--- 用例统计: $CURL 条 curl（纯 SQL/单元场景可忽略） ---"
fi

# ---------- 2. V-1 文件结构（按深度档） ----------
echo ""
echo "--- V-1 文件结构（按深度档） ---"

if [ "$FORMAT" = engine ]; then
    # 深度判定：state.json > 实际缺文件 + 裁剪声明 > 默认 standard
    DEPTH="standard"
    if [ -f "$SPEC_DIR/state.json" ]; then
        SD=$(grep -oE '"depth"[[:space:]]*:[[:space:]]*"[a-z]+"' "$SPEC_DIR/state.json" 2>/dev/null \
             | sed -E 's/.*"([a-z]+)"$/\1/' | head -1 || true)
        case "$SD" in light|standard|heavy|research) DEPTH="$SD" ;; esac
    fi

    # 先看全量缺口，用于判定是否属于"轻量档裁剪"
    PRECHECK_MISSING=""
    for f in 01_analysis.md 02_requirements.md 03_design.md 04_tasks.md 05_validator.md; do
        [ -f "$SPEC_DIR/$f" ] || PRECHECK_MISSING="$PRECHECK_MISSING $f"
    done

    # 有缺口 + 有裁剪声明 → 轻量档；否则按标准档判缺
    if [ "$DEPTH" = standard ] && [ -n "$PRECHECK_MISSING" ]; then
        if grep -qE '裁剪|轻量档|轻量深度|research|调研档' "$MAIN_README" 2>/dev/null; then
            DEPTH="light"
        fi
    fi
    [ "$DEPTH" = light ] && echo "     深度档: 轻量（02/03/04 可裁减）"

    case "$DEPTH" in
        light|research) REQUIRED="01_analysis.md 05_validator.md" ;;
        *)              REQUIRED="01_analysis.md 02_requirements.md 03_design.md 04_tasks.md 05_validator.md" ;;
    esac

    # 只对"该深度档必填"的文件计缺（轻量档不应把 02/03 算成缺失）
    CORE_MISSING=""
    for f in $REQUIRED; do
        [ -f "$SPEC_DIR/$f" ] || CORE_MISSING="$CORE_MISSING $f"
    done
    # 去重
    CORE_MISSING=$(printf '%s\n' $CORE_MISSING | LC_ALL=C sort -u | tr '\n' ' ' || true)
    CORE_MISSING="${CORE_MISSING% }"

    if [ -z "$CORE_MISSING" ]; then
        ok "必需文件齐全（${DEPTH}）"
    else
        err "缺必需文件:$CORE_MISSING"
        if [ "$DEPTH" = standard ] && ! grep -qE '裁剪|轻量档|轻量深度|research|调研档' "$MAIN_README" 2>/dev/null; then
            err "且 00_README 无「裁剪声明」— 轻量档必须显式声明理由（specs-rules §一 裁剪声明义务）"
        fi
    fi

    # execution-log：标准档必填；轻量档允许并入 00_README
    if [ ! -f "$SPEC_DIR/execution-log.md" ]; then
        if [ "$DEPTH" = light ] || [ "$DEPTH" = research ]; then
            echo -e "${YELLOW}ℹ️  轻量档无 execution-log（允许并入 00_README 复盘）${NC}"
        else
            err "缺 execution-log.md（标准档必填，HAIT-031 完成即记账）"
        fi
    fi
    [ -f "$SPEC_DIR/laws.md" ] || warn "缺 laws.md（方法论薄快照，scaffold 应落盘）"
else
    # 历史格式：README + analysis + validator 为最小集，缺 → WARN
    LEGACY_MISSING=""
    for f in analysis.md validator.md; do
        [ -f "$SPEC_DIR/$f" ] || LEGACY_MISSING="$LEGACY_MISSING $f"
    done
    if [ -z "$LEGACY_MISSING" ]; then
        ok "历史格式最小集齐全（README + analysis + validator）"
    else
        warn "历史格式缺:${LEGACY_MISSING}（存量不追溯，新建请用引擎格式）"
    fi
fi

# ---------- 3. V-2 占位符残留 + 文件头 ----------
echo ""
echo "--- V-2 占位符与文件头 ---"
PH_FILES=$(grep -lE '\{(简述|TICKET|YYYY-[A-Z]|Spec 标题|author|父 Spec 相对路径|父主题|子主题)\}' "$SPEC_DIR"/*.md 2>/dev/null | xargs -n1 basename 2>/dev/null | tr '\n' ' ' || true)
PH_FILES="${PH_FILES% }"
if [ -z "$PH_FILES" ]; then
    ok "全部 .md 无模板占位符残留"
else
    warn "模板占位符残留: ${PH_FILES}（置 ✅ 前必须全部替换）"
fi

HDR_MISSING=""
for f in "$MAIN_README" "$SPEC_DIR"/0[1-5]_*.md; do
    [ -f "$f" ] || continue
    head -8 "$f" | grep -qE '生成时间|用途|创建[:：]' || HDR_MISSING="$HDR_MISSING $(basename "$f")"
done
HDR_MISSING="${HDR_MISSING# }"
if [ -z "$HDR_MISSING" ]; then
    ok "组件文件头齐全（生成时间/用途/创建）"
else
    warn "缺文件头（前 8 行无 生成时间/用途/创建）: $(printf '%s' "$HDR_MISSING" | tr ' ' ',')"
fi

# ---------- 4. V-3 产出表引用落地 ----------
echo ""
echo "--- V-3 产出表引用落地 ---"
SEC=$(awk '/^## .*(产出|交付物|交付件)/{f=1;next} /^## /{f=0} f' "$MAIN_README" 2>/dev/null || true)
if [ -z "$SEC" ]; then
    echo -e "${YELLOW}ℹ️  未找到「产出」节，跳过引用核对${NC}"
else
    REFS=$( { printf '%s\n' "$SEC" | grep -oE '`[^`]+\.md`' | sed -E 's/^`//; s/`$//' || true
              printf '%s\n' "$SEC" | grep -oE '\]\([^)]+\.md\)' | sed -E 's/^\]\(//; s/\)$//' || true
            } | LC_ALL=C sort -u || true )
    # 注意：macOS 默认 locale 下 `sort -u` 会把不同中文文件名判成等价（实测 9 行只剩 5 行），
    # 必须 LC_ALL=C —— 否则引用核对会静默漏掉一半。首次踩坑见修复记录 20261020。
    MISSING_REFS=""          # 换行分隔 —— 不用空格：坏 locale 下 wc -w 会把中文名数错
    while IFS= read -r ref; do
        [ -n "$ref" ] || continue
        # 跳过：占位符、外链、绝对路径、锚点、通配符模式（如 文档包_*/06-xx.md，按模式表述而非具体产物）
        case "$ref" in *'{'*|http*|/*|'#'*|*'*'*) continue ;; esac
        ref="${ref#./}"
        [ -f "$SPEC_DIR/$ref" ] && continue
        [ -f "$SPEC_DIR/deliverables/$(basename "$ref")" ] && continue
        MISSING_REFS="${MISSING_REFS}${ref}"$'\n'
    done <<< "$REFS"
    if [ -z "$MISSING_REFS" ]; then
        ok "产出表引用全部存在"
    else
        NREF=$(printf '%s' "$MISSING_REFS" | grep -c . || true)
        REFLIST=$(printf '%s' "$MISSING_REFS" | tr '\n' ' ')
        if [ "$STATUS" = "✅" ] || [ "${STATUS:0:1}" = "✅" ]; then
            err "产出表 $NREF 条引用不存在（状态已 ✅）:$REFLIST"
        else
            warn "产出表 $NREF 条引用不存在（进行中可先视为计划产出，置 ✅ 前必须补齐或改口径）:$REFLIST"
        fi
    fi
fi

# ---------- 5. V-4 execution-log 非空 ----------
echo ""
echo "--- V-4 execution-log 记账 ---"
if [ -f "$SPEC_DIR/execution-log.md" ]; then
    LOG="$SPEC_DIR/execution-log.md"
    head -1 "$LOG" | grep -q '{Spec 标题}' && warn "标题仍是 {Spec 标题}（P2-1 批量修）"
    # 条目标题兼容 `### 2026-10-20 09:46 · …` 与 `## 2026-10-19 17:00 — …` 两种写法
    ENTRIES=$(grep -cE '^#{2,4} [0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2})?' "$LOG" || true)
    TPL=$(grep -cE '^#{2,4} \{(YYYY-MM-DD|Phase)' "$LOG" || true)
    if [ "$ENTRIES" -eq 0 ]; then
        warn "无带时间戳的真实条目（空骨架，HAIT-031 完成即记账）"
    else
        ok "$ENTRIES 条真实记录"
        [ "$TPL" -gt 0 ] && warn "残留 $TPL 条模板条目未删（{YYYY-MM-DD HH:MM}）"
    fi
else
    echo -e "${YELLOW}ℹ️  无 execution-log.md，跳过（缺失已在 V-1 判定）${NC}"
fi

# ---------- 6. V-5 子 Spec 索引对账 ----------
SUBROOT=""
for c in sub-specs subspecs; do [ -d "$SPEC_DIR/$c" ] && SUBROOT="$SPEC_DIR/$c" && break; done
if [ -n "$SUBROOT" ]; then
    echo ""
    echo "--- V-5 子 Spec 索引对账（父 README ↔ 实有子目录） ---"
    ACTUAL=$(find "$SUBROOT" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
    PARENT_README="$SPEC_DIR/00_README.md"
    if [ ! -f "$PARENT_README" ]; then
        warn "父 00_README.md 不存在，无法对账"
    else
        # 只数「子 Spec 索引段」内的行；无该段（老写法把行混在主索引表里）则数全文
        # 行内只要出现 sub-specs/ 路径即计数，兼容三列旧表与七列新表
        SECTION=$(awk '/^## .*子 Spec/{f=1;next} /^## /{f=0} f' "$PARENT_README" || true)
        if [ -n "$SECTION" ]; then
            LISTED=$(printf '%s\n' "$SECTION" | grep -cE '^\|.*(sub-specs|subspecs)/' || true)
        else
            LISTED=$(grep -cE '^\|.*(sub-specs|subspecs)/' "$PARENT_README" || true)
        fi
        if [ "$ACTUAL" = "$LISTED" ]; then
            ok "索引一致（实有 ${ACTUAL} / 列出 ${LISTED}）"
        else
            err "索引漂移：实有 ${ACTUAL} 个子 Spec，父 README 只列 ${LISTED} 个 — 补齐索引行"
            echo "      ↳ 该漂移在真实项目中发生过三次（只列 1 个 vs 实有 6/10 个）"
        fi
        # 导航指针（新增约定；存量子 Spec 多为历史写法 → WARN 不 ERROR，防假门禁）
        NORMD=0; NOPTR=0
        while IFS= read -r d; do
            if [ ! -f "$d/00_README.md" ]; then
                NORMD=$((NORMD + 1))
            elif ! grep -qE '^>.*父 Spec' "$d/00_README.md"; then
                NOPTR=$((NOPTR + 1)); echo "      ↳ 有 00_README 但缺父指针: ${d#$SPEC_DIR/}/00_README.md"
            fi
        done < <(find "$SUBROOT" -mindepth 1 -maxdepth 1 -type d)
        if [ "$NORMD" -eq 0 ] && [ "$NOPTR" -eq 0 ]; then
            ok "子 Spec 导航齐全（00_README + 父指针）"
        else
            [ "$NORMD" -gt 0 ] && warn "${NORMD} 个子 Spec 无 00_README（存量可接受，新建应有）"
            [ "$NOPTR" -gt 0 ] && warn "${NOPTR} 个子 Spec 缺「> 父 Spec：」指针行（新建应有）"
        fi
    fi
fi

# ---------- 汇总 ----------
echo "==== 汇总 ===="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ 全部通过${NC}"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS 警告（可人工判断）${NC}"
else
    echo -e "${RED}❌ $ERRORS 错误 / $WARNINGS 警告 — 未填完/结构缺失${NC}"
fi
exit $ERRORS

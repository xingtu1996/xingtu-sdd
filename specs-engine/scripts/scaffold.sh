#!/bin/bash
# ============================================================================
# specs-engine scaffold — 物化 Spec 骨架（模板只 cp 自全局 skill，不产项目快照）
#
# 用法:
#   scaffold.sh new <specs父目录> <spec名> [--depth light|standard|heavy] [--tool <agent>]
#     建 {YYYYMMDDHHMM}[-{tool}]-<spec名>/ 骨架；<specs父目录>/README.md 索引自动建+加行
#
#   scaffold.sh sub <父Spec目录> <子Spec名> [--depth light|standard|heavy] [--tool <agent>]
#     建 <父Spec目录>/sub-specs/{YYYYMMDDHHMM}[-{tool}]-<子Spec名>/ 骨架
#     父 README 的「子 Spec」索引段自动建+加行；子 00_README 自动写入父指针
#     子 Spec 不建 laws.md（继承父）/ 不建 execution-log（记父的）—— 见 references/subspec.md
#
#   depth 只约束"AI 必填哪些"（骨架统一落骨架文件）；--tool 缺省读 $XINGTU_TOOL
# ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$HERE/templates"

usage() {
    cat >&2 <<'EOF'
用法:
  scaffold.sh new <specs父目录> <spec名> [--depth light|standard|heavy] [--tool <agent>]
  scaffold.sh sub <父Spec目录> <子Spec名> [--depth light|standard|heavy] [--tool <agent>]
EOF
    exit 1
}

# 解析公共参数：$1=depth变量名 $2=tool变量名，其余为待解析参数
parse_opts() {
    local _depth="$1" _tool="$2"; shift 2
    while [ $# -gt 0 ]; do
        case "$1" in
            --depth) eval "$_depth=\${2:-standard}"; shift 2 ;;
            --tool)  eval "$_tool=\${2:-}"; shift 2 ;;
            *) echo "❌ 未知参数: $1" >&2; exit 1 ;;
        esac
    done
    eval "local d=\$$_depth"
    case "$d" in
        light|standard|heavy) ;;
        *) echo "❌ 未知深度: $d (light|standard|heavy)" >&2; exit 1 ;;
    esac
}

depth_hint() {
    case "$1" in
        light)    echo "   必填: 01_analysis + 05_validator（02/03/04 可删，执行日志并入 00_README 复盘）" ;;
        standard) echo "   必填: 01~05 全五 + execution-log 同步记账" ;;
        heavy)    echo "   必填: 同 standard + 方案对比 + 暂停点 + 人审" ;;
    esac
}

make_dir() {   # $1=父路径 $2=名 $3=tool
    local ts dir
    ts="$(date +%Y%m%d%H%M)"
    if [ -n "$3" ]; then dir="$1/$ts-$3-$2"; else dir="$1/$ts-$2"; fi
    if [ -d "$dir" ]; then
        dir="${dir}$(date +%S)"
        [ -d "$dir" ] && { echo "❌ 目录仍冲突: $dir" >&2; exit 1; }
    fi
    mkdir -p "$dir"
    echo "$dir"
}

cmd_new() {
    [ $# -ge 2 ] || usage
    local parent="${1%/}" name="$2"; shift 2
    [ "${name#--}" != "$name" ] && { echo "❌ spec 名不能以 -- 开头" >&2; exit 1; }
    local depth="standard" tool="${XINGTU_TOOL:-}"
    parse_opts depth tool "$@"

    local dir; dir="$(make_dir "$parent" "$name" "$tool")"
    local base; base="$(basename "$dir")"
    local f
    for f in 00_README.md laws.md 01_analysis.md 02_requirements.md 03_design.md 04_tasks.md 05_validator.md execution-log.md; do
        cp "$TPL/$f" "$dir/" 2>/dev/null || echo "⚠️  模板缺失: $f" >&2
    done
    # 产出物目录（spec 根只放"组件"，一切产出走 deliverables/）
    mkdir -p "$dir/deliverables"
    cp "$TPL/deliverables.README.md" "$dir/deliverables/README.md" 2>/dev/null || true

    local readme="$parent/README.md"
    if [ ! -f "$readme" ]; then
        cat > "$readme" <<'EOF'
# Specs 索引

> Spec 驱动开发目录。方法论见全局 `specs-engine` skill；每个子目录 = 一个 Spec。

## 生命周期

| 状态 | 含义 |
|------|------|
| ⬜ 待启动 | 目录已建，分析未开始 |
| 🔵 进行中 | ≥1 阶段文件完成 |
| ✅ 完成 | tasks 全勾 + 代码已提交 + ✅ 三前置 |

## Spec 列表

| Spec | 简述 | 状态 |
|------|------|:---:|
EOF
    elif ! grep -q '^| Spec |' "$readme"; then
        printf '\n## Spec 列表\n\n| Spec | 简述 | 状态 |\n|------|------|:---:|\n' >> "$readme"
    fi

    # ── 索引行：插到「Spec 列表」表尾，**不是文件尾**（2026-10-15 修 BUG）──
    # BUG：原来是 `printf ... >> "$readme"` —— **无条件追加到文件末尾**。
    #      若 README 的索引表后面还有别的段落（版本历史 / 说明 / 其他表），
    #      新索引行就飘到文件最后，与主表脱节、累积成冗余。
    #      **实测复现 4 次**（2026-09-30 / 10-09 / 10-15 ×2），每次都要手工搬回去。
    # 修法：定位 `| Spec |` 表头之后的最后一个表格行，把新行插在它后面。
    if awk -v row="| [${base}](./${base}/) | ${name} | ⬜ |" '
        /^\| Spec \|/ { inbd=1 }
        inbd && /^\|/ { last=NR }
        inbd && !/^\|/ { if (last) inbd=0 }
        { buf[NR]=$0 }
        END {
            if (!last) exit 3
            for (i=1; i<=NR; i++) { print buf[i]; if (i==last) print row }
        }' "$readme" > "${readme}.tmp" && [ -s "${readme}.tmp" ]; then
        mv "${readme}.tmp" "$readme"
    else
        # 兜底：找不到表（本不该发生）→ 退回追加，并**明确提示需手工搬回**，不静默
        [ -f "${readme}.tmp" ] && mv "${readme}.tmp" "/tmp/scaffold-idx-fallback-$$.tmp" 2>/dev/null
        printf '| [%s](./%s/) | %s | ⬜ |\n' "$base" "$base" "$name" >> "$readme"
        echo "   ⚠️  未找到「Spec 列表」表 —— 索引行已追加到**文件尾**，请手工搬回主表"
    fi

    echo "✅ Spec 骨架已建: $dir  (深度: $depth)"
    depth_hint "$depth"
    echo "   ① 替换占位符 {TICKET}/{YYYY-MM-DD HH:MM}/{author} → 填 00_README 标题"
    echo "   ② 信息不全先澄清，execution-log 记开工首条（澄清状态）"
    echo "   ③ 完成 05_validator 后跑: bash ~/.claude/skills/specs-engine/scripts/validator-check.sh \"$dir\""
}

cmd_sub() {
    [ $# -ge 2 ] || usage
    local parent="${1%/}" name="$2"; shift 2
    [ "${name#--}" != "$name" ] && { echo "❌ 子 Spec 名不能以 -- 开头" >&2; exit 1; }
    [ -f "$parent/00_README.md" ] || { echo "❌ 这不是一个 Spec 目录（缺 00_README.md）: $parent" >&2; exit 1; }
    local depth="standard" tool="${XINGTU_TOOL:-}"
    parse_opts depth tool "$@"

    local root="$parent/sub-specs"
    mkdir -p "$root"
    local dir; dir="$(make_dir "$root" "$name" "$tool")"
    local base; base="$(basename "$dir")"
    local f
    for f in 01_analysis.md 02_requirements.md 03_design.md 04_tasks.md 05_validator.md; do
        cp "$TPL/$f" "$dir/" 2>/dev/null || echo "⚠️  模板缺失: $f" >&2
    done
    cp "$TPL/00_README.subspec.md" "$dir/00_README.md"

    # 子 00_README 头部的父指针（占位符替换）
    local parent_abs parent_name today
    parent_abs="$(cd "$parent" && pwd)"
    parent_name="$(grep -m1 '^# ' "$parent/00_README.md" 2>/dev/null | sed 's/^# *//')"
    # 标题未填（仍是 {占位符}）或取不到 → 退回目录名
    case "$parent_name" in ''|*'{'*) parent_name="$(basename "$parent")" ;; esac
    today="$(date '+%Y-%m-%d %H:%M')"
    sed -i.bak \
        -e "s|{父 Spec 相对路径}|../../00_README.md|" \
        -e "s|{父主题}|$parent_name|" \
        -e "s|{子主题}|$name|" \
        -e "s|{YYYY-MM-DD HH:MM}|$today|" \
        "$dir/00_README.md" && rm -f "$dir/00_README.md.bak"

    # 父 README：确保「子 Spec」索引段存在，并加行（七列：ID/子 Spec/目标/边界/依赖/状态/路径）
    local readme="$parent/00_README.md" rel="sub-specs/$base/"
    if ! grep -q '^## .*子 Spec' "$readme"; then
        printf '\n## 子 Spec（Sub-Spec）\n\n> 本 Spec 为主，子继承之；**冲突以本 Spec 为准**。（规范见 specs-engine `references/subspec.md`）\n\n| ID | 子 Spec | 目标（Intent） | 边界 | 依赖 | 状态 | 路径 |\n|:--:|------|------|------|------|:--:|------|\n' >> "$readme"
    fi
    # 表格式按**表头**判定（老表若为三列则不混表头）
    local sec; sec="$(awk '/^## .*子 Spec/{f=1;next} /^## /{f=0} f' "$readme" || true)"
    local next_id; next_id=$(( $(printf '%s\n' "$sec" | grep -cE '^\| *S[0-9]+ *\|' || true) + 1 ))
    if printf '%s\n' "$sec" | grep -qE '^\| *ID *\| *子 Spec'; then
        printf '| S%s | %s | {待填} | {待填} | — | ⬜ | [`%s`](./%s) |\n' "$next_id" "$name" "$rel" "$rel" >> "$readme"
    else
        printf '| [`%s`](./%s) | %s | ⬜ |\n' "$rel" "$rel" "$name" >> "$readme"
        echo "   ⚠️  父索引为旧三列格式（无 ID 列）——新子已按老格式追加；建议择机升级为七列（subspec.md §10.4）" >&2
    fi

    # 子 00_README 回写父条目 ID
    sed -i.bak -e "s|{父条目 ID}|S${next_id}|" "$dir/00_README.md" && rm -f "$dir/00_README.md.bak"

    echo "✅ 子 Spec 骨架已建: $dir  (深度: $depth)"
    echo "   父指针已写入: $dir/00_README.md → ../../00_README.md（${parent_name}）｜父条目 S${next_id}"
    echo "   父索引已加行: $readme"
    depth_hint "$depth"
    echo "   ① 本骨架不含 laws.md（继承父）/ 不含 execution-log（事件记父的）—— 见 references/subspec.md"
    echo "   ② 补 00_README §2「不在范围内」栏（最常被省，省了会被邻项拖走）"
    echo "   ③ 跑: bash ~/.claude/skills/specs-engine/scripts/validator-check.sh \"$dir\""
}

[ $# -ge 1 ] || usage
CMD="$1"; shift
case "$CMD" in
    new) cmd_new "$@" ;;
    sub) cmd_sub "$@" ;;
    *) usage ;;
esac

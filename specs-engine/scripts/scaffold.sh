***REMOVED***!/bin/bash
***REMOVED*** ============================================================================
***REMOVED*** specs-engine scaffold — 物化 Spec 骨架（模板只 cp 自全局 skill，不产项目快照）
***REMOVED*** 用法: scaffold.sh new <specs父目录> <spec名> [--depth light|standard|heavy]
***REMOVED***       建 {YYYYMMDDHH}-<spec名>/ 骨架；父目录/README.md 索引自动建+加行
***REMOVED***   depth 只约束"AI 必填哪些"（骨架统一落 8 文件）
***REMOVED*** ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$HERE/templates"

usage() { echo "用法: $0 new <specs父目录> <spec名> [--depth light|standard|heavy]" >&2; exit 1; }

main() {
    [ "${1:-}" = "new" ] || usage
    shift
    [ $***REMOVED*** -ge 2 ] || usage

    local parent="${1%/}" name="$2" depth="standard"
    [ "${name***REMOVED***--}" != "$name" ] && { echo "❌ spec 名不能以 -- 开头" >&2; exit 1; }
    if [ "${3:-}" = "--depth" ]; then
        depth="${4:-}"
    fi
    case "$depth" in
        light|standard|heavy) ;;
        *) echo "❌ 未知深度: $depth (light|standard|heavy)" >&2; exit 1 ;;
    esac

    local ts dir
    ts="$(date +%Y%m%d%H)"
    dir="$parent/$ts-$name"

    [ -d "$dir" ] && { echo "❌ 目录已存在: $dir" >&2; exit 1; }

    ***REMOVED*** 骨架：统一 8 文档（validator 检查走全局 scripts/validator-check.sh，不落脚本）
    mkdir -p "$dir"
    local f
    for f in 00_README.md laws.md 01_analysis.md 02_requirements.md 03_design.md 04_tasks.md 05_validator.md execution-log.md; do
        cp "$TPL/$f" "$dir/" 2>/dev/null || echo "⚠️  模板缺失: $f" >&2
    done

    ***REMOVED*** 索引自动建/加行
    local readme="$parent/README.md"
    if [ ! -f "$readme" ]; then
        cat > "$readme" <<'EOF'
***REMOVED*** Specs 索引

> Spec 驱动开发目录。方法论见全局 `specs-engine` skill；每个子目录 = 一个 Spec。

***REMOVED******REMOVED*** 生命周期

| 状态 | 含义 |
|------|------|
| ⬜ 待启动 | 目录已建，分析未开始 |
| 🔵 进行中 | ≥1 阶段文件完成 |
| ✅ 完成 | tasks 全勾 + 代码已提交 + ✅ 三前置 |

***REMOVED******REMOVED*** Spec 列表

| Spec | 简述 | 状态 |
|------|------|:---:|
EOF
    elif ! grep -q '^| Spec |' "$readme"; then
        printf '\n***REMOVED******REMOVED*** Spec 列表\n\n| Spec | 简述 | 状态 |\n|------|------|:---:|\n' >> "$readme"
    fi
    printf '| [%s](./%s/) | %s | ⬜ |\n' "$ts-$name" "$ts-$name" "$name" >> "$readme"

    echo "✅ Spec 骨架已建: $dir  (深度: $depth)"
    case "$depth" in
        light)    echo "   必填: 01_analysis + 05_validator（02/03/04 可删，执行日志并入 00_README 复盘）" ;;
        standard) echo "   必填: 01~05 全五 + execution-log 同步记账" ;;
        heavy)    echo "   必填: 同 standard + 方案对比 + 暂停点 + 人审" ;;
    esac
    echo "   ① 替换占位符 {TICKET}/{YYYY-MM-DD HH:MM}/{author} → 填 00_README 标题"
    echo "   ② 信息不全先澄清，execution-log 记开工首条（澄清状态）"
    echo "   ③ 完成 05_validator 后跑: bash ~/.claude/skills/specs-engine/scripts/validator-check.sh \"$dir\""
}

main "$@"

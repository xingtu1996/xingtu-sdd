#!/bin/bash
# ============================================================================
# validator-check — 静态检查 05_validator.md 的填充完整性（全局单份，不随 spec 复制）
#   - ERROR: 结构章节缺失 / 模板占位符未替换（{简述}/{TICKET}/{YYYY-...} 残留）
#   - WARN : 安全三条件缺失 / 无验证命令用例（纯 SQL/单元场景可忽略）
# 用法: bash validator-check.sh [spec_dir]（默认当前目录）
# ============================================================================
set -euo pipefail

SPEC_DIR="${1:-.}"
VALIDATOR_FILE="$SPEC_DIR/05_validator.md"
ERRORS=0
WARNINGS=0
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo "==== validator-check: $VALIDATOR_FILE ===="

if [ ! -f "$VALIDATOR_FILE" ]; then
    echo -e "${RED}❌ 05_validator.md 不存在${NC}"
    exit 1
fi

check_section() {
    if grep -q "$1" "$VALIDATOR_FILE"; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2 — 缺失${NC}"
        ERRORS=$((ERRORS + 1))
    fi
}

check_section "## 一、数据准备" "数据准备"
check_section "## 二、.*验证" "验证用例"
check_section "## 三、.*一致性" "数据一致性"
check_section "## 五、合规检查" "合规检查"

# 占位符残留 = 真门禁（空模板/未填必被抓住）
PH=$(grep -cE '\{(简述|TICKET|YYYY-[A-Z]|Spec 标题|正常场景|异常场景)\}' "$VALIDATOR_FILE" || true)
echo ""
echo "--- 模板占位符残留 ---"
if [ "$PH" -eq 0 ]; then
    echo -e "${GREEN}✅ 无占位符残留${NC}"
else
    echo -e "${RED}❌ $PH 处模板占位符未替换 — 内容仍是骨架，禁止置 ✅${NC}"
    ERRORS=$((ERRORS + PH))
fi

# 安全三条件（软性）
echo ""
echo "--- 安全三条件（涉及计费/库存/权限/写操作时必填） ---"
grep -qE "(退出条件)" "$VALIDATOR_FILE" && echo -e "${GREEN}✅ 退出条件${NC}" || { echo -e "${YELLOW}⚠️  退出条件缺${NC}"; WARNINGS=$((WARNINGS + 1)); }
grep -qE "(幂等|idempotent)" "$VALIDATOR_FILE" && echo -e "${GREEN}✅ 幂等条件${NC}" || { echo -e "${YELLOW}⚠️  幂等条件缺${NC}"; WARNINGS=$((WARNINGS + 1)); }
grep -qE "(回滚|rollback|恢复)" "$VALIDATOR_FILE" && echo -e "${GREEN}✅ 回滚条件${NC}" || { echo -e "${YELLOW}⚠️  回滚条件缺${NC}"; WARNINGS=$((WARNINGS + 1)); }

# 验证命令用例
CURL=$(grep -c 'curl ' "$VALIDATOR_FILE" || true)
echo ""
echo "--- 用例统计: $CURL 条 curl（纯 SQL/单元场景可忽略） ---"

echo "==== 汇总 ===="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ 全部通过${NC}"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS 警告（可人工判断）${NC}"
else
    echo -e "${RED}❌ $ERRORS 错误 — 未填完/结构缺失${NC}"
fi
exit $ERRORS

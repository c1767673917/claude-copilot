#!/bin/bash

# Codex MCP 集成验证脚本
# 验证 CLAUDE.md, bmad-dev.md, bmad-review.md 的强制执行机制

echo "=================================================="
echo "Codex MCP Integration Verification"
echo "=================================================="
echo ""

PASS=0
FAIL=0

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function check_exists() {
    local file=$1
    local pattern=$2
    local description=$3

    if grep -q "$pattern" "$file"; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $description"
        ((FAIL++))
    fi
}

function count_occurrences() {
    local file=$1
    local pattern=$2
    local min_expected=$3
    local description=$4

    local count=$(grep -c "$pattern" "$file")

    if [ "$count" -ge "$min_expected" ]; then
        echo -e "${GREEN}✓${NC} $description (found $count, expected >=$min_expected)"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $description (found $count, expected >=$min_expected)"
        ((FAIL++))
    fi
}

echo "Checking CLAUDE.md..."
echo "-----------------------------------"

check_exists "CLAUDE.md" "Self-Check Protocol" "自检协议存在"
check_exists "CLAUDE.md" "Violation Detection" "违规检测机制存在"
check_exists "CLAUDE.md" "CHECKPOINT" "检查点机制存在"
check_exists "CLAUDE.md" "EXECUTE Codex MCP Tool Call" "强制执行指令存在"
check_exists "CLAUDE.md" "mcp__codex_cli__ask_codex" "Codex 工具调用存在"
check_exists "CLAUDE.md" "Step 1: Prepare Context" "步骤1: 准备上下文"
check_exists "CLAUDE.md" "Step 6: Backend Revision" "步骤6: 后端修订"
count_occurrences "CLAUDE.md" "MUST\|MANDATORY\|CRITICAL" 10 "强制性语言 (MUST/MANDATORY/CRITICAL)"

echo ""
echo "Checking agents/bmad-dev.md..."
echo "-----------------------------------"

check_exists "agents/bmad-dev.md" "DO NOT write backend code yourself. EVER." "禁止直接编写后端代码"
check_exists "agents/bmad-dev.md" "MANDATORY SELF-CHECK" "强制自检机制"
check_exists "agents/bmad-dev.md" "VIOLATION DETECTION" "违规检测机制"
check_exists "agents/bmad-dev.md" "Step 4.0: Task Classification & Routing" "任务分类和路由"
check_exists "agents/bmad-dev.md" "Step 4.1: Backend Implementation (Via Codex MCP - MANDATORY)" "后端实现强制使用 Codex"
check_exists "agents/bmad-dev.md" "Step 4.3: Bug Fix Implementation (ROUTING MANDATORY)" "Bug 修复强制路由"
check_exists "agents/bmad-dev.md" "Step 4.4: Code Review Tasks (ROUTING MANDATORY)" "代码审查强制路由"
check_exists "agents/bmad-dev.md" "4.1.3: EXECUTE Codex MCP Tool Call" "强制执行 Codex 调用"
count_occurrences "agents/bmad-dev.md" "CHECKPOINT" 8 "检查点数量"
count_occurrences "agents/bmad-dev.md" "ACTION REQUIRED\|MANDATORY ACTION" 6 "强制执行动作"
count_occurrences "agents/bmad-dev.md" "mcp__codex" 4 "Codex 工具引用"

echo ""
echo "Checking agents/bmad-review.md..."
echo "-----------------------------------"

check_exists "agents/bmad-review.md" "DO NOT review backend code manually. EVER." "禁止手动审查后端代码"
check_exists "agents/bmad-review.md" "Step 1: Load Context (MANDATORY - READ ALL FILES)" "强制加载上下文"
check_exists "agents/bmad-review.md" "Step 2: Analyze Code Changes & Classify Review Type" "代码变更分类"
check_exists "agents/bmad-review.md" "Step 3.1: Backend Code Review (Via Codex MCP - MANDATORY)" "后端审查强制使用 Codex"
check_exists "agents/bmad-review.md" "CHECKPOINT: What files were changed" "文件变更检查点"
check_exists "agents/bmad-review.md" "EXECUTE.*mcp__codex_cli__ask_codex" "执行 Codex 调用"
count_occurrences "agents/bmad-review.md" "CHECKPOINT" 3 "检查点数量"
count_occurrences "agents/bmad-review.md" "ACTION REQUIRED" 3 "强制执行动作"

echo ""
echo "Checking cross-file consistency..."
echo "-----------------------------------"

# 检查所有文件都使用相同的工具名称
TOOL_NAME="mcp__codex_cli__ask_codex"
check_exists "CLAUDE.md" "$TOOL_NAME" "CLAUDE.md 使用正确的工具名"
check_exists "agents/bmad-dev.md" "$TOOL_NAME" "bmad-dev.md 使用正确的工具名"
check_exists "agents/bmad-review.md" "$TOOL_NAME" "bmad-review.md 使用正确的工具名"

# 检查所有文件都提到 constraints.yaml
check_exists "CLAUDE.md" "00-constraints.yaml" "CLAUDE.md 引用 constraints.yaml"
check_exists "agents/bmad-dev.md" "00-constraints.yaml" "bmad-dev.md 引用 constraints.yaml"
check_exists "agents/bmad-review.md" "00-constraints.yaml" "bmad-review.md 引用 constraints.yaml"

# 检查所有文件都有输出验证机制
check_exists "CLAUDE.md" "Verify Output" "CLAUDE.md 有输出验证"
check_exists "agents/bmad-dev.md" "Verify Codex Output" "bmad-dev.md 有输出验证"
check_exists "agents/bmad-review.md" "verify.*created" "bmad-review.md 有输出验证"

echo ""
echo "Checking specific backend protection rules..."
echo "-----------------------------------"

# 验证"永远不要"规则
check_exists "agents/bmad-dev.md" "DO NOT write backend code yourself. EVER." "bmad-dev: 禁止写后端代码"
check_exists "agents/bmad-dev.md" "DO NOT fix backend bugs manually. EVER." "bmad-dev: 禁止手动修复后端 bug"
check_exists "agents/bmad-dev.md" "DO NOT review backend code manually. EVER." "bmad-dev: 禁止手动审查后端代码"
check_exists "agents/bmad-review.md" "DO NOT review backend code manually. EVER." "bmad-review: 禁止手动审查后端代码"

# 验证自我纠正机制
check_exists "CLAUDE.md" "VIOLATION DETECTED" "全局规则有违规检测"
check_exists "agents/bmad-dev.md" "VIOLATION DETECTION" "bmad-dev 有违规检测"
check_exists "CLAUDE.md" "STOP.*DELETE.*CALL CODEX" "全局规则有纠正机制"

echo ""
echo "=================================================="
echo "Verification Results"
echo "=================================================="
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Codex integration is properly configured.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please review the integration.${NC}"
    exit 1
fi

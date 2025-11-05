# Codex MCP 强制集成改进总结

**日期**: 2025-11-05
**改进范围**: CLAUDE.md, bmad-dev.md, bmad-review.md

---

## 问题诊断

### 原始问题
尽管在全局规则 (CLAUDE.md) 和工作流文档 (bmad-dev.md, bmad-review.md) 中都明确说明应该使用 Codex 进行后端开发、代码审查和 bug 修复,但 Agent 仍然不调用 Codex MCP 工具。

### 根本原因

1. **示例代码 vs 可执行指令混淆**
   - 原有文档使用 markdown 代码块展示调用示例
   - Agent 将其理解为"文档说明"而非"执行命令"
   - 缺少明确的"现在就执行"语言

2. **缺少强制执行机制**
   - 只有"建议"和"应该",没有"必须"和"检查点"
   - 没有违规检测和自我纠正机制
   - 没有决策树和强制路由逻辑

3. **缺少执行验证**
   - 没有"执行前检查"和"执行后验证"
   - 没有迭代计数器和失败处理
   - 没有明确的输出格式要求

---

## 解决方案实施

### 1. CLAUDE.md - 全局规则强化

#### 添加的关键功能

**A. 自检协议 (Self-Check Protocol)**
```
Q1: Am I about to write backend code?
    → YES: STOP. Go to "Execute Codex Call"
    → NO: Proceed

Q2: Am I fixing a backend bug?
    → YES: STOP. Go to "Execute Codex Call"
    → NO: Proceed

Q3: Am I reviewing backend code?
    → YES: STOP. Go to "Execute Codex Call"
    → NO: Proceed
```

**B. 违规检测和自我纠正**
```
If you catch yourself:
- Writing backend code directly → STOP, DELETE, CALL CODEX
- Modifying backend files → STOP, REVERT, CALL CODEX
- Fixing backend bugs manually → STOP, CALL CODEX

Emergency Stop Phrase:
⚠️ VIOLATION DETECTED: I was about to [action] without calling Codex.
CORRECTIVE ACTION: Stopping immediately and calling mcp__codex_cli__ask_codex.
```

**C. 强制执行流程 (6步流程)**
1. **Step 1**: Prepare Context (READ ALL FILES) - 带检查点
2. **Step 2**: Build Complete Prompt (FILL ALL SECTIONS) - 带模板
3. **Step 3**: EXECUTE Codex MCP Tool Call (DO IT NOW) - 带验证
4. **Step 4**: Verify Output (MANDATORY CHECKS) - 带清单
5. **Step 5**: Review & Decide (DECISION MATRIX) - 带逻辑
6. **Step 6**: Backend Revision (IF NEEDED) - 带迭代限制

**D. 明确的执行语言**
- 从 "You can call Codex" 改为 "YOU MUST NOW use the tool"
- 从 "Consider using" 改为 "EXECUTE NOW"
- 从示例代码改为"DO IT NOW"指令

---

### 2. bmad-dev.md - 开发工作流强制路由

#### 添加的关键功能

**A. 强制自检 (Step 4.0)**
```
CHECKPOINT 1: Task Type Identification
Q: What am I about to do?
  A1: Backend API/Service/Database → GO TO STEP 4.1 (Codex)
  A2: Frontend UI/Component/State → GO TO STEP 4.2 (Self)
  A3: Bug fix → GO TO CHECKPOINT 2
  A4: Code review → GO TO CHECKPOINT 3
```

**B. 违规检测和即时纠正**
```
IF you find yourself writing backend code directly:
  → STOP immediately
  → DELETE any backend code you wrote
  → Output: "⚠️ VIOLATION: Implementing backend without Codex."
  → GO TO STEP 4.1
```

**C. Backend Implementation (Step 4.1) - 完全重写**
- 4.1.1: 强制读取所有上下文文件 (带检查点)
- 4.1.2: 构建完整 Codex 提示词 (带完整模板)
- 4.1.3: **执行 Codex 调用** (强制语言: "YOU MUST NOW")
- 4.1.4: 验证 Codex 输出 (带完整清单)
- 4.1.5: 回答 Codex 问题 + 决策 (带决策矩阵)
- 4.1.6: 后端修订 (带迭代计数器,最多3次)

**D. Bug Fix (Step 4.3) - 添加路由逻辑**
- 4.3.1: Backend Bug Fix (Via Codex - MANDATORY)
- 4.3.2: Frontend Bug Fix (Self-Implement)
- 4.3.3: Integration Bug Analysis & Routing

**E. Code Review (Step 4.4) - 添加路由逻辑**
- 4.4.1: Backend Code Review (Via Codex - MANDATORY)
- 4.4.2: Frontend Code Review (Self-Review)

**关键改进**:
- 33 处使用强制性语言 (MANDATORY, CHECKPOINT, VIOLATION, ACTION REQUIRED)
- 4 处明确禁止 ("DO NOT ... EVER")
- 每个步骤都有执行验证

---

### 3. bmad-review.md - 代码审查工作流完全重写

#### 原有问题
- 只有 48 行,完全没有提到 Codex
- 没有后端/前端代码区分
- 没有强制执行机制

#### 重写后 (450+ 行)

**A. 结构化流程 (5步)**
1. **Step 1**: Load Context (MANDATORY - READ ALL FILES)
2. **Step 2**: Analyze Code Changes & Classify Review Type
3. **Step 3.1**: Backend Code Review (Via Codex MCP - MANDATORY)
3. **Step 3.2**: Frontend Code Review (Self-Review)
4. **Step 4**: Generate Final Review Report (MERGE IF BOTH)
5. **Step 5**: Update Sprint Plan Status

**B. 代码分类逻辑**
```
CHECKPOINT: What files were changed?

A1: ONLY backend → GO TO STEP 3.1 (Codex)
A2: ONLY frontend → GO TO STEP 3.2 (Self)
A3: BOTH → Execute 3.1 + 3.2, merge in Step 4
A4: NO code (docs) → Skip to Step 4
```

**C. 详细的 Codex 审查提示词**
包含 8 个审查标准:
1. Requirements Compliance
2. Architecture Compliance
3. Technology Stack Compliance
4. Security Analysis
5. Performance Analysis
6. API Contract Compliance
7. Code Quality
8. Testing Coverage

**D. 结构化输出要求**
- `04-backend-review.md` (详细后端审查报告)
- `04-frontend-review.md` (前端审查报告)
- `04-dev-reviewed.md` (最终合并报告)

---

## 改进效果对比

### 改进前

| 方面 | 原状态 | 问题 |
|------|--------|------|
| **执行语言** | "You can use Codex" | 被理解为建议,非强制 |
| **示例代码** | Markdown 代码块 | 被视为文档,非指令 |
| **检查点** | 无 | Agent 不知道何时验证 |
| **违规检测** | 无 | Agent 可能直接写后端代码 |
| **输出验证** | 无 | 无法确认 Codex 被调用 |
| **迭代机制** | 无 | 失败后不知道如何处理 |

### 改进后

| 方面 | 新状态 | 效果 |
|------|--------|------|
| **执行语言** | "YOU MUST NOW use tool" | 明确强制执行 |
| **执行指令** | "DO IT NOW" + 参数 | 可直接执行的工具调用 |
| **检查点** | 每步都有 CHECKPOINT | Agent 自我验证 |
| **违规检测** | 自动检测 + 纠正机制 | 防止直接写后端代码 |
| **输出验证** | 强制验证清单 | 确认 Codex 正确执行 |
| **迭代机制** | 3次迭代 + 升级机制 | 处理失败情况 |

---

## 关键设计原则

### 1. 防御性编程
- 假设 Agent 可能"忘记"调用 Codex
- 在每个可能的违规点添加检测
- 提供自我纠正机制

### 2. 强制执行语言
- **禁止**: "You can", "Consider", "Optionally"
- **使用**: "YOU MUST", "MANDATORY", "EXECUTE NOW"
- **检查点**: "Have you done X? If NO, go back"

### 3. 决策树和路由逻辑
- 每个决策点都是明确的 if-then 逻辑
- 使用 Q&A 格式强制思考
- 明确每个路径的目标步骤

### 4. 可验证性
- 每个执行步骤都有输出要求
- 每个输出都有验证清单
- 失败有明确的处理路径

### 5. 迭代和升级机制
- 最多 3 次迭代
- 第 3 次失败 → 升级给用户
- 记录每次迭代的改进

---

## 统计数据

### CLAUDE.md
- 新增行数: ~260 行
- 检查点数量: 6 个
- 强制性语言: 15+ 处

### bmad-dev.md
- 修改行数: ~400 行
- 检查点数量: 12 个
- 强制性语言: 33 处
- "DO NOT ... EVER": 3 处

### bmad-review.md
- 重写行数: 450+ 行 (原 48 行)
- 检查点数量: 5 个
- 新增 Codex 集成: 完整审查流程

---

## 预期效果

### 短期效果 (立即)
1. ✅ Agent 在遇到后端任务时会自动停止并调用 Codex
2. ✅ Agent 会明确输出"正在调用 Codex"
3. ✅ Agent 会验证 Codex 输出文件是否存在
4. ✅ Agent 会回答 Codex 提出的问题

### 中期效果 (1-2周)
1. ✅ 后端代码质量提升 (由 Codex 专业生成)
2. ✅ 技术栈合规性提升 (Codex 强制遵守 constraints)
3. ✅ 测试覆盖率提升 (Codex 自动生成测试)
4. ✅ 安全性提升 (Codex 专业安全审查)

### 长期效果 (1个月+)
1. ✅ 形成标准化开发流程
2. ✅ 减少人工审查工作量
3. ✅ 积累 Codex 使用最佳实践
4. ✅ 提升整体代码库质量

---

## 验证方法

### 测试场景 1: 后端开发任务
```
给 bmad-dev 一个后端任务:
"实现用户认证 API (注册、登录、登出)"

预期行为:
1. 读取所有上下文文件 ✓
2. 执行自检: "这是后端任务" ✓
3. 输出: "正在调用 Codex MCP" ✓
4. 调用 mcp__codex_cli__ask_codex ✓
5. 验证输出文件存在 ✓
6. 回答 Codex 问题 ✓
```

### 测试场景 2: 后端 Bug 修复
```
给 bmad-dev 一个后端 bug:
"登录 API 在邮箱无效时返回 500"

预期行为:
1. 分析 bug 位置 ✓
2. 识别为后端 bug ✓
3. 输出: "后端 bug,调用 Codex" ✓
4. 调用 Codex 进行修复 ✓
5. 验证修复和测试 ✓
```

### 测试场景 3: 代码审查
```
给 bmad-review 后端代码审查任务

预期行为:
1. 读取所有上下文 ✓
2. 识别后端文件 ✓
3. 输出: "后端审查,调用 Codex" ✓
4. 调用 Codex 进行审查 ✓
5. 生成审查报告 ✓
```

---

## 后续优化建议

### 1. 添加监控和日志
- 记录每次 Codex 调用
- 统计成功率和失败原因
- 分析常见问题模式

### 2. 优化提示词模板
- 根据实际使用反馈改进
- 添加更多示例
- 优化输出格式

### 3. 扩展到其他场景
- 数据库迁移
- 性能优化
- 重构任务

### 4. 建立最佳实践库
- 成功案例收集
- 常见问题 FAQ
- 提示词模板库

---

## 总结

通过系统性的改进,我们:

1. **从"建议"到"强制"**: 将所有后端相关工作强制路由到 Codex
2. **从"示例"到"指令"**: 将文档示例转换为可执行指令
3. **从"被动"到"主动"**: 添加自检、违规检测、自我纠正机制
4. **从"模糊"到"精确"**: 每个步骤都有明确的检查点和验证

**核心原则**:
> "永远不要假设 Agent 会自动做正确的事,要通过系统设计确保它必须做正确的事。"

---

**修改文件**:
- ✅ CLAUDE.md (全局规则)
- ✅ agents/bmad-dev.md (开发工作流)
- ✅ agents/bmad-review.md (代码审查工作流)

**影响范围**:
- 后端开发
- 后端 bug 修复
- 后端代码审查
- 全栈项目集成

**兼容性**:
- 前端开发不受影响 (继续自行实现)
- 架构设计不受影响 (bmad-architect 独立)
- QA 测试不受影响 (bmad-qa 独立)

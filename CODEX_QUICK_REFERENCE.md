# Codex MCP 快速参考指南

**适用于**: bmad-dev, bmad-review 及所有后端工作
**更新日期**: 2025-11-05

---

## 🚨 核心规则 (绝对禁止违反)

### 1. 永远不要直接编写后端代码
```
❌ 禁止: 直接写后端 API、Service、Database 代码
✅ 必须: 调用 Codex MCP 工具生成
```

### 2. 永远不要手动修复后端 Bug
```
❌ 禁止: 直接修改后端代码修复 bug
✅ 必须: 调用 Codex MCP 分析并修复
```

### 3. 永远不要手动审查后端代码
```
❌ 禁止: 人工审查后端代码
✅ 必须: 调用 Codex MCP 进行专业审查
```

---

## 🔍 自检清单 (每次执行前必问)

### Q1: 我正在做什么任务?
```
□ 后端 API 开发?           → 调用 Codex (Step 4.1)
□ 后端业务逻辑?            → 调用 Codex (Step 4.1)
□ 数据库操作?              → 调用 Codex (Step 4.1)
□ 后端 Bug 修复?          → 调用 Codex (Step 4.3.1)
□ 后端代码审查?           → 调用 Codex (Step 4.4.1)
□ 前端开发?               → 自行实现 (Step 4.2)
```

### Q2: 我是否准备好调用 Codex?
```
□ 已读取 00-constraints.yaml?
□ 已读取 01-product-requirements.md?
□ 已读取 02-system-architecture.md?
□ 已读取 03-sprint-plan.md?
□ 已准备完整提示词?
```

### Q3: 调用 Codex 后如何验证?
```
□ implementation.md 文件是否创建?
□ codex-output.json 文件是否创建?
□ 后端代码是否已提交到仓库?
□ 测试是否已编写并通过?
□ 是否回答了所有 Codex 问题?
```

---

## 📋 标准调用流程 (6步强制)

### Step 1: 准备上下文
**必读文件** (按顺序):
1. `.claude/specs/{feature}/00-constraints.yaml` (技术栈)
2. `.claude/specs/{feature}/01-product-requirements.md` (需求)
3. `.claude/specs/{feature}/02-system-architecture.md` (架构)
4. `.claude/specs/{feature}/03-sprint-plan.md` (任务)
5. `.claude/specs/{feature}/04-frontend/api-client.md` (API 契约,如存在)
6. `.claude/specs/{feature}/00-repo-scan.md` (仓库上下文,如存在)

**检查点**: 所有必读文件已加载? ✅

---

### Step 2: 构建提示词
**模板结构**:
```markdown
# BACKEND [IMPLEMENTATION|BUG_FIX|CODE_REVIEW]

## TECHNOLOGY CONSTRAINTS (MUST FOLLOW)
[粘贴完整 constraints.yaml 内容]

## PRODUCT REQUIREMENTS
[粘贴相关需求]

## SYSTEM ARCHITECTURE
[粘贴相关架构]

## SPRINT PLAN - BACKEND TASKS ONLY
[仅提取后端任务]

## FRONTEND API CONTRACT (如存在)
[粘贴 api-client.md]

## CODE CONTEXT (@文件引用)
- @路径/文件A (必要的现有代码片段，若裁剪请备注)
- @路径/文件B (配置/迁移等)
- [说明：如未包含整个文件，注明省略范围]

## YOUR SPECIFIC TASK
[清晰、具体的后端任务描述]

## OUTPUT REQUIREMENTS
- Repo code updated directly (no markdown / no apply_patch)
- implementation.md (must include Change Summary with git status, git diff --stat, per-file notes)
- codex-output.json (must include change_summary: git status, git diff --stat, per-file summaries)
```

**检查点**: 所有章节已填充? ✅

---

### Step 3: 执行 Codex 调用
**工具**: `mcp__codex_cli__ask_codex`

**参数**:
```javascript
{
  model: "gpt-5-codex",
  sandbox: false,
  fullAuto: true,
  yolo: false,
  search: true,
  prompt: "[Step 2 的完整提示词]"
}
```

**检查点**: 工具已调用,正在等待响应? ✅

---

### Step 4: 验证输出
**文件检查**:
```bash
□ .claude/specs/{feature}/04-backend/implementation.md 存在?
□ .claude/specs/{feature}/04-backend/codex-output.json 存在?
□ 后端代码文件存在于仓库?
□ 测试文件存在?
```

**内容检查**:
```bash
□ codex-output.json 状态不是 "failed"?
□ tests_passing 数量 > 0?
□ change_summary 中包含 git status / git diff --stat?
□ change_summary.files[] 与仓库实际改动一致?
□ implementation.md Change Summary 填写完整?
□ 每个 @文件都在 change_summary 中体现或在 implementation.md 说明无需改动?
□ 技术栈约束已遵守?
```

**质量检查**:
```bash
□ 运行测试 → 全部通过?
□ 测试覆盖率 > 80%?
□ 技术决策与 Change Summary 一致?
□ questions[] 数组已检查?
```

**检查点**: 所有检查通过? ✅ 继续 | ❌ 进入 Step 5

---

### Step 5: 回答问题 & 决策
**先检查**: 确认 codex-output.json 与 implementation.md 的 Change Summary 覆盖所有 @文件，记录任何可疑或缺失的改动。

**读取**: `codex-output.json` → `questions` 数组

**每个问题**:
1. 理解: 问题 + 上下文 + 建议
2. 决策: 批准 | 修改 | 拒绝
3. 文档化: 写入 `review-answers.md`

**决策矩阵**:
```
questions = 0 && tests passing && coverage >80%
  ✅ → 标记完成,进入下一个任务

questions > 0 || tests failing || coverage <80%
  迭代 < 3 → 🔄 准备修订 (Step 6)
  迭代 = 3 → ⚠️ 升级给用户

任何检查失败 (Step 4)
  → 🔄 准备修订 (Step 6)
```

---

### Step 6: 后端修订 (如需要)
**迭代追踪**: 当前 [1|2|3] / 最大 3

**修订提示词**:
```markdown
# BACKEND REVISION - Iteration [N/3]

## ORIGINAL CONTEXT
[粘贴 Step 2 的完整提示词]

## REVIEW FEEDBACK
[粘贴 review-answers.md]

## SPECIFIC CHANGES REQUIRED
1. [具体修改项 1]
2. [具体修改项 2]

## REVISION LOG REQUIREMENTS
[要求 Codex 记录修订日志]
```

**执行**: 再次调用 `mcp__codex_cli__ask_codex`

**之后**: 返回 Step 4 验证

**限制**: 如果第 3 次迭代仍失败 → **停止并升级给用户**

---

## ⚠️ 违规检测 & 自我纠正

### 违规场景 1: 正在编写后端代码
**症状**: 你发现自己在写 API、Service、Model 代码

**立即行动**:
1. **停止** 所有编码工作
2. **删除** 刚写的后端代码
3. **输出**: "⚠️ 违规检测: 正在编写后端代码,应该调用 Codex。立即纠正。"
4. **执行**: 转到 Step 1 (准备上下文)

---

### 违规场景 2: 正在修复后端 Bug
**症状**: 你发现自己在修改后端文件修复 bug

**立即行动**:
1. **停止** 所有修改
2. **回退** 所有更改
3. **输出**: "⚠️ 违规检测: 正在手动修复后端 bug,应该调用 Codex。立即纠正。"
4. **执行**: 转到 Step 1 (准备 Bug 修复上下文)

---

### 违规场景 3: 正在审查后端代码
**症状**: 你发现自己在人工审查后端代码

**立即行动**:
1. **停止** 审查工作
2. **输出**: "⚠️ 违规检测: 正在手动审查后端代码,应该调用 Codex。立即纠正。"
3. **执行**: 转到 Step 1 (准备代码审查上下文)

---

## 🎯 特定场景速查

### 场景 1: 实现用户认证 API
```
任务类型: 后端 API 实现
路由到: Step 4.1 (Backend Implementation)
Codex 提示词重点:
- TECHNOLOGY CONSTRAINTS: [粘贴 constraints.yaml]
- YOUR TASK: "实现用户认证 API: 注册、登录、登出端点"
- API CONTRACT: [粘贴 api-client.md 中的认证部分]
预期输出:
- src/controllers/auth.controller.ts
- src/services/auth.service.ts
- src/models/user.model.ts
- tests/auth.test.ts
- implementation.md
- codex-output.json
```

---

### 场景 2: 修复登录 500 错误
```
任务类型: 后端 Bug 修复
路由到: Step 4.3.1 (Backend Bug Fix)
Codex 提示词重点:
- BUG DESCRIPTION: "登录 API 在邮箱无效时返回 500"
- REPRODUCTION STEPS: [详细步骤]
- ERROR LOGS: [粘贴完整错误日志]
预期输出:
- 修复后的代码
- 回归测试
- implementation.md (包含根因分析)
- codex-output.json
```

---

### 场景 3: 审查支付 API 代码
```
任务类型: 后端代码审查
路由到: Step 4.4.1 (Backend Code Review)
Codex 提示词重点:
- FILES TO REVIEW: [列出所有支付相关后端文件]
- REVIEW CRITERIA: 安全性(重点)、性能、合规性
- CONTEXT: [粘贴支付相关需求和架构]
预期输出:
- 04-backend-review.md
  - 安全分析(支付敏感)
  - 性能分析
  - 合规性检查
  - 问题分类(Critical/Major/Minor)
  - 修复建议
```

---

## 📊 输出文件清单

### 后端实现 (Step 4.1)
```
.claude/specs/{feature}/04-backend/
├── implementation.md        (实现日志)
├── codex-output.json       (Codex 输出)
└── review-answers.md       (你的回答,如有问题)

src/backend/                 (实际代码)
├── controllers/
├── services/
├── models/
└── middleware/

tests/                       (测试代码)
└── backend/
```

### 后端审查 (Step 4.4.1)
```
.claude/specs/{feature}/
├── 04-backend-review.md     (后端审查报告)
├── 04-frontend-review.md    (前端审查报告,如适用)
└── 04-dev-reviewed.md       (最终合并报告)
```

---

## 🔧 常见问题

### Q: 什么时候可以自己写代码?
**A**: 只有在前端开发时 (UI 组件、State 管理、CSS 等)

### Q: 如果 Codex 失败了怎么办?
**A**:
1. 第 1-2 次失败: 分析 questions,准备修订,再次调用
2. 第 3 次失败: 停止,升级给用户,不要继续尝试

### Q: 如何判断是后端还是前端任务?
**A**:
- 后端: API、Service、Database、Middleware、Server-side 逻辑
- 前端: Component、Page、Hook、Store、CSS、Client-side 逻辑
- 不确定: 检查文件路径 (src/backend vs src/frontend)

### Q: 可以同时做前后端吗?
**A**: 不可以。必须分开:
1. 先做前端 → 生成 api-client.md
2. 再做后端 → 基于 api-client.md 调用 Codex

### Q: constraints.yaml 不存在怎么办?
**A**: 停止工作,报告错误:
```
"无法继续 - constraints.yaml 文件缺失。
请先运行 bmad-architect 创建项目结构。"
```

---

## 📈 成功指标

### 调用成功的标志
```
✅ 所有上下文文件已读取
✅ Codex 工具已调用(不是"计划调用")
✅ implementation.md 已创建
✅ codex-output.json 已创建
✅ 后端代码已在仓库中
✅ 测试已编写且通过
✅ 已回答所有 Codex 问题
✅ 技术栈约束 100% 遵守
```

### 调用失败的标志
```
❌ "我将实现这个 API..." (直接实现)
❌ 没有调用 mcp__codex_cli__ask_codex
❌ 没有 implementation.md 文件
❌ 没有 codex-output.json 文件
❌ Codex 有问题但没有回答
❌ 技术栈约束被违反
```

---

## 🚀 快速开始模板

**复制此模板开始后端工作**:

```markdown
# 后端任务: [任务名称]

## Step 1: 上下文准备 ✓
- [ ] 读取 00-constraints.yaml
- [ ] 读取 01-product-requirements.md
- [ ] 读取 02-system-architecture.md
- [ ] 读取 03-sprint-plan.md
- [ ] 读取 04-frontend/api-client.md (如存在)

## Step 2: 提示词构建 ✓
[在此处构建完整提示词]

## Step 3: 执行 Codex 调用 ✓
工具: mcp__codex_cli__ask_codex
状态: [等待中|已完成|失败]

## Step 4: 输出验证 ✓
- [ ] implementation.md 存在
- [ ] codex-output.json 存在
- [ ] 后端代码已提交
- [ ] 测试已通过

## Step 5: 问题回答 ✓
Questions: [数量]
Answers: [已回答|待回答]

## Step 6: 修订 (如需要)
迭代: [0|1|2|3] / 3
状态: [不需要|进行中|已完成|升级]
```

---

**记住核心原则**:
> "永远不要假设自己能写好后端代码。Codex 是专业工具,必须使用。"

**紧急情况联系**:
如果连续 3 次 Codex 调用失败,停止工作并升级给用户,说明:
- 尝试了什么
- 为什么失败
- 需要什么帮助

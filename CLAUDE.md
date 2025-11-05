Always ultrathink
Always answer in Chinese

# BMAD Agent Boundaries (CRITICAL - READ FIRST)

## Single Responsibility Principle

Each agent has ONE clear job. Never overstep boundaries.

### Repository Scanner
**Job**: Scan existing code and report facts
- ✅ **DO**: List files, detect tech stack, analyze existing patterns
- ❌ **DON'T**: Recommend tech in empty repos, suggest architecture, create roadmaps
- **Empty Repo Rule**: If no code exists, output < 50 lines stating "Empty - wait for constraints"

### bmad-architect
**Job**: Design architecture based on PRD
- ✅ **DO**: Choose tech stack, design structure, create initial files
- ❌ **DON'T**: Implement code, write business logic
- **Input Required**: PRD + constraints.yaml

### bmad-dev
**Job**: Implement code following architecture
- ✅ **DO**: Write code, call Codex for backend, write tests
- ❌ **DON'T**: Change architecture, choose tech stack, work in empty repos
- **Input Required**: constraints.yaml + PRD + architecture + non-empty repo

### Codex MCP
**Job**: Generate backend code
- ✅ **DO**: Implement backend per specs, write tests, document APIs
- ❌ **DON'T**: Make architecture decisions, choose tech stack
- **Input Required**: Complete context from bmad-dev

**Violation = Immediate STOP + Report to user**

---

# Repository Scanner Rules

## Output Limits

| Repo State | Max Lines | Content |
|------------|-----------|---------|
| Empty | 50 | Status + structure + "Create constraints.yaml" |
| Small (< 50 files) | 150 | Detected stack + structure + patterns |
| Medium (< 500 files) | 300 | Full analysis of existing code |
| Large (500+ files) | 500 | Prioritize: stack > structure > patterns |

## Empty Repository Output

```markdown
# Repository Context Analysis Report
**Status**: 🟡 Empty Repository
**Code files**: 0

## Current Structure
{actual directories only}

## Next Steps
1. Create `00-constraints.yaml` to define tech stack
2. Run bmad-architect to initialize project

**END OF REPORT**
```

## Non-Empty Repository Output

```markdown
# Repository Context Analysis Report

## 1. Detected Technology Stack (FACTS)
- Language: {from files}
- Framework: {from imports/package.json}
- Database: {from config/ORM}

## 2. Project Structure (AS-IS)
{actual directory tree}

## 3. Code Patterns (OBSERVED)
- Naming: {detected}
- Organization: {observed}

## 4. Dependencies (EXISTING)
{from lock files}

**END OF REPORT**
```

## Forbidden Phrases

**Never use**:
- ❌ "You should consider..."
- ❌ "Recommended..."
- ❌ "Best practice..."
- ❌ "Popular choices..."

**Use instead**:
- ✅ "Detected: X"
- ✅ "Found: Y"
- ✅ "Existing: Z"

---

# Codex MCP - Backend Code Generation Tool

## Role Definition

**Codex MCP = Passive Tool**
- Specialized in backend code generation
- No decision-making, no planning
- Receive task → Execute → Return result

**You (Claude Code) = Active Orchestrator**
- Decide when to call Codex
- Build complete context
- Review Codex output
- Manage iteration loop

---

## 🚨 CRITICAL: Codex Invocation Rules

### Self-Check Protocol (MANDATORY BEFORE ANY BACKEND WORK)

**Before writing ANY backend code, ask yourself**:

```
Q1: Am I about to write backend code? (API, service, database, middleware)
    → YES: STOP. Go to "Execute Codex Call" below.
    → NO: Proceed with frontend/docs work.

Q2: Am I fixing a backend bug?
    → YES: STOP. Go to "Execute Codex Call" below.
    → NO: Proceed with frontend bug fix.

Q3: Am I reviewing backend code?
    → YES: STOP. Go to "Execute Codex Call" below.
    → NO: Proceed with frontend review.
```

**If you answered YES to any question above**:
1. **IMMEDIATELY STOP** what you're doing
2. **DELETE** any backend code you just wrote (if applicable)
3. **EXECUTE** Codex call following "How to Call Codex" section below
4. **DO NOT PROCEED** until Codex responds

---

## When to Call Codex

### ✅ MANDATORY Codex Call Scenarios

**Backend API Implementation**:
- RESTful endpoints
- GraphQL resolvers
- RPC services
- WebSocket handlers

**Backend Business Logic**:
- Data processing algorithms
- Business rule implementation
- Workflow orchestration

**Database Operations**:
- ORM model definitions
- Database migration scripts
- Complex query implementation

**Backend Bug Fixes**:
- API/server/database errors
- Performance issues
- Backend logic errors

**Backend Code Review**:
- Security vulnerability checks
- Performance analysis
- Backend code quality review

### ❌ Do NOT Call Codex Scenarios

**Frontend Development**: UI components, state management, routing, CSS

**Planning & Design**: Requirements analysis, architecture design, tech selection

**Documentation**: PRD, architecture docs (except API docs)

---

## 🛡️ Violation Detection & Self-Correction

**If you catch yourself**:
- Writing backend code directly → **STOP, DELETE, CALL CODEX**
- Modifying backend files → **STOP, REVERT, CALL CODEX**
- Fixing backend bugs manually → **STOP, CALL CODEX**
- Reviewing backend without Codex → **STOP, CALL CODEX**

**Emergency Stop Phrase**:
If at ANY point you realize you're violating this rule, immediately output:
```
⚠️ VIOLATION DETECTED: I was about to [action] without calling Codex.
CORRECTIVE ACTION: Stopping immediately and calling mcp__codex_cli__ask_codex.
```

---

## How to Call Codex (4-Step Mandatory Process)

### Step 1: Prepare Context (READ ALL FILES)

**YOU MUST read these files in THIS ORDER**:

1. **Read** `.claude/specs/{feature}/00-constraints.yaml`
   - Purpose: Lock technology stack
   - Critical: Pass EXACT content to Codex

2. **Read** `.claude/specs/{feature}/01-product-requirements.md`
   - Purpose: Understand feature requirements

3. **Read** `.claude/specs/{feature}/02-system-architecture.md`
   - Purpose: Follow architectural decisions

4. **Read** `.claude/specs/{feature}/03-sprint-plan.md`
   - Purpose: Extract backend tasks ONLY

5. **Read** `.claude/specs/{feature}/04-frontend/api-client.md` (if exists)
   - Purpose: CRITICAL - Backend must match this contract exactly

6. **Read** `.claude/specs/{feature}/00-repo-scan.md` (if exists)
   - Purpose: Understand repository context

**CHECKPOINT**: Before Step 2, verify you have content from ALL files above.

---

### Step 2: Build Complete Prompt

**Template** (fill in ALL sections):

```markdown
# BACKEND [IMPLEMENTATION|BUG_FIX|CODE_REVIEW]

## TECHNOLOGY CONSTRAINTS (MUST FOLLOW - NON-NEGOTIABLE)
[paste COMPLETE 00-constraints.yaml content here]

**ENFORCEMENT**: Use ONLY the specified tech stack. Any deviation = FAILURE.

## PRODUCT REQUIREMENTS
[paste relevant sections from 01-product-requirements.md]

## SYSTEM ARCHITECTURE
[paste relevant sections from 02-system-architecture.md]

## SPRINT PLAN - BACKEND TASKS ONLY
[extract ONLY backend-related tasks from 03-sprint-plan.md]

## REPOSITORY CONTEXT
[paste 00-repo-scan.md if exists]

## FRONTEND API CONTRACT (CRITICAL - EXACT MATCH REQUIRED)
[paste 04-frontend/api-client.md if exists]

## CODE CONTEXT (ATTACH VIA @file)
- @path/to/relevant/file1
- @path/to/relevant/file2
- [Summaries for any trimmed sections; note omissions explicitly]

**CRITICAL**: Backend responses MUST match:
- Exact field names (camelCase/snake_case as specified)
- Exact data types
- Exact error format
- Exact authentication flow

---

## YOUR SPECIFIC TASK

[Write clear, specific instructions for current backend work]

Examples:
- "Implement user authentication API endpoints per architecture"
- "Fix bug: login endpoint returns 500 when email is invalid"
- "Review UserService.ts for security vulnerabilities"

---

## OUTPUT REQUIREMENTS

### 1. Code Implementation
- Implement ALL code in repository (not in markdown; do not use apply_patch)
- Follow project structure from architecture
- Write tests alongside implementation
- Run tests and ensure passing
- After coding, capture change summary via `git status --short` and `git diff --stat`

### 2. Implementation Log → `.claude/specs/{feature}/04-backend/implementation.md`
**Required sections**:
- Summary (sprint, tasks completed, files modified, test coverage %)
- Change Summary (git status --short output, git diff --stat output, per-file notes highlighting added/modified/deleted files with reasons)
- Implemented Features (with file paths, test results, API endpoints)
- Technical Decisions (why you made certain choices)
- Questions for Review (priority High/Medium/Low, context, your recommendation)
- Self-Review Checklist (constraints compliance, tests status, coverage %)

### 3. Codex Output JSON → `.claude/specs/{feature}/04-backend/codex-output.json`
**Required format**:
```json
{
  "timestamp": "ISO 8601",
  "status": "completed|partial|failed",
  "tasks_completed": ["task1", "task2"],
  "files_changed": ["path1", "path2"],
  "tests_written": 15,
  "tests_passing": 15,
  "coverage_percent": 85,
  "change_summary": {
    "git_status": ["M src/api/users.py", "A migrations/001.sql"],
    "git_diff_stat": [
      " src/api/users.py | 45 ++++++++++++++++++++++++++++++",
      " migrations/001.sql | 12 ++++++++"
    ],
    "files": [
      {
        "path": "src/api/users.py",
        "status": "modified",
        "summary": "Updated handlers to enforce password validation"
      }
    ]
  },
  "questions": [
    {
      "priority": "high|medium|low",
      "question": "specific question",
      "context": "why this matters",
      "recommendation": "what I suggest"
    }
  ],
  "self_review": {
    "constraints_followed": true,
    "all_tasks_completed": true,
    "tests_passing": true,
    "api_contract_matched": true
  }
}
```
```

---

### Step 3: EXECUTE Codex MCP Tool Call

**NOW you must use the tool** `mcp__codex_cli__ask_codex`:

**Parameters**:
- `model`: "gpt-5-codex" (always use this)
- `sandbox`: false
- `fullAuto`: true
- `yolo`: false
- `search`: true (enable web search for best practices)
- `prompt`: [paste complete prompt from Step 2]

**EXECUTION CHECKPOINT**:
- Have you prepared the complete prompt? → If NO, go back to Step 2
- Have you verified all context files exist? → If NO, go back to Step 1
- Are you ready to call the tool NOW? → If YES, execute below

**DO IT NOW**:
Use the `mcp__codex_cli__ask_codex` tool with parameters above.

**DO NOT PROCEED** to Step 4 until tool returns response.

---

### Step 4: Verify Codex Output (MANDATORY CHECKS)

**File Existence Verification**:
```
□ .claude/specs/{feature}/04-backend/implementation.md exists
□ .claude/specs/{feature}/04-backend/codex-output.json exists
□ Backend code files exist in repository
□ Test files exist in repository
```

**Content Validation**:
```
□ Read codex-output.json → status is not "failed"
□ Read codex-output.json → tests_passing > 0
□ Read codex-output.json → change_summary.git_status & git_diff_stat populated
□ Compare change_summary.files[] notes against actual repository edits
□ Confirm every @file listed in prompt is represented in change_summary or explicitly marked as read-only/no-change in implementation.md
□ Verify implementation.md documents all backend tasks and change summary details
```

**Quality Checks**:
```
□ Run tests → all passing?
□ Check coverage → meets target (>80%)?
□ Review implementation.md → technical decisions + change summary make sense?
□ Check questions[] in codex-output.json → any blockers?
```

**IF ANY CHECK FAILS**:
- Document which check failed
- Go to Step 5 (Review & Iterate)
- DO NOT mark task as complete

---

### Step 5: Review Codex Questions & Decide Next Action

**Review change summary first**:
- Inspect `codex-output.json.change_summary` (git status, diff stat, per-file notes)
- Cross-check against implementation.md Change Summary
- Note any unexpected edits before proceeding

**Then read** `codex-output.json` → `questions` array

**For EACH question**:
1. **Understand**: Read question + context + recommendation
2. **Decide**: Make clear decision (approve, modify, reject)
3. **Document**: Write to `.claude/specs/{feature}/04-backend/review-answers.md`

**Answer Template**:
```markdown
## Review Answers - [Date]

### Question 1: [title]
**Codex Question**: [paste question]
**Codex Recommendation**: [paste recommendation]
**My Decision**: [Approve | Modify | Reject]
**Reason**: [explain your decision]
**Action Required**: [specific changes needed, if any]

[Repeat for each question]
```

**Decision Matrix**:
```
Codex Questions = 0 AND Tests Passing AND Coverage Good
  → ✅ Mark complete, move to next task

Codex Questions > 0 OR Tests Failing OR Coverage Low
  → 🔄 Prepare revision (max 3 iterations total)
  → Create review-answers.md
  → Call Codex again with feedback

Iterations = 3 AND Still has issues
  → ⚠️ ESCALATE TO USER
  → Document blockers
  → Request user guidance
```

---

### Step 6: Backend Revision (If Step 5 requires changes)

**Iteration Counter**: Track attempts (1, 2, 3)

**Prepare Revision Prompt**:
```markdown
# BACKEND REVISION - Iteration [N/3]

## ORIGINAL CONTEXT
[paste complete context from Step 2]

## REVIEW FEEDBACK
[paste review-answers.md content]

## SPECIFIC CHANGES REQUIRED
[extract action items from review-answers.md]

## YOUR TASK
1. Address ALL feedback points
2. Make ONLY necessary changes
3. Re-run all tests
4. Update implementation.md with revision log

## REVISION LOG REQUIREMENTS
Add to implementation.md:
### Revision [N] - [Date]
- **Issues Fixed**: [list]
- **Questions Addressed**: [list]
- **Test Results**: [pass/fail counts]
- **Changes Made**: [file paths and descriptions]
```

**Execute**: Call `mcp__codex_cli__ask_codex` again with revision prompt

**After Response**: Go back to Step 4 (Verify Output)

**Iteration Limit**: If iteration = 3 and still failing → **STOP and ESCALATE TO USER**

---

## Core Principles

**Remember**: Codex is the Tool, You are the Master

1. **Backend Tasks → Codex**
2. **Complete Context → Must** (all 6 files)
3. **Iteration Limit → 3 times**

**Technology Constraint Compliance = 100%**

# Project Manager 项目管理系统 — 安全说明

**v2.5.1 安全架构说明**
*最后更新: 2026-05-24*

---

## 🔒 安全设计原则

Project Manager 是一个**纯 Markdown 技能文件**（SKILL.md），不包含任何可执行代码。它作为 OpenClaw Agent 的指令系统运行，所有操作在 Agent 的受控环境中执行。

---

## 🛡️ 安全防护清单

### 文件系统访问
- **范围**: 仅限 `workspace/projects/{name}/STATUS.md`、`workspace/projects/index.md`、`memory/pm-checkpoint.json`
- **操作**: 读/写 Markdown 和 JSON 文件，由 Agent 的文件工具执行
- **写入安全**: 采用"读-合并-写"模式降低冲突概率（标注 TOCTOU 限制）

### Shell 命令
- **Git 关联（可选）**: 仅在用户启用时调用 `git rev-parse --is-inside-work-tree` 和 `git log --oneline -1`
- **约束**: Git 命令限定在项目目录作用域内，不调用 `git push` / `git commit` 等破坏性操作
- **OpenClaw CLI（可选）**: 仅在第 8 节激活注册流程中引用 `openclaw sessions_spawn` 命令示例
- **这些命令均由 Agent 在隔离环境中以工具调用方式执行，不是本 skill 自身代码**

### 数据流向
- **项目进度**: 本地文件系统 `STATUS.md` → Agent 读取 → 回复用户
- **经验沉淀**: 项目经验 → `MEMORY.md`（仅跨项目通用经验，不含项目进度细节）
- **无网络传输**: 本 skill 不向任何外部服务发送数据

### memory/pm-checkpoint.json
- **内容**: 记录项目名称、最后访问时间、状态摘要
- **权限**: 与 session memory 同级，不包含敏感信息

---

## 📂 依赖审查

本 skill 无代码文件，无依赖项。所有功能通过 OpenClaw Agent 的以下内置工具实现：

| 工具 | 用途 | 风险 |
|------|------|------|
| `read` | 读取 STATUS.md / index.md | 低 — 只读 |
| `write` / `edit` | 写入/更新 STATUS.md | 低 — 项目目录限定 |
| `exec` (可选) | git rev-parse / git log | 低 — 只读命令，目录限定 |
| `memory_get` | 读取 MEMORY.md | 低 — 只读 |

---

## 🚨 应急响应

本 skill 为纯指令系统，不涉及运行时服务。如遇问题：

1. **清除 checkpoint**: `rm memory/pm-checkpoint.json`
2. **更新到最新版本**: `clawhub update agent-project-manager`

---

*版本: v2.5.1 — 安全说明与实现一一对应*

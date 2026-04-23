# 📂 Agent Project Manager Skill

**Cross-Platform Project Context Isolation & State Management for AI Agents**

> 🌐 [English](README.md) | [中文](README_CN.md)

> Battle-tested across **nanobot**, **OpenClaw**, and **Hermes Agent** — solving the fundamental tension between AI agents' stateless nature and projects' need for continuity.

## 简介 (Introduction)

AI Agent 是无状态的，但项目需要连续性。本 Skill 通过为每个项目创建独立的 `STATUS.md` 文件，实现跨会话的无缝上下文恢复，同时不污染全局记忆。

- **物理隔离**：每个项目独立文件，不共享状态
- **意图识别**：无固定关键词，从上下文推断操作
- **分级模板**：完整模板 (A) 用于复杂项目，轻量模板 (B) 用于单任务
- **写入安全**：读-合并-写模式，减少意外覆盖
- **量化效果**：全局记忆从 1153 行降至 167 行（减少 85%）

👉 详细中文设计文档：[DESIGN_CN.md](DESIGN_CN.md)

## Problem

AI agents are stateless — each conversation is a fresh start. But real work spans multiple sessions:

1. **Memory explosion**: All project progress crammed into one file → 1000+ lines, slow retrieval
2. **Context pollution**: Project A's progress leaks into Project B's context
3. **Lost breakpoints**: "Continue last project" → agent doesn't know which one or where it left off
4. **Over-engineering**: Tiny tasks forced into full project templates

## Solution

A per-project `STATUS.md` system — the agent's "external hard drive":

```
workspace/projects/
├── index.md              # Auto-maintained project registry
├── {project-name}/
│   ├── STATUS.md         # Progress, todos, key decisions
│   ├── docs/             # Proposals, reports
│   └── src/              # Code, deliverables
└── _archive/             # Completed/abandoned projects
```

## Key Features

| Feature | Description |
|---------|-------------|
| **Physical Isolation** | Each project has its own `STATUS.md` — no shared state |
| **Intent Recognition** | No rigid keywords — infers new/resume/pause/switch from context |
| **Tiered Templates** | Full (A) for multi-phase projects, Lightweight (B) for single tasks |
| **Write-Safe** | Read-merge-write pattern reduces accidental overwrites within a session |
| **Index Self-Healing** | Auto-creates `index.md`, auto-adds missing projects |
| **Memory Boundary** | Project progress in `STATUS.md`, user preferences in global memory — never mixed |

## Quantified Impact

| Metric | Before | After |
|--------|--------|-------|
| Global memory size | 1153 lines | 167 lines (85% reduction) |
| Project recovery time | User re-describes context (~2 min) | Read STATUS.md (<1 sec) |
| Context pollution risk | High (all projects mixed) | Low (physical isolation) |
| Small task overhead | Full 5-module template | Lightweight 2-3 modules |

## Installation

### nanobot
Copy `SKILL.md` to `~/.nanobot/workspace/skills/project-manager/SKILL.md`

### OpenClaw
Copy `SKILL.md` to `~/.enhance-claw/instances/{instance}/workspace/skills/project-manager/SKILL.md`

### Hermes Agent
Copy `SKILL.md` to your agent's skills directory

## Workflow

1. **New Project** → Create directory + STATUS.md + update index
2. **Resume** → Fuzzy match → Force read STATUS.md → Sync summary
3. **Save State** → Persist conclusions → Update index status
4. **Switch** → Save current → Resume target
5. **Archive** → Move to `_archive/` → Preserve history

## Architecture

See [DESIGN.md](DESIGN.md) for full architecture rationale, memory boundary rules, and comparison with automatic memory consolidation systems.

## License

MIT

---

*Designed by Kris. v2.2 — Templates extracted to references/, concurrent-safety claims softened, git commands scoped to project directory.*

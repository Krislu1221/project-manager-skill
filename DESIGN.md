# Project Manager Skill — Design Document

## Why This Skill Exists

### The Core Problem

AI agents are fundamentally stateless. Each conversation turn is a fresh inference with no persistent memory of prior work. This creates a critical gap for any project that spans multiple sessions:

1. **Context Window Limits**: Even with 128K+ token windows, conversation history gets truncated. Project decisions made 50 turns ago disappear.
2. **Memory Pollution**: When all project progress is stored in a single global memory file, it grows to 1000+ lines. Retrieval becomes slow and noisy.
3. **Lost Breakpoints**: Users say "continue last project" but the agent has no reliable way to know which project, what phase, or what the next step should be.
4. **Over-Engineering**: A simple task like "rename a variable" gets forced into a full project template, wasting tokens and cognitive overhead.

### Why Not Just Use Automatic Memory Consolidation?

Many agent frameworks (nanobot's Dream, OpenClaw's auto-memory, etc.) focus on **automatic memory consolidation** — periodically summarizing conversation history into a global memory file. This is great for long-term user preferences and cross-project lessons, but it has fundamental limitations for project management:

| Dimension | Automatic Memory Consolidation | Project Manager |
|-----------|-------------------------------|-----------------|
| **Granularity** | Global, monolithic | Per-project, isolated |
| **Trigger** | Automatic, periodic | Explicit, intent-driven |
| **Content** | User preferences, lessons learned | Project progress, todos, decisions |
| **Recovery** | Semantic search across all memory | Direct file read by project name |
| **Concurrency** | Single writer, potential conflicts | Per-project isolation (reduces cross-project conflicts; same-project writes use read-merge-write to reduce accidental overwrites) |

**They are complementary, not competing.** Project progress goes in `STATUS.md`; user preferences go in global memory. The two never overlap.

## Architecture Decisions

### 1. Physical Isolation Over Logical Tags

**Decision**: Each project gets its own directory with a dedicated `STATUS.md`, rather than tagging entries in a shared file.

**Rationale**:
- File system provides natural isolation — no risk of Project A's progress overwriting Project B's
- Direct file read is O(1) — no scanning a 1000-line file
- Git diff is cleaner — changes are scoped to one project's file
- Concurrent sessions can operate on different projects without lock contention

### 2. Intent Recognition Over Rigid Keywords

**Decision**: Infer project operations from conversation context rather than requiring exact trigger phrases.

**Rationale**:
- Users naturally say "back to that project" not "resume project {project-name}"
- Fuzzy matching + index lookup handles imprecise references
- When ambiguous, show recent projects for selection instead of guessing

### 3. Tiered Templates Over One-Size-Fits-All

**Decision**: Two templates — Full (A) for complex projects, Lightweight (B) for simple tasks.

**Rationale**:
- Not every task deserves a 5-module STATUS.md
- Lightweight template reduces overhead for single-session tasks
- Auto-upgrade from B to A when complexity grows

### 4. Read-Merge-Write Over Blind Overwrite

**Decision**: Always read the latest `STATUS.md` before writing, then merge changes.

**Rationale**:
- Multiple agent instances may operate on the same project
- Blind overwrite from stale cache causes data loss
- Read-merge-write reduces accidental overwrites within a single session
- **Limitation**: This is not truly atomic — if two sessions read the same base simultaneously, the later write can still clobber the earlier one. For true multi-session atomic safety, a lock file, CAS (compare-and-swap), or append-only log would be needed. In practice, agent sessions rarely write to the same project at the exact same second, so read-merge-write provides sufficient protection for the common case.

### 5. Index Self-Healing

**Decision**: Auto-create `index.md` on first use, auto-add missing projects.

**Rationale**:
- Users shouldn't need to manually maintain an index
- If a project directory exists but isn't in the index, it's a bug — fix it silently
- Index sorted by last active time surfaces relevant projects first

## Memory Boundary Rules

The most critical design constraint is **strict separation** between project progress and global memory:

```
workspace/
├── MEMORY.md                    ← User preferences, cross-project lessons ONLY
├── memory/
│   └── YYYY-MM-DD.md            ← One-line daily summary + STATUS.md reference
└── projects/
    ├── index.md                 ← Project registry
    ├── {project}/
    │   └── STATUS.md            ← Project progress, todos, decisions
    └── _archive/                ← Completed/abandoned projects
```

**Rules**:
1. Never store project progress in global memory
2. Daily logs contain only a summary + reference to `STATUS.md`
3. Cross-project lessons (e.g., "X approach caused Y pitfall") go in global memory
4. Project-specific decisions go in that project's `STATUS.md`

## Quantified Impact

| Metric | Before (Monolithic) | After (Project Manager) |
|--------|---------------------|------------------------|
| Global memory size | 1153 lines | 167 lines (85% reduction) |
| Project recovery time | User re-describes context (~2 min) | Read `STATUS.md` (<1 sec) |
| Context pollution risk | High (all projects mixed) | Low (physical isolation) |
| Small task overhead | Full 5-module template | Lightweight 2-3 modules |
| Write safety | Blind overwrite from stale cache | Read-merge-write reduces accidental overwrites |

## Cross-Platform Validation

This architecture has been validated across three different agent frameworks:

| Platform | Instances | Channels | Status |
|----------|-----------|----------|--------|
| **nanobot** | 1 | Feishu, WeChat, CLI | ✅ Production |
| **OpenClaw** | 2 (`{instance-A}` + `{instance-B}`) | Feishu | ✅ Production |
| **Hermes Agent** | 1 | Custom | ✅ Production |

All three platforms share the same core principles:
- Per-project `STATUS.md` isolation
- Intent-driven workflow (no rigid keywords)
- Write-safe read-merge-write pattern (reduces accidental overwrites)
- Strict memory boundary rules

## Version History

### v2.5 Architecture Additions (2026-05-17)

#### Gantt Chart Auto-Generation
- ASCII progress bar rendering (█ = done, ░ = pending), fixed 20-character width
- Milestone tracking with 3 states: pending / in-progress / completed
- Delay warning system (🔴 delayed / 🟡 at-risk)
- Resource conflict detection (≥3 milestones on same day triggers warning)
- Output: `projects/{name}/GANTT.md` + global summary in `index.md`

#### 8-Rule Risk Detection Engine
- Silent risk: >14 days without updates
- No milestones risk: project started >7 days without any milestones
- Already delayed: past estimated_end & not 100% complete
- Dependency cycle: A depends on B & B depends on A (DAG loop detection)
- Delay risk: <3 days to deadline & progress <70%
- Single point dependency: ≥3 projects depend on same skill
- Estimation bias: last 2 completed projects had >50% estimation error
- Scope creep: milestones increased >50% from original count, then more added

#### Dependency Management System
- 3 types: requires / blocks / optional
- 3 statuses: satisfied / blocked / in-progress
- Machine-parsable YAML format embedded in STATUS.md

#### Conversation Log Archiving
- Output: `memory/project_log_{name}.md`
- Contents: decision timeline + lessons learned + session snapshots
- Searchable by project name and keywords

#### Effort Tracking Fields
- `estimated_hours`: set at project start
- `actual_hours`: **MUST fill at project completion**
- Used by risk engine "estimation bias" rule

---

### v2.4 Architecture Additions (2026-04-25)

#### In-Session Periodic State Synchronization
- Checkpoint file: `memory/pm-checkpoint.json`
- Incremental read: only messages since last check
- 6 exhaustive trigger categories: explicit commands / implicit references / importance markers / topic switches / completion signals / pause signals
- Token consumption control: incremental scans only

#### Index Self-Healing
- Auto-creates `index.md` header if missing
- Auto-populates projects present in directory but not in index
- Every project requires a one-line summary

#### Template Downgrade Mechanism
- Template A (full): >3 days / multi-phase / team collaboration
- Template B (lightweight): <3 days single tasks / research
- Auto-selected based on complexity to prevent over-engineering

---

### v2.2 (Historical)
- Templates moved to `templates/` directory
- "Concurrent safety" → "Write safety", TOCTOU limitation explicitly noted
- Git commands scoped to project directory
- Worktree detection via git-native probe

---

## Future Extensions

1. **Git Integration**: Auto-record commit hashes in `STATUS.md` header for code-state correlation
2. **Auto-Archive**: Periodic check task to detect inactive projects (>30 days) and prompt archival
3. **Cross-Project Dependencies**: Track when Project A blocks Project B
4. **Template Marketplace**: Community-contributed STATUS.md templates for specific domains (research, devops, design)

---

*Full changelog: see CHANGELOG.md*

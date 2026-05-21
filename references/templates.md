# STATUS.md 模板说明

> ⚠️ 以下为简化示意，实际使用时应先从 `skills/project-manager/templates/` 目录读取对应完整模板文件。

---

## A) 完整模板（>3天项目 / 多阶段 / 多人协作）

```markdown
# 项目：[名称]
> 最后更新：[日期] | Git: [commit hash, 如果有] | PM: v2.5

## 🎯 核心目标
[一句话描述项目终极目标]

## ⏱️ 工时追踪
```yaml
estimated_hours: [预计工时，如 8]
actual_hours: null  # 🔴 项目完成时必须回填，供风险引擎「估时不准」规则使用
```

## 📅 时间线
```yaml
start_date: [YYYY-MM-DD]
estimated_end: [YYYY-MM-DD]
actual_end: null  # 项目完成时自动填写
milestones:
  - name: [里程碑 1 名称]
    date: [YYYY-MM-DD]
    status: pending  # pending / in-progress / completed
  - name: [里程碑 2 名称]
    date: [YYYY-MM-DD]
    status: pending
```

## 📍 当前状态
[当前处于什么阶段，刚完成了什么]

## 📋 待办事项
- [x] 已完成 1
- [ ] 待办 2（优先级高）
- [ ] 待办 3

## 🔗 依赖关系
```yaml
# - project: [依赖项目名称]
#   type: requires  # requires / blocks / optional
#   description: "需要该项目提供 XX 能力"
#   status: satisfied  # satisfied / blocked / in-progress
```

## 🔑 关键上下文 / 决策
- 决策 1（为什么这么做）
- 约束 1（用户明确要求的事项）
- 链接（相关 URL / 文件路径）

## 🛑 暂停原因 / 待确认问题
[如果项目暂停，记录卡点或下次需要确认的问题]

## ⚠️ 风险日志
```yaml
# 由 Project Manager v2.5 自动检测
# - name: [风险名称]
#   level: high  # high / medium / low
#   trigger: 14 days no update  # 检测触发条件
#   status: active  # active / mitigated / resolved
#   description: "详细描述"
#   suggestion: "建议动作"
```
```

## B) 轻量模板（<3天单任务 / 个人小项目 / 调研/分析类临时任务）

```markdown
# 项目：[名称]
> 最后更新：[日期] | PM: v2.5

## 📅 时间线
```yaml
start_date: [YYYY-MM-DD]
estimated_end: [YYYY-MM-DD]
estimated_hours: [预计工时，如 4]
actual_hours: null  # 完成后填写
# 自动计算进度
# progress: 0%
```

## 📍 当前状态
[一句话描述当前进度]

## 🔑 决策（可选）
[如果做了重要选择，记录原因。没有就删掉。]

## 📋 下一步
- [ ] 接下来要做什么

## ⚠️ 风险（自动检测）
<!-- Project Manager v2.5 自动填充 -->
```

## 模板选择规则

| 场景 | 模板 |
|----------|----------|
| 多阶段项目 >3 天 | A 完整 |
| 单任务（如"重构这个接口"） | B 轻量 |
| 调研/分析类临时任务 | B 轻量 |
| 多人协作或长期维护 | A 完整 |
| 不确定 | 先用 B，复杂度上升时升级到 A |

---

## 模板来源

实际使用的完整模板文件位于 `skills/project-manager/templates/` 目录：
- `STATUS-A.md` - 完整模板（包含所有 v2.5 字段）
- `STATUS-B.md` - 轻量模板（简化版）

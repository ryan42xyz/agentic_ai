# Oncall Flow (OpenSpec, Analysis-First)

目标：尽快恢复系统，并且不制造新风险。

最小端到端模板（目录/文件/证据格式）见 `control_flow/how_to_use_workflow.md`。

## 三条铁律

1) 分析优先于结论  
2) 证据优先于解释  
3) 止血优先于根因  

这三条决定：oncall 流程更偏 control 层、更保守。

## 定位

一句话：**oncall = 一个 OpenSpec change，但它是“分析型 change”，不是“实现型 change”。**

特征：
- `openspec/changes/<incident-id>/` 作为单一事实源
- 通常没有 patch
- `actions/` 里以 `info_retrieval` / `execution_run` 为主
- `decision/` 关注是否升级、是否回滚、是否止血

## 精简流程

### 0) 初始化（人）
- 创建 `openspec/changes/<incident-id>/request.md`，记录报警/上下文（原文）。

### 1) 编译初始状态（control）
- `control/execution_state_compiler`
- 输出：
  - `state/00_initial.yaml`
  - `state/current.yaml`
  - `notes/open-questions.md`

### 2) 验证状态（control）
- `control/state_validator`
- 输出：`evidence/state_validator/validation.md`

### 3) 选择下一条阻塞不确定性（decision）
- `decision/plan_refiner` → `actions/action-XXX-plan.md`
- `decision/action_selector` → `actions/action-XXX-exec.md`

### 4) 执行一个动作（execution）
只允许以下两类：
- `execution/info_retrieval` → `evidence/<source>/<artifact>.md`
- `execution/execution_runner` → `evidence/run/<run-id>.md`

### 5) 重新编译状态（control）
- `control/execution_state_compiler` 产出新快照 + 更新 `current.yaml`

### 6) 判断是否需要升级/止血（decision + human）
当证据表明需要止血或升级时，明确写入 `actions/` 并等人类确认。

### 7) 循环
重复步骤 2-6，直到：
- 系统恢复或影响被止血
- 关键不确定性被关闭

## 约束

- 不在 oncall change 内直接写 patch（除非显式升级为“实现型 change”）。
- 任何会改变系统状态的动作必须有清晰证据支撑并要求人类确认。
- 只要证据不足，就记录为 open question，不下结论。

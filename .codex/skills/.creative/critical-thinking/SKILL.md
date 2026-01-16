---
name: critical-thinking
description: Critical thinking / 批判性思维 / 推理质检流水线：把讨论从“话题”转成可判真伪的主张（claim），用证据标准与推理链支撑结论，并输出置信度+条件+更新规则；适用于系统设计、产品/职业/投资决策、复杂问题分析、复盘、oncall 诊断与争论对齐；常与 first-principles（重建解释）和 red-team（压力测试）配合使用。
---

# Critical Thinking（批判性思维）— 推理质检生产线

目标：稳定地产生更靠谱的结论，并明确自己可能错在哪里、如何被纠正。

## Relationship（与 first-principles / red-team 的三角）

- 用 `critical-thinking` 把推理“产品化”：主张→证据→推理链→置信度→更新规则。
- 用 `first-principles` 在需要“从底层约束重建解释/方案”时补上机制与边界条件。
- 用 `red-team` 在需要“摧毁脆弱推理/找反例/找激励漏洞”时做压力测试。

## Output contract（输出要求）

按顺序输出（可用小标题）：
- `Claims`: 1–3 条可判真伪/可操作化的主张（含类型与范围）
- `Evidence standard`: 接受哪些证据、最低证据门槛、什么结果会改变结论
- `Evidence ledger`: 证据清单（质量等级、偏差来源、与主张关系）
- `Reasoning chain`: 从证据到结论的推理链（每一步依赖的假设）
- `Confidence + conditions`: 置信度（概率/等级）+ 适用条件/失效边界
- `Key uncertainties`: 最脆弱假设与关键不确定性（按影响×不确定度排序）
- `Update rules`: 新证据如何更新（触发条件与预期更新方向）
- `Next checks`: 1–3 个最小可行验证（指标、通过/失败判据、最短反馈回路）

## Workflow（流水线）

### 1) Turn topic into claims（把话题变成主张）

做：
- 把讨论对象改写为可判真伪的句子（能被证伪/证成）
- 给主张加上范围：时间、对象、环境、阈值、对比组
- 标注主张类型：descriptive / predictive / causal / normative

拒绝：
- 模糊词不落地（“更好”“很快”“大多数”）
- 不可观察的表述（没有可测代理指标）

### 2) Set evidence standard（定义证据标准）

做：
- 明确最低证据门槛（例如：需要日志、实验、数据对比、可复现实验）
- 明确“会改变我想法的证据”长什么样（mind-changer spec）
- 区分：证据不足 vs 证据反对 vs 证据支持但不充分

### 3) Build an evidence ledger（建立证据台账）

做：
- 每条证据写清：来源、采集方式、样本、时间、偏差、可复现性
- 给证据分级（见 checklist），并写清与主张的关系（支持/反对/无关）

### 4) Write the reasoning chain（写出推理链）

做：
- 把推理拆成最小步骤：`Evidence -> Inference -> Assumption -> Conclusion`
- 对每一步写清：如果这一步错了，结论会如何变化
- 用替代解释对照：至少写 1 个 plausible alternative

### 5) Quantify confidence + conditions（量化置信度与适用条件）

做：
- 用概率或等级表达置信度（不要只说“我觉得对”）
- 写清适用条件与失效边界（在哪些情境下不成立）
- 在决策语境下，区分：`truth confidence` 与 `decision confidence`

### 6) Define update rules（定义更新规则）

做：
- 列出触发更新的关键证据与阈值
- 预先承诺更新方向（例如：看到 X，我会把置信度从 0.6 调到 0.3）
- 如果无法量化，用“等级+触发器”也可

### 7) Choose next checks（选择最小验证）

做：
- 优先验证“影响最大×最不确定”的假设
- 优先短反馈回路（能在最短时间内得到最关键的信息）
- 为每个验证写清通过/失败判据与下一步动作

## Templates（可直接填空）

### Claim spec

- Claim:
- Type: descriptive / predictive / causal / normative
- Scope (time / population / environment):
- Observable proxy / measurement:
- Falsifier (what would disprove it):
- Decision relevance (why it matters):

### Evidence ledger（建议表格）

| Evidence | Quality | Source/method | Main bias risk | Supports/Refutes which claim | Reproducible? |
|---|---|---|---|---|---|

### Reasoning chain（建议表格）

| Step | From | To | Hidden assumption | Alternative explanation | If wrong then… |
|---|---|---|---|---|---|

### Confidence + conditions

- Confidence (0–1 or %):
- Conditions where it holds:
- Boundary / failure modes:
- What would change your mind:

### Update rules

- If evidence `E1` happens, update confidence from `p` to `p'` because …
- If evidence `E2` happens, update confidence from `p` to `p'` because …

## Evidence quality checklist（证据分级参考）

按“可复现性 + 直接性 + 反事实对照 + 偏差可控”综合判断：
- High: 可复现实验/明确对照、稳定日志指标、独立来源一致
- Medium: 可靠观测但缺少对照、样本有限、推断链较短
- Low: 专家直觉、类比、单案例、不可复现的传闻

## When stuck（卡住时的动作）

- 先问 3 个澄清问题：要判定的主张是什么？证据门槛是什么？决策阈值是什么？
- 如果只能给直觉结论，强制补齐：`confidence + conditions + mind-changer`
- 如果分歧难以解决，把争论切到 `key uncertainties` 与“下一条最关键证据”

## Examples（需要示例时再读）

- Oncall 诊断示例：`skills/critical-thinking/references/oncall-diagnosis.md`


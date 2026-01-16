===== FILE: .codex/skills/.creative/first-principles/SKILL.md =====
---
name: first-principles
description: First-principles reasoning / 第一性原理 / 从零推导思考框架，用于把问题拆到最底层约束（物理/逻辑/信息/算力/人性/经济/时间），显式化隐含假设并据此自下而上重建方案；适用于战略推演、产品/系统设计、商业模型、AI agent 协作、决策复盘、idea review/refine，或任何需要摆脱行业惯例与既有模式的分析。
---

# First Principles（第一性原理）— 正向思维引擎

以“建构”为目标：先把问题拆到不可再简化的边界条件，再从这些约束自下而上重建模型/方案。

## Operating stance

- 把“行业经验/惯例/最佳实践”当作假设，而不是理由。
- 优先显式化：边界、变量、约束、假设、证据、可检验性。
- 输出应可行动：给出可验证的下一步，而不是抽象金句。

## Workflow

### 1) Define the object of analysis（定义分析对象）

目标：回答“我们到底在分析什么”，并画出边界。

做：
- 明确对象类型：系统 / 概念 / 现象 / 决策 / 方案
- 指定范围：包含什么、不包含什么
- 定义成功指标与时间尺度
- 列出关键变量与可控/不可控项

### 2) Decompose assumptions（拆解隐含假设）

目标：把“默认前提”摊在阳光下，并区分哪些是假设、哪些是约束。

做：
- 逐句/逐点问：这句话成立依赖什么前提？
- 将“经验结论”翻译为可检验的命题
- 标注每条假设的来源：观察、类比、权威、历史惯例、可推导

### 3) Reduce to fundamental laws（还原到底层约束）

目标：在不借助历史/惯例的前提下，找出必须遵守的边界条件。

做：
- 把约束按类别归因（见下方 checklist）
- 识别“硬约束”(必须满足) 与 “软约束”(偏好/策略)
- 把“看似复杂”的问题压缩成最少的关键张力/权衡

### 4) Rebuild upward logically（自下而上重建）

目标：从底层约束推导出新的结构/模型/决策逻辑，并给出验证路径。

做：
- 生成 2–3 个候选机制/方案（尽量不同，而不是同质微调）
- 对每个方案写清：满足哪些硬约束、牺牲什么、主要风险
- 设计最短反馈回路：用最小成本验证最高不确定性

## Output contract（输出要求）

按以下顺序输出（可用小标题）：
- `Boundary`: 分析对象的精确定义、范围、成功指标、时间尺度
- `Assumption ledger`: 假设清单（含置信度与可检验方式）
- `Fundamental constraints`: 不可再简化的边界条件（按类别归因）
- `Rebuilt model / decision logic`: 从约束推导出的结构/方案与权衡
- `Next experiments`: 1–3 个最小实验/验证步骤（含指标与通过/失败判据）
- `Mind-changers`: 哪些信息/结果会让结论反转或显著调整

## Templates（可直接填空）

### Boundary

- Object:
- Goal / success metric:
- Time horizon:
- Scope in:
- Scope out:
- Controllables:
- Non-controllables:
- Constraints already known:

### Assumption ledger（建议表格）

| Assumption | Category | Why believed | If false, then… | How to test | Confidence |
|---|---|---|---|---|---|

`Category` 参考：physics / logic / information / compute / human / economics / legal-policy / org-process

## Fundamental constraint checklist（不可再简化的边界条件）

- Physics: 能量/物质/空间/时间、损耗、可靠性上限
- Information: 可观测性、延迟、带宽、噪声、信息不对称、反馈周期
- Compute: 算力/内存/并行度、成本曲线、推理/训练瓶颈、工具调用开销
- Humans: 动机/激励、注意力、信任与协作成本、技能分布、行为偏差
- Economics: 供需、定价、边际成本、替代品、切换成本、网络效应
- Legal/Policy: 合规、隐私、责任边界、合同约束
- Org/Process: 沟通通道、审批链路、所有权、度量体系

## Rebuild prompts（重建时常用提问）

- 如果从零开始建造，我们“必须”满足哪些硬约束？
- 最简单的可行机制是什么？复杂性来自哪里，是否必要？
- 系统的主瓶颈是什么（信息流/反馈周期/算力/人/资金/时间）？
- 哪个变量最值得被直接测量？目前缺少哪条关键观测？
- 最短反馈回路是什么？用什么最小实验验证最大不确定性？

## When stuck（卡住时的动作）

- 先提出最多 3 个澄清问题，优先问“目标/约束/资源/风险承受度”。
- 如果信息不足，给出 2 套并行推导：`assumption A` 与 `assumption B`，并明确分歧点与验证方式。

## Examples（需要示例时再读）

- AI agent 协作的第一性原理拆解：`skills/first-principles/references/agent-collaboration.md`

===== FILE: .codex/skills/.creative/first-principles/references/agent-collaboration.md =====
# Example: AI agent 协作（第一性原理拆解）

## Boundary

- Object: 多 agent 协作完成一个复杂任务（研究→方案→实现→验证）
- Goal: 提升吞吐/质量/可靠性，同时控制成本与风险
- Time horizon: 单次任务 + 长期复用（知识/工具沉淀）
- Scope in: 信息流、反馈周期、算力/工具调用、任务切分、对齐与评审
- Scope out: 具体框架/“行业最佳实践”细节（先当作可选实现）

## Assumption ledger（样例）

| Assumption | Category | Why believed | If false, then… | How to test | Confidence |
|---|---|---|---|---|---|
| 并行 agent 一定更快 | information / org-process | 直觉：并行=提速 | 协作开销吞噬收益 | 做 A/B：单 agent vs 多 agent，统计端到端耗时 | medium |
| agent 输出可直接拼接 | information | “模块化”类比 | 需要大量对齐/重写 | 统计合并时返工率 | low |
| 主要瓶颈在“想法”而非“执行” | human / compute | 经验 | 真瓶颈可能是验证/工具调用 | 记录每阶段耗时与阻塞点 | medium |

## Fundamental constraints（不可再简化）

- Information: 跨 agent 的信息传递有损耗（压缩、误读、遗漏）；同步越频繁，延迟越大
- Feedback loops: 最慢的验证环节（测试/运行/人审）决定整体节奏；长环节需要前置风险控制
- Compute/tools: 工具调用与上下文切换有固定成本；多 agent 可能增加总调用量
- Humans: 注意力与信任是稀缺资源；评审/裁决链路是硬约束
- Economics: “更快”并非免费，协作的边际收益递减

## Rebuilt model / decision logic

把协作系统视为“信息处理流水线”：
- 目标是最大化有效信息吞吐（有用且可验证），而不是最大化 token/文档产出
- 用“反馈周期”驱动切分：让高不确定性部分尽快进入短反馈回路
- 将协作开销当作一等公民：每增加一个接口/交接点，都要有明确收益假设

## Candidate mechanisms（候选机制）

1) 单 owner + 多并行“探路者”
- 多 agent 并行探索假设/方案，owner 统一裁剪与整合
- 适合：前期探索大、需要发散；不适合：需要大量一致性写作/实现

2) 流水线分工（Research → Plan → Implement → Verify）
- 每个环节只交付可验证产物（例如：可运行命令、可复现实验）
- 关键：交付物契约化（输入/输出/通过标准），否则交接成本爆炸

3) 双回路（短回路 + 长回路）
- 短回路：快速假设→最小实验→判定
- 长回路：架构一致性、代码质量、文档沉淀、复盘

## Next experiments（最小验证）

- 记录基线：单 agent 完成一次任务的端到端耗时、返工次数、缺陷密度
- 设计 2-agent 实验：owner+探路者，明确接口（问题陈述、假设表、最小实验）
- 用 3 个指标评价：`cycle time`、`rework rate`、`verification pass rate`

## Mind-changers

- 如果协作后 `rework rate` 上升且 `cycle time` 不降，说明瓶颈在对齐/信息损耗，应收敛接口或减少并行度
- 如果 `verification pass rate` 显著提升，说明多视角评审价值高，应加大“评审型 agent”投入而非“发散型 agent”



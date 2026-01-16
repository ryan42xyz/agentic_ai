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


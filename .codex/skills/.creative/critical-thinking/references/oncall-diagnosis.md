# Example: Oncall 诊断（Critical Thinking 流水线）

## Scenario（场景）

线上错误率在 10 分钟内从 0.1% 升到 2%，报警触发。团队争论点是：“是不是刚发布导致的？”

## Claims

1) `C1 (causal)`: 本次错误率上升主要由最近一次发布引起（占比 > 50%）。
- Scope: 发布后 0–30min，受影响服务 `api-gateway`
- Observable proxy: 错误码分布、版本维度错误率、回滚前后变化
- Falsifier: 回滚后错误率不下降；或未发布实例同样升高

2) `C2 (descriptive)`: 错误集中在某一类请求/下游依赖，而非全量随机。
- Proxy: 按 route / dependency / tenant 分桶的错误率与延迟
- Falsifier: 各桶均匀上升（支持“基础设施/网络层面”替代解释）

## Evidence standard

- 最低证据门槛：必须看到与“版本/发布”相关的可观测信号（分版本指标、回滚实验、变更窗口对齐）
- Mind-changer：只要发现“未发布实例也同步恶化”，立即下调 `C1` 并转向基础设施/下游依赖排查

## Evidence ledger

| Evidence | Quality | Source/method | Main bias risk | Supports/Refutes which claim | Reproducible? |
|---|---|---|---|---|---|
| 错误率上升时间与发布窗口重合 | Medium | deploy log + alert timeline | 巧合/共同原因 | weakly supports C1 | yes |
| 新版本实例错误率 3.5%，旧版本 0.2% | High | metrics split by version | 采样/标签错误 | supports C1 | yes |
| 错误集中在 `POST /checkout` | High | route-level metrics | 路由聚合误差 | supports C2 | yes |
| 下游 `payments` p95 延迟上升 | Medium | dependency metrics | 因果方向不明 | alternative to C1 | yes |

## Reasoning chain

| Step | From | To | Hidden assumption | Alternative explanation | If wrong then… |
|---|---|---|---|---|---|
| 1 | 版本维度错误率分化 | 发布是主要原因 | 版本标签准确、流量分配可比 | 新版本承担更多高风险流量 | C1 置信度下降 |
| 2 | 错误集中在 checkout | 变更影响局部路径 | 路由归因准确 | 该路径依赖的下游退化 | 转向下游排查 |
| 3 | 回滚后若下降 | 因果更强 | 回滚影响迅速 | 其他同时发生变更 | 需要更多对照 |

## Confidence + conditions

- C1 confidence: 0.75
- Conditions where it holds: 版本标签可靠；新旧版本流量结构相近；回滚影响可在 5–10min 体现
- Failure modes: 标签错/流量偏；下游 `payments` 自身退化导致新版本更敏感

## Key uncertainties

1) 版本分流是否可比（影响高、不确定中）
2) 下游 `payments` 是否在同窗口发生退化（影响高、不确定高）
3) 错误是否由配置/特性开关触发而非代码（影响中、不确定中）

## Update rules

- 如果回滚后 10 分钟内错误率恢复到 <0.3%，把 C1 从 0.75 上调到 0.9
- 如果未发布实例错误也同步升高，把 C1 从 0.75 下调到 0.3，并优先排查基础设施/下游
- 如果 `payments` 在同时间段出现全局退化，把 C1 从 0.75 下调到 0.5，并把主因拆成“发布×下游敏感性”

## Next checks（最小验证）

1) 执行回滚（或灰度切回旧版本）并监控 10 分钟
- Pass: 错误率显著下降且版本差异消失
- Fail: 错误不降或版本差异仍在

2) 对照未发布实例/环境
- Pass: 未发布实例稳定（支持 C1）
- Fail: 未发布也恶化（反对 C1）

3) 对 `payments` 做快速健康检查（错误率、延迟、限流、依赖链）
- Pass: 正常（减少替代解释权重）
- Fail: 异常（主因需要重写为“下游退化为主”或“交互效应”）


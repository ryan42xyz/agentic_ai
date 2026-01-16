https://datavisor.atlassian.net/wiki/spaces/~557058edd12ee1c71041ba9f529f4c12d8df22/pages/4247486469/Onefinance+QPS+spike+oncall+12-28+29

你这段记录，本质上是一整套 OneFinance 在 12-28/29 遭遇 QPS spike 时的「止血 + 降级 + 承载扩容 + 负载切换」联合处置流程。
我先给你一句话版本，然后再按“系统层级”把每一步串起来，告诉你每个动作在解决什么问题、为什么要这么做、它们之间的逻辑关系是什么。

一句话总览（你这套流程在干什么）

当 OneFinance 的实时流量突然飙升，导致 FP / FP-Async / Kafka / Yugabyte 同时承压时，通过「限制非核心计算 + 扩容关键组件 + 分流请求 + 动态关闭后台任务」来优先保证主链路可用性，避免系统雪崩。

一、先搞清楚“问题从哪来”
1️⃣ 触发事件：OneFinance QPS Spike

外部业务流量激增（真实用户流量）

压力从 dApp → network → traffic switch → apisix → FP → FP-Async → Kafka → Yugabyte
一路向下放大

2️⃣ 核心瓶颈被确认

你这段笔记里已经点名了两个“扛不住的点”：

FP pods can’t handle

Yugabyte can’t handle

这说明不是单点问题，而是：

上游 QPS 没被限制

下游计算 + 存储双双被打满

二、应用层（FP / FP-Async）：先活下来再说
🔹 FP / FP-Async 线程池配置（Prerequisite 部分）
COREPOOLSIZEINCONSUMER = 40
MAXPOOLSIZEINCONSUMER = 80


这一步在干什么？

增大 Consumer 线程池容量

提高并发消费 Kafka 消息的能力

避免 backlog 快速堆积导致延迟爆炸

👉 本质：短期扩大吞吐能力，避免请求在应用层直接被阻塞

🔹 HPA 调整

fp-async hpa: min 6, max 8

fp hpa: min 12, max 16

这一步的含义是：

强制提升最小实例数，避免冷启动或 scale-up 来不及

限制最大实例数，防止无脑扩容把数据库拖死

👉 本质：有边界的扩容，而不是无限堆 pod

三、基础设施层（Infra）：让底座别先塌
🔹 Kafka：双分区
double kafka partition
- velocity.onefinance
- velocity_detail_onefinance


目的：

提升并行消费能力

降低单 partition 热点

👉 Kafka 是 FP-Async 的“供血系统”，这一步是在缓解输入侧压力

🔹 Yugabyte：Double instance type

垂直扩容（CPU / Memory / IO）

给 DB 临时“续命”

👉 本质：数据库优先稳住，否则所有服务都会被拖死

四、流量层：50 / 50 分流是“止血带”
🔹 流量拆分
Split 50/50 traffic
From dApp → network → traffic switch → apisix


这一步在解决什么？

把单集群 / 单路径的压力切开

给系统一个缓冲时间窗口

👉 本质：降低瞬时 QPS 峰值，而不是提升处理能力

这是典型的 oncall 里的 “负载转移止血手段”。

五、真正的关键：关闭「非核心计算」

这是你这份记录里最重要、也是最成熟的一段设计。

🔥 核心问题

Parameter to rate limit recompute
how to know if there is a Recompute lag

说明：

Recompute / AggBackfill 是 高 CPU + 高 IO 的后台任务

在 QPS spike 时，它们会和实时请求抢资源

🔹 TenantInfo 动态降级（无需重启）
关闭 Recompute
hotspotRecomputeTaskRateLimitPerPartition = 0

关闭 AggBackfill
hotspotAggBackfillTaskRateLimitPerPartition = 0


这一步做了什么？

直接把 后台补算 / 回填任务的速率打到 0

实时流量优先

非实时计算全部暂停

👉 本质：主动降级，而不是被动 OOM / timeout

🔹 为什么这一步设计得很好？

你这里其实已经做到了 成熟平台级系统的几个关键点：

TenantInfo 是动态配置

不用重启

不用改代码

秒级生效

限速是 per-partition

不影响 Kafka 结构

不影响实时消费

默认值 ≠ 紧急值

Default:
Recompute = 10
AggBackfill = 10
VelocityDetail = 100


Oncall 时：

一键降为 0

等系统恢复再慢慢打开

👉 这是标准的“熔断 + 手动恢复”模式

六、Grafana 的角色：判断“什么时候可以开回来”

你贴的 Grafana 链接，其实回答的是这个问题：

Recompute lag 是否在积压？
FP-Async 是否已经回到健康区间？

指标用途是：

判断是否可以重新打开 Recompute / AggBackfill

而不是一直关着

七、整体逻辑串起来其实非常清晰

我帮你把整个流程压成一句“工程视角”的话：

在 OneFinance QPS 暴涨场景下，通过扩容计算与存储、分流外部请求、并利用 TenantInfo 动态关闭非核心后台计算，优先保证主链路实时服务可用，避免 Kafka backlog、FP-Async 堵塞和 Yugabyte 崩溃，从而实现系统的可控降级与恢复。

八、一个隐藏的加分点（你可能没意识到）

你这套流程已经具备了：

清晰的 Critical Path（实时请求）

可随时关闭的 Non-Critical Work（Recompute / Backfill）

动态可调的 Rate Limiter

流量层 + 应用层 + 存储层的联动

👉 这已经不是“临时 oncall 手段”，而是平台级架构能力。

如果你愿意，下一步我可以帮你做三件更狠的事之一：

把这次事件整理成一份 Postmortem（SRE 标准版）

帮你抽象成 OneFinance 流量突发 Runbook

或者把 TenantInfo + RateLimit 设计总结成 平台架构亮点，直接能写进简历

你选一个。

画出charts，能够形象看出来，不需要 mermaid

好，这里我不用 mermaid，也不用任何“工具味”的东西，而是用 工程师一眼就能读懂的结构化 ASCII 图 + 分层说明。
目标只有一个：让人“看一眼就知道这次 oncall 到底做了什么”。

1️⃣ 事故全链路压力传播图（问题是怎么扩散的）
           外部流量突增 (OneFinance QPS Spike)
                         │
                         ▼
        ┌──────────── dApp / Client ────────────┐
                         │
                         ▼
               Network / Traffic Switch
                         │
                 (50 / 50 流量切分)
                         │
                         ▼
                     APISIX
                         │
                         ▼
                  Feature Platform (FP)
                 ┌───────────────┐
                 │  实时 API 请求 │  ← FP Pods 扛不住
                 └───────────────┘
                         │
                         ▼
                FP-Async (Kafka Consumer)
          ┌────────────────────────────────┐
          │ Recompute / AggBackfill / Detail│ ← CPU & IO 黑洞
          └────────────────────────────────┘
                         │
                         ▼
                       Kafka
            (velocity / velocity_detail)
                         │
                         ▼
                     Yugabyte
                 (DB 扛不住，放大故障)


直观结论：

压力不是某一层的问题

是实时流量 + 后台计算 + 存储三者叠加

如果不切断某一支，必然雪崩

2️⃣ Oncall 的第一步：止血（流量 & 容量）
🔹 流量止血：50 / 50 Split
            原来：
            100% 流量
                 │
                 ▼
               单集群

            oncall 时：
            100% 流量
                 │
        ┌────────┴────────┐
        ▼                 ▼
     集群 A (50%)      集群 B (50%)


作用：

瞬时 QPS 减半

给系统“喘息时间”

不解决根因，但防止立刻挂

🔹 容量止血：HPA + 实例扩容
FP Pods:
   原来：  min ~ 小
   oncall：min 12  →  max 16

FP-Async Pods:
   原来：  min ~ 小
   oncall：min 6   →  max 8

Yugabyte:
   Instance Type  × 2


直觉理解：

前端多点人接电话

后端数据库先“加机器续命”

但注意：这一步不能无限做

3️⃣ 真正的关键动作：主动降级（切掉“耗能后台任务”）
🔥 核心思想图
                FP-Async Worker 内部

        ┌───────────────────────────────────┐
        │ Kafka Partition                   │
        │                                   │
        │  ┌──────────┐  ┌──────────────┐  │
        │  │ 实时请求 │  │ Recompute    │  │
        │  │ (必须活) │  │ (可暂停)     │  │
        │  └──────────┘  └──────────────┘  │
        │                                   │
        │  ┌──────────────┐                │
        │  │ AggBackfill  │                │
        │  │ (可暂停)     │                │
        │  └──────────────┘                │
        └───────────────────────────────────┘


👉 问题在于：
当 QPS spike 时，这些任务会同时抢：

CPU

Kafka 消费能力

Yugabyte IO

4️⃣ TenantInfo RateLimit：精准“拉闸”
🔹 默认状态（正常运行）
Per Kafka Partition:

Recompute       ██████████  (10)
AggBackfill     ██████████  (10)
VelocityDetail  ██████████████████████████ (100)

🔹 Oncall 紧急状态（你做的事）
TenantInfo Update:

Recompute       ░░░░░░░░░░  (0)  ← 完全关闭
AggBackfill     ░░░░░░░░░░  (0)  ← 完全关闭
VelocityDetail  ██████████████████████████ (100)


视觉理解：

不是“慢一点”

是直接把非核心计算的电闸拉掉

5️⃣ 为什么这是“正确的工程做法”
🔹 动态生效，不重启
curl → FP API → TenantInfo
                 │
                 ▼
          RateLimiter 更新
                 │
                 ▼
        Consumer 即刻生效


没有 rollout

没有 pod restart

非常适合 oncall

🔹 降级不是破坏数据
实时请求： 继续处理 ✅
Recompute： 暂停，但不丢数据 ⏸
AggBackfill： 延后再补算 ⏸


本质是：

用“数据延迟”换“系统可用性”

6️⃣ Grafana 在这个流程中的位置
Grafana Dashboard
        │
        ├─ FP-Async Lag
        ├─ Kafka Consumer Delay
        ├─ Yugabyte CPU / IO
        └─ 请求 P95 / P99


你不是靠感觉开的开关，而是：

指标恢复 → 逐步调高 RateLimit → 系统回暖

7️⃣ 全流程一张“工程脑图”
QPS Spike
   │
   ├─▶ 流量切分 (50/50)
   │
   ├─▶ 扩容
   │     ├─ FP / FP-Async HPA
   │     ├─ Kafka Partition
   │     └─ Yugabyte Instance
   │
   └─▶ 主动降级 ⭐
         ├─ Recompute = 0
         ├─ AggBackfill = 0
         └─ 实时链路保活

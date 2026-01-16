# Latency Troubleshooting Guide

## Purpose

This guide provides systematic approach to diagnose latency issues by first checking SLA dashboard to determine if the problem is in FP service or network/ingress layer.

## First Step: SLA Dashboard Analysis

**Always start with SLA dashboard** to get a high-level view of latency breakdown before diving into detailed metrics.

### SLA Dashboard Location

**SLA Batch and Realtime Dashboard**: 
- URL: `https://grafana-mgt.dv-api.com/d/p1KqfRAMk/sla-batch-and-realtime`
- Parameters: `var-client`, `var-PromDs`, `var-sandbox_client`, `var-pipeline`, `var-Batch_Pipeline`, `from`, `to`

### Key Panels in SLA Dashboard

The SLA dashboard contains 21 panels that show the complete latency breakdown:

1. **Response Percentiles from Ingress** (Recording Rule) - Total Response Time (`request_time`)
2. **Response Percentiles from Ingress** (LogQL) - Total Response Time (real-time calculation)
3. **Upstream latency graph (Feature Platform)** - Upstream Response Time (`upstream_response_time`)
4. **Waiting Latency between Ingress and Upstream** - Waiting Latency (`waiting_latency`)

### Core Latency Formula

```
Total Response Time (request_time) = Waiting Latency + Upstream Response Time
     (SLA 面板 1/2)                      (SLA 面板 4)        (SLA 面板 3)
```

**Visual Breakdown**:
```
┌─────────────────────────────────────────────────────────┐
│         Total Response Time (request_time)              │
│  = Waiting Latency + Upstream Response Time             │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────┐  ┌────────────────────────┐│
│  │   Waiting Latency      │  │  Upstream Response    ││
│  │                        │  │       Time             ││
│  │ • 客户端网络延迟(往返) │  │  • FP Pod 处理时间     ││
│  │ • Ingress 处理时间     │  │  • 特征计算            ││
│  │ • 内部网络延迟(往返)   │  │  • 数据库查询          ││
│  │ • 负载均衡             │  │  • 业务逻辑            ││
│  └────────────────────────┘  └────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

## Decision Logic: FP vs Network/Ingress

### Scenario A: Upstream Response Time High, Total Response Time High

```
Total Response Time:  1500ms  ❌
Upstream Response:    1400ms  ❌
Waiting Latency:       100ms   ✅
```

**Conclusion**: 🎯 **FP Service Issue** (业务逻辑慢)

**Root Cause**: FP Pod processing is slow, not network/ingress issue.

**Investigation Direction**:
- Check FP Pod CPU/Memory usage
- Check database query performance (YugabyteDB is P0 priority)
- Analyze feature calculation algorithm optimization
- Check for slow external dependency calls (Ekata API is P1 priority)

### Scenario B: Upstream Response Time Normal, Total Response Time High

```
Total Response Time:  1500ms  ❌
Upstream Response:     200ms   ✅
Waiting Latency:      1300ms  ❌
```

**Conclusion**: 🌐 **Network or Ingress Issue**

**Root Cause**: Network delay or Ingress processing is slow, not FP service issue.

**Investigation Direction**:
- Check **Waiting Latency** panel (panel 4)
- Check client to Ingress network quality
- Check Ingress Controller performance (CPU/Memory)
- Check Ingress to FP Pod internal network
- Check Ingress logs for connection timeouts

### Scenario C: Both High

```
Total Response Time:  1500ms  ❌
Upstream Response:    1400ms  ❌
Waiting Latency:       100ms   ⚠️ (may be normal or slightly elevated)
```

**Conclusion**: 🔥 **Systemic Issue** (both layers affected)

**Root Cause**: Multiple issues or cascading failure.

**Investigation Direction**:
- Check if all FP replicas are affected
- Check if issue started after specific time window
- Check for recent deployments or config changes
- Check infrastructure health (nodes, network, ingress)

## Key Metrics Interpretation

### Waiting Latency

**Formula**: `waiting_latency = request_time - upstream_response_time`

**Actual Meaning**: Ingress internal waiting/queuing/proxy/scheduling/rate limiting overhead

**⚠️ Common Misconception**: 
- ❌ Not necessarily "network issue"
- ⚠️ More reflects ingress own pressure

**Contains**:
- Client to Ingress network delay (round trip)
- Ingress routing, load balancing time
- Ingress to FP Pod internal network delay (round trip)
- Ingress internal queuing, proxy, scheduling, buffer overhead

**High Waiting Latency Indicates**: Network or Ingress problem, need to investigate:
- Ingress Controller performance (CPU/Memory)
- Network quality (client to DataVisor network path)
- K8s internal network
- Ingress logs for connection timeouts

### Upstream Response Time

**Meaning**: 
- **Only measures FP Pod processing time**
- From FP Pod receiving request to returning response
- **Does NOT include network delay and Ingress processing time**
- This is **actual business logic processing time**

**High Upstream Response Time Indicates**: FP service issue, need to investigate:
- FP Pod resource usage (CPU/Memory)
- Database query performance (YugabyteDB P0, MySQL P2)
- External API calls (Ekata API P1)
- Application-level errors or exceptions

## Reference Values

### ✅ Normal Situation (Reference Values)

| Metric | P50 | P95 | P99 | P99.9 |
|--------|-----|-----|-----|-------|
| **Total Response Time** | < 100ms | < 300ms | < 500ms | < 1000ms |
| **Upstream Response** | < 50ms | < 150ms | < 300ms | < 500ms |
| **Waiting Latency** | < 50ms | < 100ms | < 200ms | < 500ms |

### ⚠️ Needs Attention (Yellow Warning)

| Metric | P50 | P95 | P99 | P99.9 |
|--------|-----|-----|-----|-------|
| **Total Response Time** | 100-200ms | 300-500ms | 500-1000ms | 1000-2000ms |
| **Upstream Response** | 50-100ms | 150-300ms | 300-500ms | 500-1000ms |
| **Waiting Latency** | 50-100ms | 100-200ms | 200-500ms | 500-1000ms |

### ❌ Serious Problem (Red Alert)

| Metric | P50 | P95 | P99 | P99.9 |
|--------|-----|-----|-----|-------|
| **Total Response Time** | > 200ms | > 500ms | > 1000ms | > 2000ms |
| **Upstream Response** | > 100ms | > 300ms | > 500ms | > 1000ms |
| **Waiting Latency** | > 100ms | > 200ms | > 500ms | > 1000ms |

## Workflow: First Response to Latency Alert

### Step 1: Open SLA Dashboard

1. Open SLA Batch and Realtime dashboard
2. Set appropriate client (if known) or use "All"
3. Set time window (default: `now-2h` to `now`)
4. Review all 4 latency panels

### Step 2: Compare Metrics

1. **Check Total Response Time** (panel 1/2)
   - Is P95/P99 exceeding threshold?
   - Confirm problem exists

2. **Check Upstream Response Time** (panel 3)
   - Is it high or normal?
   - Compare with reference values

3. **Check Waiting Latency** (panel 4)
   - Is it high or normal?
   - Calculate: `waiting_latency = request_time - upstream_response_time`

### Step 3: Make Initial Decision

**If Upstream Response Time is high**:
- → FP service issue
- → Proceed to FP service health checks (Priority 1)
- → Check YugabyteDB (Priority 2, P0 dependency)

**If Waiting Latency is high**:
- → Network/Ingress issue
- → Proceed to Ingress/Nginx logs (Priority 0)
- → Check Ingress Controller resources

**If both are high**:
- → Systemic issue
- → Check infrastructure health
- → Check for recent changes

### Step 4: Detailed Investigation

Based on initial decision, follow detailed investigation steps in checklist.

## Related Dashboards

### E2E Dashboard (Ingress → FP Pod)
- **URL**: `https://grafana-mgt.dv-api.com/d/p1KqfRAMk/sla-batch-and-realtime`
- **Use for**: Detailed latency breakdown analysis
- **Panels**: 21 panels including the 4 key latency panels

### Multi-cluster Traffic Distribution (E2E for APISIX)
- **URL**: `https://grafana-mgt.dv-api.com/d/X2qhqpjSk/multi-cluster-traffic-distribution`
- **Use for**: Requests that go through APISIX gateway
- **Note**: If request goes through APISIX, check this dashboard first, then compare with E2E dashboard

## Key Insights

1. **Always start with SLA dashboard** - It provides the fastest way to determine if issue is in FP or network/ingress layer
2. **Use the formula** - `request_time = waiting_latency + upstream_response_time` to understand latency breakdown
3. **Waiting Latency ≠ Network Issue** - It reflects ingress internal pressure, not necessarily external network problems
4. **YugabyteDB is P0** - For FP service issues, always check YugabyteDB first (per architecture_fp.md)
5. **High failed rate suggests systemic issue** - If failed rate is high (e.g., >80%), likely not isolated latency spikes

## Related Documents

- **Architecture Guide**: `../blogs/architecture_fp.md` - FP service topology and dependency priorities
- **Latency Architecture**: `../blogs/monitoring-latency_architecture.md` - Complete latency architecture and dashboard guide
- **Request Routing**: `../blogs/architecture-request-routing-flow.md` - Request flow and routing architecture

---

**Last Updated**: 2025-01-XX  
**Source**: `../blogs/monitoring-latency_architecture.md`

# Oncall Cases Archive

This file archives historical oncall cases from the oncall cognitive control plane system.

Rules:
- Reference only - these are historical cases for pattern recognition
- Use for understanding common failure modes and triage patterns
- Never infer current state from historical cases
- Cases are organized by family/phenomenon for pattern matching

## Case Families

### 1. Ingress Global Rate Limit 429 + Burst Window Mismatch (1s vs 1m)

**Pattern**: Customer-facing intermittent failures with observed intermittent 429s; 1m average QPS is healthy but 1s/5s spikes can trigger rate limiting; may be accompanied by traffic switch / recent config or restart.

**Typical Evidence**:
- Customer intermittent failure + observed intermittent 429
- 1m average QPS healthy but 1s/5s spikes trigger rate limiting
- May be accompanied by traffic switch / recent config or restart

**Typical Decision**: Mostly `monitor` + explicitly verify short-window QPS/429 correlation and ingress rate limit config; one case directly `escalate`.

**Commands**: `kubectl get ingress -A -o yaml  | grep -E "global-rate-limit"`

**Cases**:

#### Complete Cases (with case.json)

##### Escalate Decision
- **alert_20260103T143243Z (2026-01-03)**
  - **Evidence**: Customer intermittent failure; observed intermittent 429; burst + 1s global rate limit can trigger even when 1m QPS is healthy; accompanied by restart/config change clues
  - **Decision**: `escalate` - Priority: confirm rate limit config/window and short-window QPS↔429 correlation

##### Monitor Decision
- **alert_20260103T162612Z (2026-01-03)**
  - **Evidence**: Customer intermittent failure; intermittent 429; 1m QPS healthy but burst + 1s window may trigger
  - **Decision**: `monitor` - First use short-window metrics to verify burst↔429, then decide whether to escalate/expand

- **alert_20260108T134045Z (2026-01-08)**
  - **Evidence**: Same as above, and explicitly customer-facing; accompanied by recent changes/restart clues
  - **Decision**: `monitor` - First verify rate limiting and short-window metrics, then decide escalation and impact scope

#### Partial Cases (missing case.json)

##### Bursty Traffic Window Mismatch
- **alert_20260103T154152Z (2026-01-03)**
  - **Artifacts**: `decision_for_plan` + `execution_plan_v1`
  - **Classification**: B_potential_risk
  - **Top Hypothesis**: ingress_global_rate_limit_window_mismatch_bursty_traffic (high)
  - **Decision**: Follow execution plan: get ingress annotations/rate limit params → short-window QPS vs 429 → Loki check rate limit marker

##### 429 Window Mismatch
- **alert_20260103T160008Z (2026-01-03)**
  - **Artifacts**: `decision_framing` + `execution_plan_v1`
  - **Classification**: B_potential_risk
  - **Top Hypothesis**: ingress_global_rate_limit_429_window_mismatch (high)
  - **Decision**: 429 burst family (suggest re-run to generate case.json to capture evidence/rule_excerpt)

- **alert_20260103T161646Z (2026-01-03)**
  - **Artifacts**: `decision_framing` + `execution_plan_v1`
  - **Classification**: B_potential_risk
  - **Top Hypothesis**: ingress_global_rate_limit_window_mismatch (high)
  - **Decision**: 429 burst family (suggest re-run to generate case.json)

##### 1s Window Burst Throttle
- **alert_20260103T162425Z (2026-01-03)**
  - **Artifacts**: `decision_framing` + `execution_plan_v1`
  - **Classification**: B_potential_risk
  - **Top Hypothesis**: ingress_global_rate_limit_1s_window_burst_throttle (high)
  - **Decision**: 429 burst family (suggest re-run to generate case.json)

### 2. Ingress→Upstream Waiting Latency High but Upstream Latency Normal

**Pattern**: `waiting_latency` increases while `upstream_response_time` is normal; traffic switch has occurred (may be mitigation); need to first confirm blast radius.

**Typical Evidence**:
- `waiting_latency` rises while `upstream_response_time` is normal
- Traffic switch has occurred (may be mitigation)
- Need to first confirm blast radius

**Typical Decision**: `monitor` - Priority: check latency breakdown (request_time/upstream_response_time/waiting_latency) + ingress logs (upstream connection/endpoint jitter) + change events.
  - dashboard
    - multiple traffic dashboard
    - apisix logs dashboard
    - ingress logs dashboard
    - sla dashboard

**Cases**:

#### alert_20260110T120322Z (2026-01-10)
- **Evidence**: `waiting_latency↑` upstream latency normal; traffic switch already done; need to confirm blast radius/whether it reproduces
- **Decision**: `monitor` - Latency breakdown → ingress logs → change/traffic switch event verification

### 3. Incomplete Cases

**Cases with incomplete artifacts**:

#### alert_20260103T161129Z (2026-01-03)
- **Artifacts**: raw/bundle early stage
- **Status**: Incomplete (only raw/bundle raw/log)
- **Recommendation**: Suggest re-run to generate decision_framing/summary/case.json

## Pattern Summary

### High-Frequency Families

1. **Ingress global rate limit 429 + burst window mismatch** (7 cases)
   - **Complete cases**: 3 (1 escalate, 2 monitor)
   - **Partial cases**: 4 (all monitor/B_potential_risk)
   - Primary action: Verify short-window QPS vs 429 correlation and ingress rate limit config
   - Decision: Mostly `monitor`, one `escalate` case

2. **waiting_latency high but upstream normal** (1 case)
   - **Complete cases**: 1
   - Primary action: Latency breakdown analysis + ingress logs + change events
   - Decision: `monitor`

## Related Knowledge

- **Attention Rules**: 
  - `ingress_global_rate_limit_429_window_mismatch` (1s window rate limit vs 1m SLA/QPS causes burst to be 429)
  - `fp_latency_bottleneck_order` (latency troubleshooting order)
  - `core_attention_signals` (priority/signal governance)

- **Monitoring Patterns**:
  - `monitoring_fp_ingress_global_rate_limit_429_burst_window_mismatch`
  - `monitoring_fp_latency_nginx_waiting_latency_high_upstream_normal`

## Usage Notes

- These cases are historical references for pattern matching
- Do not infer current system state from historical cases
- Use for understanding common triage paths and decision patterns
- Cases marked as "Partial" may need re-processing to generate complete case.json artifacts

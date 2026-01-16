# Traffic Interface

## Purpose

Inspect traffic, ingress, and interface-level metrics.

## Scope

- Ingress traffic patterns
- API gateway metrics
- Interface-level errors
- Request rates and latencies
- Upstream/downstream relationships

## Inspection Checklist

1. Multi-cluster traffic distribution dashboard
   - Check traffic split across clusters
   - Verify interface-level routing
   - Identify traffic anomalies

2. Ingress logs and metrics
   - API gateway (APISIX) logs
   - Ingress controller metrics
   - Request/response patterns

3. Interface health
   - Status codes distribution
   - Request time percentiles
   - Upstream response times

## Principles

- Traffic metrics are symptoms, not root causes
- Check multiple interfaces if client uses multiple
- Consider time windows around alert time
- Do NOT assume all traffic is affected

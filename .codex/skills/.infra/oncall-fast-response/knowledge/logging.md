# Logging

Central logging dashboard for evidence gathering.

## Central Logging Dashboard

URL: `https://grafana-mgt.dv-api.com/d/9aBY8rWMz/logging`

Usage:
- Evidence gathering only
- No assumption of causality
- Use with extracted signals from alert text
- Filter by time window around alert time

## Principles

- Logs provide evidence, not root cause
- Use logs to validate hypotheses from other facets
- Preserve log context (timestamps, sources, levels)
- Do NOT search logs blindly without hypothesis

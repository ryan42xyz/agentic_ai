# Infra Tools

Small, read-only helpers for oncall workflows. These tools may query monitoring endpoints but never mutate production systems.

## `vm_lookup.py`

Queries VictoriaMetrics via the Prometheus-compatible API:

- Base: `https://vm-mgt-a.dv-api.com`
- Endpoint: `/prometheus/api/v1/query`

Examples:

```bash
# List candidate FP pods in a cluster (returns JSON)
python3 skills/.infra/tools/vm_lookup.py pods --cluster aws-useast1-prod-b --service fp

# Same, but prefer prod namespace in ranking (does not hide other namespaces)
python3 skills/.infra/tools/vm_lookup.py pods --cluster aws-useast1-prod-b --service fp --prefer-namespace prod

# Get namespace for a known pod
python3 skills/.infra/tools/vm_lookup.py namespace-from-pod --pod fp-deployment-957745bf6-wdrqx
```

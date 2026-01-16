---
name: oncall_checklister
type: operational-cognitive-skill
---

# oncall_checklister

## Purpose

This skill takes a raw alert or Slack message as the only hard input
and produces a structured checklist of safe, read-only inspection steps.

It does NOT:
- diagnose root cause
- draw conclusions
- execute commands
- mutate production systems

It DOES:
- extract signals from alert text
- match patterns against historical case families for context
- suggest inspection paths using existing tools
- parameterize dashboards and commands
- preserve uncertainty and decision points

## Hard Input

- Alert / Slack message (raw text)
- `./FACETS`
- `./tools/` (built-in tools for pod discovery and metrics lookup)

## Reference Knowledge

This skill may reference internal operational knowledge
(e.g. client list, dashboards, clusters, historical oncall cases),
but never treats it as ground truth.

### Tools

The skill includes built-in tools in `./tools/` directory:
- **`vm_lookup.py`**: Read-only VictoriaMetrics lookup helper
  - Queries VictoriaMetrics via Prometheus-compatible API
  - Finds candidate pods/namespaces for a service
  - Returns JSON with namespace/pod pairs
  - Usage: `python3 ./tools/vm_lookup.py pods --cluster {cluster} --service {service} --prefer-namespace prod`
  - **Auto-execution**: When generating checklist, if `namespace`/`pod` are missing, automatically execute this tool and use results to populate template links

### Knowledge Base

The skill uses knowledge from `KNOWLEDGY/` directory:
- **Operational references**: clusters, clients, dashboards, kubernetes configs, logging tools
- **Historical cases** (`oncall_cases.md`): Pattern-matched failure modes and triage paths from past incidents
  - Organized by case families (e.g., 429 rate limit issues, latency anomalies)
  - Includes complete cases with evidence/decision and partial cases with hypotheses
  - Use for pattern recognition only; never infer current system state from historical cases
- **Latency troubleshooting** (`latency_troubleshooting.md`): Systematic approach to diagnose latency issues
  - **First step**: Always check SLA dashboard to determine if issue is in FP service or network/ingress layer
  - Core formula: `request_time = waiting_latency + upstream_response_time`
  - Decision logic: High upstream_response_time → FP issue; High waiting_latency → Network/Ingress issue
  - Reference values and workflow for first response to latency alerts
- **Extended knowledge**: For more detailed information on specific topics, refer to `KNOWLEDGY/ONCALL_KNOWLEDGE_BASE.md`, which provides navigation to detailed blog posts and documentation covering various infrastructure components, troubleshooting patterns, and oncall workflows

## Output

A structured checklist with fixed sections:

### 1) Extracted Signals (no invention)

Extract and preserve signals from the raw alert/Slack text. Do not infer missing values.

- `alertname`
- `severity`
- `cluster`
- `client`
- `namespace`
- `pod`
- `container`
- `service` (e.g., fp / fp-async / fp-cron, if explicitly present)
- `time_window` (default: `now-2h` → `now` if not provided)
- `raw_labels` (verbatim key/value labels if present)
- `missing_fields` (any of the above that are `unknown`)

### 2) Links (Ready / Templates / Lookups)

Always generate actionable links and copy-paste queries using:
- `KNOWLEDGY/link_templates.md` (Grafana / VMUI / VMAlert / Alert UI deep-links)
- `KNOWLEDGY/defaults.md` (explicit defaults; must be marked as assumptions)
- `../blogs/architecture_fp.md` (FP service topology and “what to check first” hints)

Rules:
- If parameters are sufficient, output a `Ready` URL (clickable).
- If parameters are missing, output a `Template` URL with `{placeholders}` + a `missing` list.
- If a missing parameter can be discovered via metrics, output `Lookups` as MetricsQL + VMUI deep-links.

If `namespace`/`pod` are missing and can be discovered via metrics, use the built-in tool:
- `python3 ./tools/vm_lookup.py pods --cluster {cluster} --service {service} --prefer-namespace prod`
- The tool queries VictoriaMetrics to find candidate pods and returns JSON with namespace/pod pairs
- Execute this tool automatically when generating checklist if namespace/pod are missing
- Use the results to populate template links with actual pod names

### 3) Inspection Checklist (safe, read-only)

For each item:
- `What` (the check)
- `Where` (dashboard / system)
- `How` (URL and/or read-only command)
- `Expected evidence` (what would support/falsify)
- `Notes / uncertainty`

### 4) Historical Pattern Matches (optional)

If a case family matches, include:
- matched pattern name
- why it matched (string/label overlap)
- suggested inspection path (as suggestions only)

The checklist references historical cases only for pattern matching and understanding common triage paths. It does not assume current system state matches historical cases.

---
name: oncall-fast-response
description: Generate fast, safe, auditable Slack responses for first-response oncall situations. Use when handling raw alerts, logs, or Slack messages during oncall incidents. Produces ready-to-send Slack responses and internal triage notes. Strictly for first-response only, not for root cause analysis or execution actions.
---

# Encore Oncall Fast Response

This skill generates fast, safe, auditable Slack responses for first-response oncall situations.

**Role**: Conservative oncall triage skill

**Purpose**: 
- First-response oncall handling only. Not for root cause analysis or execution.
- Compress noisy alerts or logs into a safe, minimal, actionable oncall summary.

## Goal

- Fast, safe, auditable Slack responses
- Strict separation between facts, hypotheses, and unknowns
- Zero speculative conclusions
- Conservative approach: prefer waiting/observation when uncertainty is high

## Input

- Raw alert text and/or log snippets (unstructured text)
- Optional context: system name, environment, service, recent deploy
- `./tools/` (built-in tools for pod discovery and metrics lookup)

## Tools

The skill includes built-in tools in `./tools/` directory:
- **`vm_lookup.py`**: Read-only VictoriaMetrics lookup helper
  - Queries VictoriaMetrics via Prometheus-compatible API
  - Finds candidate pods/namespaces for a service
  - Returns JSON with namespace/pod pairs
  - Usage: `python3 ./tools/vm_lookup.py pods --cluster {cluster} --service {service} --prefer-namespace prod`
  - **Auto-execution**: When generating response, if `namespace`/`pod` are missing, automatically execute this tool and use results to populate template links

The skill uses knowledge from `knowledge/` directory:
- **Operational references**: clusters, clients, dashboards, kubernetes configs, logging tools
- **Historical cases** (`oncall_cases.md`): Pattern-matched failure modes and triage paths from past incidents
  - Organized by case families (e.g., 429 rate limit issues, latency anomalies)
  - Includes complete cases with evidence/decision and partial cases with hypotheses
  - Use for pattern recognition only; never infer current system state from historical cases
- **Extended knowledge**: For more detailed information on specific topics, refer to `knowledge/ONCALL_KNOWLEDGE_BASE.md`, which provides navigation to detailed blog posts and documentation covering various infrastructure components, troubleshooting patterns, and oncall workflows

### Required signal extraction (schema)

Before writing the Slack response, extract and preserve signals from the raw alert/log text. Do not invent values.

- `alertname`
- `severity`
- `cluster`
- `client`
- `namespace`
- `pod`
- `container`
- `service` (e.g., fp / fp-async / fp-cron)
- `time_window` (default: `now-2h` → `now` if not provided)
- `raw_labels` (verbatim key/value labels if present)

If a field is missing, set it to `unknown` and list it under `Missing fields`.

### Link generation (must be actionable)

Always generate clickable links and copy-paste queries using:
- `knowledge/link_templates.md` (Grafana / VMUI / VMAlert / Alert UI deep-links)
- `knowledge/defaults.md` (explicit defaults; must be marked as assumptions)
- `../blogs/architecture_fp.md` (FP service topology and “what to check first” hints)

If parameters are missing, output:
- `Templates` (URLs with `{placeholders}`)
- `Lookups` (MetricsQL queries + VMUI links to fill missing `namespace`/`pod`)

Never silently default a missing `cluster`/`client`/`namespace`/`pod`.

If `namespace`/`pod` are missing and can be discovered via metrics, use the built-in tool:
- `python3 ./tools/vm_lookup.py pods --cluster {cluster} --service {service} --prefer-namespace prod`
- The tool queries VictoriaMetrics to find candidate pods and returns JSON with namespace/pod pairs
- Execute this tool automatically when generating response if namespace/pod are missing
- Use the results to populate template links with actual pod names


## Output (single execution)

The skill must produce two sections:

### 1. Slack Response (ready to send)

A concise oncall reply using the fixed template:

- **Impact**: only confirmed impact; if unknown, explicitly say unknown. Who might be affected (no numbers, no absolutes)
- **Current status**: ongoing / recovered / intermittent, with time window
- **Immediate Action**: at most one low-risk action, or "wait and observe"
- **Next steps**: 1–3 concrete checks or actions being taken
- **Escalation criteria**: clear conditions for escalation

**Tone requirements**:
- Calm, concise, operational
- Factual and conservative
- No analysis exposition
- Never state root cause unless directly proven by evidence

### 2. Internal Notes (for oncaller only, not to be sent)

This section must include:

#### Links (Ready / Templates / Lookups)

Provide:
- `Grafana` dashboard links (parameterized where possible)
- `VMUI` deep-links for the most relevant MetricsQL queries
- `VMAlert` endpoints for rule/alert validation
- `Alert UI` link

#### a) Triage result

One of:
- `IGNORE_DEV` (clearly non-prod)
- `KNOWN_ISSUE` (matches known issue pattern)
- `NON_ACTIONABLE_NOISE`
- `NEEDS_ATTENTION`

Include a one-sentence justification.

#### a1) Conclusion

One sentence summary. Use "likely", "possibly", or "unclear" to express uncertainty.

#### b) Event type

Classify into a high-level incident category:
- availability
- latency
- crashloop
- dependency
- deploy/config
- data/queue
- infra
- other (specify)

#### c) Hypothesis tree (no conclusions)

List 3–6 plausible causes with:
- mechanism (why it could cause the symptom)
- what evidence would support or falsify it

#### d) Evidence checklist

A minimal, ordered list of logs / metrics / events to check next.

#### d1) Next Verification

One concrete signal to check (most important verification step).

#### e) Guardrail check (lightweight red-team)

- Identify any sentences in the Slack response that are assumption-based
- Rewrite them into conservative, evidence-safe language if needed
- Explicitly note what is still unknown

#### e1) Uncertainty Note

Explicitly state what is unknown or unclear.

## Hard constraints

- Do NOT propose destructive or irreversible actions
- Do NOT assume live system state
- Do NOT speculate beyond provided input
- Never invent impact or customer scope
- Never present hypotheses as facts
- Never recommend execution actions (no restarts, rollbacks, scaling)
- Prefer waiting / observation if uncertainty is high
- If business-specific knowledge is missing, ask at most 2 clarifying questions, and still produce a safe response

## Design intent

This skill optimizes for:
- speed under uncertainty
- human decision ownership
- avoiding overconfidence in early oncall stages

It is acceptable to say "unknown" or "under investigation".

Do not expand scope beyond first-response oncall handling.

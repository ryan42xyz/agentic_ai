# Defaults and Assumptions (Must Be Explicit)

These are workflow defaults to speed up first-response triage. They are not facts.

## Namespace default

If an alert looks like production (e.g., `*-prod-*`) but does not include `namespace`, you may use:
- `assumed_namespace = prod`

You must still list `namespace` under `Missing fields` and mark the value as an assumption.

## Cluster → default client (only when client missing)

If an alert does not include `client`, you may set an assumed default *only* for SLA dashboard shortcuts:

- `aws-uswest2-prod-*` → `sofi`
- `aws-useast*-prod-*` → `airasia`

For other clusters: do not assume; keep `client=unknown` and use `All` in dashboards where possible.

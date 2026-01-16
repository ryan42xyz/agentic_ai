# Link Templates (Grafana / VMUI / VMAlert / Alert UI)

These templates are for generating actionable, clickable links from extracted alert signals.
They are not facts. Do not invent missing parameters.

## Canonical bases

- Grafana: `https://grafana-mgt.dv-api.com`
- VMUI base: `https://vm-mgt-a.dv-api.com/vmui/`
- VMUI deep-link pattern: `https://vm-mgt-a.dv-api.com/vmui/#/?g0.expr={urlencoded_metricsql}`
- VMAlert rules: `https://vm-mgt-a.dv-api.com/vmalert/api/v1/rules`
- VMAlert alerts: `https://vm-mgt-a.dv-api.com/vmalert/api/v1/alerts`
- Alert UI: `https://eng.datavisor.com/#/alert`

## Grafana dashboards (parameterized)

### Multi-cluster traffic distribution
Template:
`https://grafana-mgt.dv-api.com/d/X2qhqpjSk/multi-cluster-traffic-distribution?orgId=1&var-cluster={cluster}&var-client={client_or_All}&var-interface={interface_or_All}&from={from}&to={to}`

### Pod resources
Template:
`https://grafana-mgt.dv-api.com/d/b_XlLjRMz/pod-resources?orgId=1&from={from}&to={to}&var-PromDs=prometheus-pods&var-cluster={cluster}&var-namespace={namespace}&var-pod={pod}&var-containers={container_or_All}`

### Logging
Template:
`https://grafana-mgt.dv-api.com/d/9aBY8rWMz/logging?orgId=1&from={from}&to={to}`

### YugabyteDB
Template:
`https://grafana-mgt.dv-api.com/d/1IGjQaiMk/yugabytedb?orgId=1&from={from}&to={to}&var-PromDs=vms-victoria-metrics-single-server&var-cluster={cluster}&var-dbcluster={dbcluster}&var-node={node_or_All}`

### SLA batch and realtime
Template:
`https://grafana-mgt.dv-api.com/d/p1KqfRAMk/sla-batch-and-realtime?orgId=1&var-PromDs={promds_or_default}&var-client={client}&var-sandbox_client={sandbox_client}&var-pipeline={pipeline}&var-Batch_Pipeline={batch_pipeline}`

## VMUI lookups (to fill missing namespace/pod)

Use these when alert text lacks `namespace` and/or `pod`.

### Find namespace from a known pod name
MetricsQL:
`max by (namespace) (kube_pod_info{pod="{pod}"})`

VMUI:
`https://vm-mgt-a.dv-api.com/vmui/#/?g0.expr=max%20by%20(namespace)%20(kube_pod_info%7Bpod%3D%22{urlenc_pod}%22%7D)`

### Find pods for FP services (regex hint; must be verified)
MetricsQL:
`topk(50, max by (namespace, pod) (kube_pod_info{pod=~"fp(-async|-cron)?-.*"}))`

VMUI:
`https://vm-mgt-a.dv-api.com/vmui/#/?g0.expr=topk(50%2C%20max%20by%20(namespace%2C%20pod)%20(kube_pod_info%7Bpod%3D~%22fp(-async%7C-cron)%3F-.*%22%7D))`

### Kafka consumer lag (FP / FP-Async shared group)
MetricsQL:
`kafka_consumer_lag{group="velocity.prod_a"}`

VMUI:
`https://vm-mgt-a.dv-api.com/vmui/#/?g0.expr=kafka_consumer_lag%7Bgroup%3D%22velocity.prod_a%22%7D`

## Encoding rules

- Any MetricsQL placed into VMUI deep-links must be URL-encoded.
- Grafana query parameters must be URL-encoded (e.g., `>` becomes `%3E`).

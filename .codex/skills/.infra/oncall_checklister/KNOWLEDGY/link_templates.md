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

### APISIX Logging
Template:
`https://grafana-mgt.dv-api.com/d/0lpCu9kHk/apisix-logging?orgId=1&var-cluster={cluster_without_suffix}&var-client={client}&var-search={search_or_empty}&from={from}&to={to}`

**Important**: For APISIX dashboard, the `var-cluster` parameter must use cluster name WITHOUT the `-a` or `-b` suffix. For example:
- `aws-uswest2-prod-a` → use `aws-uswest2-prod`
- `aws-useast1-prod-b` → use `aws-useast1-prod`
- Extract base cluster name by removing trailing `-a`, `-b`, etc.

### Kafka Exporter
Template:
`https://grafana-mgt.dv-api.com/d/cluster_kafkfa_exporter/kafka-exporter-for-all?orgId=1&var-PromDs=prometheus-services&var-job=kubernetes-pods&var-cluster={cluster}&var-namespace={namespace}&var-pod={kafka_exporter_pod}&var-topic={topic1}&var-topic={topic2}&...&var-consumergroup={consumer_group}&from={from}&to={to}`

**Parameters**:
- `var-PromDs` - Fixed: `prometheus-services`
- `var-job` - Fixed: `kubernetes-pods`
- `var-cluster` - Cluster name (WITH suffix, e.g., `aws-uswest2-prod-b`)
- `var-namespace` - Namespace (typically `prod`)
- `var-pod` - Kafka exporter pod name (e.g., `kafka3-exporter-788587b949-7bwxg`)
- `var-topic` - Kafka topic name (can be repeated multiple times for multiple topics)
- `var-consumergroup` - Consumer group name (optional)
- `from` / `to` - Time window

**Note**: Multiple `var-topic` parameters can be included by repeating the parameter in the URL.

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

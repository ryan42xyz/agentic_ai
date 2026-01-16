# Grafana Dashboards (Reference)

These are parameter templates, not facts. Parameters must be filled from alert signals.

## Multi-cluster Traffic Distribution
URL: `https://grafana-mgt.dv-api.com/d/X2qhqpjSk/multi-cluster-traffic-distribution`

Parameters:
- `var-cluster` - Cluster name (e.g., aws-uswest2-prod-a)
- `var-client` - Client name or "All"
- `var-interface` - Interface name or "All"
- `from` - Start timestamp (Unix ms) or relative (e.g., now-2h)
- `to` - End timestamp (Unix ms) or relative (e.g., now)

Example: `?orgId=1&var-cluster=aws-uswest2-prod&var-client=sofi&var-interface=All&from=now-2h&to=now`

## Pod Resources
URL: `https://grafana-mgt.dv-api.com/d/b_XlLjRMz/pod-resources`

Parameters:
- `var-cluster` - Cluster name
- `var-namespace` - Namespace (e.g., prod)
- `var-pod` - Pod name (e.g., fp-deployment-957745bf6-wdrqx)
- `var-containers` - Container name
- `var-PromDs` - Prometheus datasource (default: prometheus-pods)
- `from` / `to` - Time window

Example: `?orgId=1&var-cluster=aws-uswest2-prod-a&var-namespace=prod&var-pod=fp-deployment-957745bf6-wdrqx&var-containers=fp&from=now-2h&to=now`

## SLA Batch and Realtime
URL: `https://grafana-mgt.dv-api.com/d/p1KqfRAMk/sla-batch-and-realtime`

Parameters:
- `var-PromDs` - Prometheus datasource (default: vms-victoria-metrics-single-server)
- `var-client` - Client name
- `var-sandbox_client` - Sandbox client name (optional)
- `var-pipeline` - Pipeline name (optional)
- `var-Batch_Pipeline` - Batch pipeline name (e.g., prod.awsus)
- `from` / `to` - Time window

Example: `?orgId=1&var-client=sofi&var-sandbox_client=airasia&var-pipeline=&var-Batch_Pipeline=prod.awsus&from=now-6h&to=now`

## YugabyteDB
URL: `https://grafana-mgt.dv-api.com/d/1IGjQaiMk/yugabytedb`

Parameters:
- `var-PromDs` - Prometheus datasource (default: vms-victoria-metrics-single-server)
- `var-cluster` - Cluster name
- `var-dbcluster` - Database cluster name (e.g., prod-external-new-1)
- `var-node` - Node identifier or "All"
- `var-nodeInstance` - Node instance (IP:port, e.g., 172.31.35.20:7000)
- `var-serverNode` - Server node or "All"
- `var-serverNodeInstance` - Server node instance (IP:port)

Example: `?orgId=1&var-cluster=aws-uswest2-prod-a&var-dbcluster=prod-external-new-1&var-node=All&from=now-2h&to=now`

## API / Ingress Logs

### APISIX Logging
URL: `https://grafana-mgt.dv-api.com/d/0lpCu9kHk/apisix-logging`

Parameters:
- `var-cluster` - Cluster name
- `var-client` - Client name
- `var-search` - Search query (optional)
- `from` / `to` - Time window

Example: `?orgId=1&var-cluster=aws-uswest2-prod&var-client=sofi&var-search=&from=now-3h&to=now`

### Ingress Nginx Controller Debug Logs
URL: `https://grafana-mgt.dv-api.com/d/HFAlVh2Nz/debug-logs-for-ingress-nginx-controller`

Parameters:
- `var-cluster` - Cluster name
- `var-client` - Client name
- `var-interface` - Interface name or "All"
- `var-status_code` - HTTP status code (e.g., 200)
- `var-request_time_operator` - Request time operator (e.g., >)
- `var-request_time_prerequisite` - Request time threshold (e.g., 0)
- `var-upstream_response_time_operator` - Upstream response time operator
- `var-upstream_response_time_prerequisite` - Upstream response time threshold
- `from` / `to` - Time window

Example: `?orgId=1&var-cluster=aws-uswest2-prod-a&var-client=sofi&var-interface=All&var-status_code=200&var-request_time_operator=%3E&var-request_time_prerequisite=0&var-upstream_response_time_operator=%3E&var-upstream_response_time_prerequisite=0.005&from=now-2h&to=now`

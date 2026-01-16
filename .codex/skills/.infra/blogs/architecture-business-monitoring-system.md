# Monitoring System Overview

This document provides an overview of the monitoring infrastructure at DataVisor, focusing on two main components:
1. `core/src/monitorV3` - Core monitoring components
2. `multicloud` - Cloud provider specific monitoring configurations

## File Structure

### 1. Core Monitoring Components (`core/src/monitorV3`)

```
core/src/monitorV3/
├── prometheus/
│   ├── alerts/
│   │   ├── aws_alert_rules.yml
│   │   ├── base_dapp_alert_rules.yml
│   │   ├── batch_abnormal_alert_rules.yml
│   │   ├── batch_event_time_alert_rules.yml
│   │   ├── batch_sla_alert_rules.yml
│   │   ├── blackbox_alert_rules.yml
│   │   ├── cassandra_rules.yml
│   │   ├── clickhouse_rules.yml
│   │   ├── cluster_monitor_v2.yml
│   │   ├── cpu_rules.yml
│   │   ├── dash_cluster_alert_rules.yml
│   │   ├── dedge_alert_rules.yml
│   │   ├── degde_clients_rules.yml
│   │   ├── dw_rules.yml
│   │   ├── feature_platform_alert_rules.yml
│   │   ├── hdfs_alert_rules.yml
│   │   ├── k8s_system_alert_rules.yml
│   │   ├── kafka_rules.yml
│   │   ├── loki_rt_rules.yaml
│   │   ├── luigi_alert_rules.yml
│   │   ├── mysql_rules.yml
│   │   ├── nginx_postback_rules.yml
│   │   ├── nginx_rt_rules.yml
│   │   ├── node_alert_rules.yml
│   │   ├── pushgateway.yml
│   │   ├── redis_rules.yml
│   │   ├── rt_sla.rules.yml
│   │   ├── rule_engine_v3_rules.yml
│   │   ├── sink-connector.yml
│   │   ├── sml_abnormal_alert_rules.yml
│   │   ├── ssl_expiry.rules.yml
│   │   ├── system.rules.yml
│   │   ├── test_rules.yml
│   │   ├── ui_alert_rules.yml
│   │   ├── yugabytedb_rules.yml
│   │   └── zookeeper_rules.yml
│   ├── alertmanager/
│   │   ├── config.yml
│   │   └── config.yml.bak
│   ├── alert_generator.py
│   ├── alert_summary.py
│   ├── dead_nodes
│   ├── docker_run_prom.sh
│   ├── host_aliases.yaml
│   ├── hosts
│   ├── nodes.yml
│   └── prometheus.yml
├── scripts/
│   ├── generate_prometheus_alerts.py
│   ├── generate_prometheus_alerts.sh
│   ├── metrics_server.py
│   ├── monitoring_docker_service.py
│   ├── push_node_exporter_metrics.sh
│   └── reload_hosts.sh
├── jiralert/
│   ├── config/
│   │   ├── jiralert.tmpl
│   │   └── jiralert.yml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── README.md
└── es_nginx_exporter/
    ├── config.cfg
    └── README.md
```

### 2. Multicloud Monitoring Configurations (`multicloud`)

The `multicloud` directory contains monitoring configurations for different cloud providers, environments, and regions:

```
multicloud/
├── chartconfigs/
│   ├── aws/
│   │   ├── dev/
│   │   │   └── us-west-2/
│   │   │       └── monitoring/
│   │   │           ├── prometheus.yaml
│   │   │           └── alertmanager.yml
│   │   ├── prod/
│   │   │   ├── us-west-2/
│   │   │   │   └── monitoring/
│   │   │   │       └── prometheus.yaml
│   │   │   ├── eu-west-1/
│   │   │   │   └── monitoring/
│   │   │   │       └── prometheus.yaml
│   │   │   └── ap-southeast-1/
│   │   │       └── monitoring/
│   │   │           └── prometheus.yaml
│   │   └── staging/
│   │       └── us-west-2/
│   │           └── monitoring/
│   │               └── prometheus.yaml
│   └── azure/
│       └── dev/
│           └── westus2/
│               └── monitoring/
│                   └── prometheus.yaml
└── onsite/
    └── onsite-ansible-k8s/
        └── roles/
            └── k8s/
                └── templates/
                    └── cluster.yml.j2
```

## Key Components

### Prometheus Alert Rules

The system has numerous alert rules categorized by component/service:
- System alerts (system.rules.yml)
- Node-specific alerts (node_alert_rules.yml)
- AWS-specific alerts (aws_alert_rules.yml)
- Batch processing alerts (batch_*.yml)
- Database-related alerts (cassandra_rules.yml, mysql_rules.yml, redis_rules.yml)
- Kafka alerts (kafka_rules.yml)
- Kubernetes alerts (k8s_system_alert_rules.yml)
- SLA monitoring (rt_sla.rules.yml)
- and many more service-specific alert configurations

### Alert Managers

The alert manager configurations are defined in:
- `core/src/monitorV3/prometheus/alertmanager/config.yml`
- `multicloud/chartconfigs/aws/dev/us-west-2/monitoring/alertmanager.yml`

These manage alert routing, grouping, and notification delivery.

### Prometheus Configuration

The main Prometheus configuration is in `core/src/monitorV3/prometheus/prometheus.yml`, while cloud-specific configurations are in the `multicloud/chartconfigs/*/monitoring/prometheus.yaml` files.

### JIRA Integration

The system integrates with JIRA for alert management through `core/src/monitorV3/jiralert/`.

### Scripts

Various scripts in `core/src/monitorV3/scripts/` support:
- Alert generation
- Host file management
- Metric collection
- Docker service monitoring

## Cloud Provider Configurations

Different cloud providers have specific monitoring configurations:
- AWS (dev, staging, prod environments across regions)
- Azure
- On-premises deployments

## Deployment

For Kubernetes deployments, Helm charts are used with configurations stored in `multicloud/chartconfigs/`.

## Prometheus Configuration Details

Based on the retrieved Prometheus configuration, the monitoring system includes:

### Global Configuration
```yaml
global:
  scrape_interval: 30s
  scrape_timeout: 10s
  evaluation_interval: 15s
  external_labels:
    monitor: datavisor-global-monitor
```

### Alerting Configuration
```yaml
alerting:
  alertmanagers:
  - follow_redirects: true
    enable_http2: true
    scheme: http
    path_prefix: /alertmanager
    timeout: 10s
    api_version: v2
    static_configs:
    - targets:
      - prometheus-alertmanager:80
```

### Rule Files
The Prometheus instance loads numerous alert rule files, including:
```yaml
rule_files:
- /etc/config/aws_alert_rules.yml
- /etc/config/batch_abnormal_alert_rules.yml
- /etc/config/batch_event_time_alert_rules.yml
- /etc/config/batch_sla_alert_rules.yml
- /etc/config/blackbox_alert_rules.yml
- /etc/config/base_dapp_alert_rules.yml
# ... (and many more)
```

### Scrape Configurations

The system scrapes metrics from various targets:

1. **Federated Prometheus Instances** - The main Prometheus federates from cluster-specific instances across different regions:
   - aws-apsoutheast1-prod-a/b
   - aws-uswest2-prod-a/b
   - aws-uswest2-preprod-a
   - aws-cacentral1-prod-a/b
   - aws-useast1-prod-a/b
   - and many more

2. **Kubernetes Components**:
   - kubernetes-apiservers
   - kubernetes-nodes
   - kubernetes-nodes-cadvisor
   - kubernetes-service-endpoints
   - kubernetes-services
   - kubernetes-pods

3. **External Services**:
   - pushgateway instances across regions
   - blackbox_https (for HTTP endpoint monitoring)
   - blackbox_external (for external site monitoring)
   - node-exporter instances
   - cluster-monitor-v2
   - dEdge instances in different regions

4. **External Websites Monitoring**:
   - www.datavisor.com
   - www.datavisor.cn
   - Various admin portals (admin.datavisor.com, admin-eu.datavisor.com, etc.)
   - API endpoints and services

### Special Configurations

1. **HTTP Service Discovery** - Used for dynamic target discovery:
   - node-exporter-http-sd
   - promtail-metrics-http-sd
   - promtail-apisix-http-sd

2. **Blackbox Monitoring** - For HTTP(S) endpoint monitoring:
   - Monitors external websites
   - Monitors internal services
   - Validates SSL certificates

3. **Edge Monitoring**:
   - Dedicated jobs for dEdge components
   - Region-specific configurations (EU, SG)

## Grafana Dashboard Parameters

Grafana dashboards use specific parameters to filter and display metrics. Understanding these parameters is essential for troubleshooting and monitoring specific components of the system.

### Common Dashboard Parameters

1. **PromDs (Prometheus Data Source)**
   - **Meaning**: Specifies which Prometheus server instance to query for metrics
   - **Example value**: `default` (typically refers to the primary Prometheus instance)
   - **Usage**: When multiple Prometheus instances exist across different regions or environments, this parameter determines which one provides the metrics

2. **client**
   - **Meaning**: The production client/tenant whose metrics you want to view
   - **Example value**: `airasia` (the airline company using the platform)
   - **Usage**: Filters metrics to show only data related to this specific client

3. **sandbox_client**
   - **Meaning**: The test/sandbox environment client/tenant
   - **Example value**: `acorns`
   - **Usage**: Used for development, testing, or isolation purposes to view metrics for test environments

4. **pipeline**
   - **Meaning**: Specifies the real-time pipeline for which to display metrics
   - **Example value**: `prod.realtime.rtserver.awssg`
   - **Structure**: `environment.system.component.region`
     - Environment: `prod` (production)
     - System: `realtime` (real-time processing system)
     - Component: `rtserver` (real-time server)
     - Region: `awssg` (AWS Singapore region)

5. **Batch_Pipeline**
   - **Meaning**: Specifies the batch processing pipeline for which to display metrics
   - **Example value**: `prod.awssg`
   - **Structure**: `environment.region`
     - Environment: `prod` (production)
     - Region: `awssg` (AWS Singapore region)

### Example Dashboard URL

```
https://grafana-mgt.dv-api.com/d/p1KqfRAMk/sla-batch-and-realtime?var-PromDs=default&var-client=airasia&var-sandbox_client=acorns&var-pipeline=prod.realtime.rtserver.awssg&var-Batch_Pipeline=prod.awssg
```

This URL points to a dashboard that monitors:
- SLA metrics for both batch and real-time processing
- For client: AirAsia
- With sandbox client: Acorns
- Real-time pipeline: Production real-time server in AWS Singapore
- Batch pipeline: Production batch processing in AWS Singapore

## Troubleshooting Dashboard Issues

When a dashboard displays issues or alerts, use the following approach to identify and troubleshoot the affected services:

### 1. Identify the Affected Components

Use the dashboard parameters to determine:
- Which client is affected (from the `client` parameter)
- Which pipeline shows issues (from `pipeline` or `Batch_Pipeline` parameters)
- Which metrics are abnormal (CPU, memory, latency, error rates, etc.)

### 2. Locate Relevant Metrics and Alert Rules

Based on the affected components:

1. **For real-time processing issues**:
   - Check `rt_sla.rules.yml` for SLA-related alert definitions
   - Examine `nginx_rt_rules.yml` for web service performance issues
   - Look at `system.rules.yml` for infrastructure-related problems

2. **For batch processing issues**:
   - Review `batch_sla_alert_rules.yml` for SLA violations
   - Check `batch_abnormal_alert_rules.yml` for unusual behavior
   - Inspect `batch_event_time_alert_rules.yml` for timing problems

### 3. Examine Relevant Prometheus Targets

Use the monitoring architecture to find the specific services:

1. **Check federated Prometheus instances**:
   - Find the region-specific Prometheus instance (e.g., aws-apsoutheast1-prod-a)
   - Check metrics from that region that match the affected pipeline

2. **Investigate Kubernetes components**:
   - Look at pod metrics for services in the affected pipeline
   - Check node metrics for the hosts running those pods
   - Examine service endpoints for availability issues

### 4. Follow the Data Flow

For persistent issues:

1. Trace the data flow through the affected pipeline:
   - Check upstream services and dependencies
   - Verify downstream consumers
   - Look for bottlenecks in the processing chain

2. Correlate events across multiple dashboards:
   - System metrics (CPU, memory, disk)
   - Application metrics (request rate, error rate, latency)
   - Infrastructure metrics (network, Kubernetes status)

### 5. Practical Example

If investigating high latency on the SLA-batch-and-realtime dashboard for AirAsia:

1. Determine which pipeline shows the issue:
   - If real-time (prod.realtime.rtserver.awssg):
     - Check AWS Singapore Prometheus for real-time server metrics
     - Look at node metrics for the Kubernetes pods running the service
     - Investigate system resource constraints
   
   - If batch (prod.awssg):
     - Look for delayed batch jobs
     - Check resource consumption during batch processing
     - Verify data pipeline integrity

2. Look for related alerts in the monitoring system:
   - Check if any alerts from `rt_sla.rules.yml` or `batch_sla_alert_rules.yml` are firing
   - Verify if system-level alerts correlate with the issue

## Further Reference

For more information on monitoring and alerting, refer to the internal wiki page: https://datavisor.atlassian.net/wiki/spaces/ENG/pages/1066172545/Monitoring+and+Alerting+on+Kubernetes 
# 监控系统概览

本文档提供了DataVisor监控基础设施的概述，主要关注两个核心组件：
1. `core/src/monitorV3` - 核心监控组件
2. `multicloud` - 云服务提供商特定的监控配置

## 文件结构

### 1. 核心监控组件 (`core/src/monitorV3`)

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

### 2. 多云监控配置 (`multicloud`)

`multicloud` 目录包含了不同云服务提供商、环境和区域的监控配置：

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

## 关键组件

### Prometheus 告警规则

系统包含多种按组件/服务分类的告警规则：
- 系统告警 (system.rules.yml)
- 节点特定告警 (node_alert_rules.yml)
- AWS特定告警 (aws_alert_rules.yml)
- 批处理告警 (batch_*.yml)
- 数据库相关告警 (cassandra_rules.yml, mysql_rules.yml, redis_rules.yml)
- Kafka告警 (kafka_rules.yml)
- Kubernetes告警 (k8s_system_alert_rules.yml)
- SLA监控 (rt_sla.rules.yml)
- 以及更多服务特定的告警配置

### 告警管理器

告警管理器配置定义在：
- `core/src/monitorV3/prometheus/alertmanager/config.yml`
- `multicloud/chartconfigs/aws/dev/us-west-2/monitoring/alertmanager.yml`

这些配置管理告警的路由、分组和通知传递。

### Prometheus 配置

主要的Prometheus配置在 `core/src/monitorV3/prometheus/prometheus.yml`，而云特定的配置则位于 `multicloud/chartconfigs/*/monitoring/prometheus.yaml` 文件中。

### JIRA 集成

系统通过 `core/src/monitorV3/jiralert/` 与JIRA进行告警管理集成。

### 脚本

`core/src/monitorV3/scripts/` 中的各种脚本支持：
- 告警生成
- 主机文件管理
- 指标收集
- Docker服务监控

## 云服务提供商配置

不同的云服务提供商有特定的监控配置：
- AWS（开发、测试、生产环境，跨区域）
- Azure
- 本地部署

## 部署

对于Kubernetes部署，使用Helm charts，配置存储在 `multicloud/chartconfigs/` 中。

## Prometheus 配置详情

基于获取的Prometheus配置，监控系统包括：

### 全局配置
```yaml
global:
  scrape_interval: 30s
  scrape_timeout: 10s
  evaluation_interval: 15s
  external_labels:
    monitor: datavisor-global-monitor
```

### 告警配置
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

### 规则文件
Prometheus实例加载了多个告警规则文件，包括：
```yaml
rule_files:
- /etc/config/aws_alert_rules.yml
- /etc/config/batch_abnormal_alert_rules.yml
- /etc/config/batch_event_time_alert_rules.yml
- /etc/config/batch_sla_alert_rules.yml
- /etc/config/blackbox_alert_rules.yml
- /etc/config/base_dapp_alert_rules.yml
# ... (还有更多)
```

### 采集配置

系统从各种目标采集指标：

1. **联邦Prometheus实例** - 主Prometheus从不同区域的集群特定实例联合数据：
   - aws-apsoutheast1-prod-a/b
   - aws-uswest2-prod-a/b
   - aws-uswest2-preprod-a
   - aws-cacentral1-prod-a/b
   - aws-useast1-prod-a/b
   - 以及更多

2. **Kubernetes组件**：
   - kubernetes-apiservers
   - kubernetes-nodes
   - kubernetes-nodes-cadvisor
   - kubernetes-service-endpoints
   - kubernetes-services
   - kubernetes-pods

3. **外部服务**：
   - 各区域的pushgateway实例
   - blackbox_https（用于HTTP端点监控）
   - blackbox_external（用于外部网站监控）
   - node-exporter实例
   - cluster-monitor-v2
   - 不同区域的dEdge实例

4. **外部网站监控**：
   - www.datavisor.com
   - www.datavisor.cn
   - 各种管理门户（admin.datavisor.com, admin-eu.datavisor.com等）
   - API端点和服务

### 特殊配置

1. **HTTP服务发现** - 用于动态目标发现：
   - node-exporter-http-sd
   - promtail-metrics-http-sd
   - promtail-apisix-http-sd

2. **Blackbox监控** - 用于HTTP(S)端点监控：
   - 监控外部网站
   - 监控内部服务
   - 验证SSL证书

3. **Edge监控**：
   - 专用于dEdge组件的作业
   - 区域特定配置（欧盟，新加坡）

## Grafana 仪表盘参数

Grafana仪表盘使用特定参数来筛选和显示指标。理解这些参数对于故障排除和监控系统的特定组件至关重要。

### 常用仪表盘参数

1. **PromDs (Prometheus 数据源)**
   - **含义**：指定要查询指标的Prometheus服务器实例
   - **示例值**：`default`（通常指主Prometheus实例）
   - **用途**：当多个Prometheus实例存在于不同区域或环境时，此参数确定哪个实例提供指标

2. **client**
   - **含义**：要查看其指标的生产客户端/租户
   - **示例值**：`airasia`（使用平台的航空公司）
   - **用途**：筛选指标，仅显示与特定客户相关的数据

3. **sandbox_client**
   - **含义**：测试/沙盒环境客户端/租户
   - **示例值**：`acorns`
   - **用途**：用于开发、测试或隔离目的，查看测试环境的指标

4. **pipeline**
   - **含义**：指定要显示指标的实时管道
   - **示例值**：`prod.realtime.rtserver.awssg`
   - **结构**：`环境.系统.组件.区域`
     - 环境：`prod`（生产）
     - 系统：`realtime`（实时处理系统）
     - 组件：`rtserver`（实时服务器）
     - 区域：`awssg`（AWS新加坡区域）

5. **Batch_Pipeline**
   - **含义**：指定要显示指标的批处理管道
   - **示例值**：`prod.awssg`
   - **结构**：`环境.区域`
     - 环境：`prod`（生产）
     - 区域：`awssg`（AWS新加坡区域）

### 仪表盘URL示例

```
https://grafana-mgt.dv-api.com/d/p1KqfRAMk/sla-batch-and-realtime?var-PromDs=default&var-client=airasia&var-sandbox_client=acorns&var-pipeline=prod.realtime.rtserver.awssg&var-Batch_Pipeline=prod.awssg
```

此URL指向监控以下内容的仪表盘：
- 批处理和实时处理的SLA指标
- 客户端：亚洲航空
- 沙盒客户端：Acorns
- 实时管道：AWS新加坡的生产实时服务器
- 批处理管道：AWS新加坡的生产批处理

## 仪表盘问题排查

当仪表盘显示问题或告警时，使用以下方法来识别和排查受影响的服务：

### 1. 识别受影响的组件

使用仪表盘参数确定：
- 哪个客户受到影响（从`client`参数）
- 哪个管道显示问题（从`pipeline`或`Batch_Pipeline`参数）
- 哪些指标异常（CPU、内存、延迟、错误率等）

### 2. 定位相关指标和告警规则

基于受影响的组件：

1. **对于实时处理问题**：
   - 查看`rt_sla.rules.yml`了解SLA相关的告警定义
   - 检查`nginx_rt_rules.yml`了解Web服务性能问题
   - 查看`system.rules.yml`了解基础设施相关问题

2. **对于批处理问题**：
   - 检查`batch_sla_alert_rules.yml`了解SLA违规情况
   - 查看`batch_abnormal_alert_rules.yml`了解异常行为
   - 检查`batch_event_time_alert_rules.yml`了解计时问题

### 3. 检查相关Prometheus目标

使用监控架构查找特定服务：

1. **检查联邦Prometheus实例**：
   - 找到区域特定的Prometheus实例（例如aws-apsoutheast1-prod-a）
   - 检查来自该区域匹配受影响管道的指标

2. **调查Kubernetes组件**：
   - 查看受影响管道中服务的Pod指标
   - 检查运行这些Pod的主机节点指标
   - 检查服务端点的可用性问题

### 4. 跟踪数据流

对于持续存在的问题：

1. 跟踪受影响管道的数据流：
   - 检查上游服务和依赖项
   - 验证下游消费者
   - 查找处理链中的瓶颈

2. 关联多个仪表盘的事件：
   - 系统指标（CPU、内存、磁盘）
   - 应用程序指标（请求率、错误率、延迟）
   - 基础设施指标（网络、Kubernetes状态）

### 5. 实际示例

如果调查亚洲航空的SLA-batch-and-realtime仪表盘上的高延迟问题：

1. 确定哪个管道显示问题：
   - 如果是实时管道(prod.realtime.rtserver.awssg)：
     - 检查AWS新加坡的Prometheus获取实时服务器指标
     - 查看运行该服务的Kubernetes Pod的节点指标
     - 调查系统资源限制
   
   - 如果是批处理管道(prod.awssg)：
     - 查找延迟的批处理作业
     - 检查批处理期间的资源消耗
     - 验证数据管道完整性

2. 查找监控系统中的相关告警：
   - 检查`rt_sla.rules.yml`或`batch_sla_alert_rules.yml`中的告警是否触发
   - 验证系统级别告警是否与问题相关

## 更多参考

有关监控和告警的更多信息，请参阅内部Wiki页面：https://datavisor.atlassian.net/wiki/spaces/ENG/pages/1066172545/Monitoring+and+Alerting+on+Kubernetes 
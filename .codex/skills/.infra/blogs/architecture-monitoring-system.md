```mermaid
flowchart TD
    subgraph "Metrics Collection"
        NE[prometheus-node-exporter] -->|Node metrics| PS
        KSM[kube-state-metrics] -->|K8s object metrics| PS
        MS[metrics-server] -->|Pod/Node resource metrics| K["Kubernetes API"]
        CERT[x509-certificate-exporter] -->|Certificate metrics| PS
        AWS[aws-access-logs] -->|AWS logs| PS
    end

    subgraph "Metrics Processing"
        PS[prometheus-server] -->|Store time-series data| PA
        PG[prometheus-pushgateway] -->|Push-based metrics| PS
        VMA[victoria-metrics-agent] -->|Forward metrics| VM["Victoria Metrics DB\n(external)"]
    end

    subgraph "Log Collection"
        PT[promtail] -->|Collect logs| L["Loki\n(not visible in pod list)"]
    end

    subgraph "Visualization & Alerting"
        PA["Prometheus Alertmanager\n(part of prometheus-server)"] -->|Alerts| AM["Alert Receivers\n(Email, Slack, etc.)"]
        PS -->|Query metrics| G["Grafana\n(not visible in pod list)"]
        L -->|Query logs| G
        VM -->|Query metrics| G
    end

    A[Applications] -->|Push metrics| PG
    K -->|Metrics API| G
    
    style NE fill:#f9d67a,stroke:#333,stroke-width:2px
    style PS fill:#e97451,stroke:#333,stroke-width:2px
    style PG fill:#e97451,stroke:#333,stroke-width:2px
    style KSM fill:#f9d67a,stroke:#333,stroke-width:2px
    style PT fill:#7eb5e6,stroke:#333,stroke-width:2px
    style L fill:#7eb5e6,stroke:#333,stroke-width:2px
    style G fill:#8fd694,stroke:#333,stroke-width:2px
    style VMA fill:#c792ea,stroke:#333,stroke-width:2px
    style VM fill:#c792ea,stroke:#333,stroke-width:2px
    style MS fill:#f9d67a,stroke:#333,stroke-width:2px
    style CERT fill:#f9d67a,stroke:#333,stroke-width:2px
    style AWS fill:#f9d67a,stroke:#333,stroke-width:2px
```

## Kubernetes Monitoring Pipeline Explanation

This chart illustrates the metrics and monitoring pipeline in your Kubernetes cluster. Here's how it works:

### Metrics Collection
- **prometheus-node-exporter**: Deployed as a DaemonSet (one per node), collects hardware and OS metrics from each Kubernetes node
- **kube-state-metrics**: Collects metrics about the state of Kubernetes objects (deployments, pods, etc.)
- **metrics-server**: Provides resource metrics (CPU/memory) for Kubernetes autoscaling
- **x509-certificate-exporter**: Monitors certificate expiration dates
- **aws-access-logs**: Collects AWS-related logs and metrics

### Metrics Processing
- **prometheus-server**: The central time-series database that scrapes and stores metrics from exporters
- **prometheus-pushgateway**: Allows batch jobs or services to push their metrics to Prometheus
- **victoria-metrics-agent**: An agent that forwards metrics to Victoria Metrics (appears to be an external time-series database)

### Log Collection
- **promtail**: Collects logs from pods/nodes and forwards them to Loki (Loki pod isn't visible in your list but is likely present in another namespace or deployed externally)

### Visualization & Alerting
- **Prometheus Alertmanager**: Part of the prometheus-server deployment, handles alerting based on metrics
- **Grafana**: The visualization layer where dashboards display metrics and logs (likely deployed in another namespace or externally)

This pipeline provides comprehensive monitoring of your Kubernetes infrastructure, applications, and services through metrics collection, log aggregation, visualization, and alerting. 

```mermaid
graph TB
    subgraph "Management Cluster (US East 1)"
        MGT[MGT Prometheus]
        ALERT[Alertmanager]
        GRAF[Grafana]
        MGT -->|alerts| ALERT
        MGT -->|metrics| GRAF
    end

    subgraph "Production Clusters"
        subgraph "AF South 1 Production A"
            PA[Prometheus A]
            PA_KSM[kube-state-metrics]
            PA_NODE[Node Exporter]
            PA_POD[Pod Metrics]
            PA_KSM --> PA
            PA_NODE --> PA
            PA_POD --> PA
        end

        subgraph "AF South 1 Production B"
            PB_KSM[kube-state-metrics]
            PB[Prometheus B]
            PB_NODE[Node Exporter]
            PB_POD[Pod Metrics]
            PB_KSM --> PB
            PB_NODE --> PB
            PB_POD --> PB
        end
    end

    PA -->|federate| MGT
    PB -->|federate| MGT

    classDef mgmt fill:#f9f,stroke:#333,stroke-width:4px;
    classDef prod fill:#bbf,stroke:#333,stroke-width:2px;
    class MGT,ALERT,GRAF mgmt;
    class PA,PB prod;

%% 连接说明
    style MGT fill:#f96,stroke:#333,stroke-width:4px;
    
    %% 添加说明
    note1["/federate endpoint
    抓取间隔: 1m
    超时: 1m"]
    note2["收集指标:
    - kubernetes-service-endpoints
    - kubernetes-nodes-cadvisor
    - kubernetes-pods
    - yugabytedb-.*"]
    
    note1 -.-> PA
    note2 -.-> MGT
```
```mermaid
graph TB
    subgraph "Node"
        NE[Node Exporter]
        CD[cAdvisor]
        KT[kubelet]
    end

    subgraph "Cluster Level"
        KSM[kube-state-metrics]
        MS[metrics-server]
    end

    subgraph "Application Level"
        APP[Applications]
        PE[Pod Exporter]
    end

    subgraph "Prometheus"
        PS[Prometheus Server]
    end

    NE -->|node metrics<br>9100/tcp| PS
    CD -->|container metrics<br>4194/tcp| PS
    KSM -->|cluster metrics<br>8080/tcp| PS
    MS -->|resource metrics<br>443/tcp| KT
    APP -->|custom metrics<br>custom port| PS
    PE -->|pod metrics| PS

    classDef default fill:#f9f,stroke:#333,stroke-width:2px;
```
系统级（Node Exporter）
容器级（cAdvisor）
集群级（kube-state-metrics）
资源使用（metrics-server）
应用级（自定义指标）

```
Node Exporter (9100) ----\
cAdvisor (4194) ---------> Prometheus -----> Alertmanager
kube-state-metrics (8080) /        \
Application metrics ------/         \-----> Grafana
```
```mermaid
sequenceDiagram
    participant P as Prometheus
    participant K as Kubernetes API
    participant Pod as Pod/Service
    
    P->>K: 1. 查询 Pod/Service 列表
    K-->>P: 2. 返回资源列表及其元数据(包含注解)
    P->>P: 3. 解析注解配置
    P->>Pod: 4. 根据注解配置抓取 metrics
    Pod-->>P: 5. 返回 metrics 数据
```
```mermaid

graph TD
    A[Prometheus] -->|1. API 请求| B[Kubernetes API]
    B -->|2. 返回 Pod 列表| A
    A -->|3. 解析注解| C[处理 relabel_configs]
    C -->|4. 生成目标| D[创建抓取任务]
    D -->|5. 执行抓取| E[Pod Metrics Endpoint]
    E -->|6. 返回 metrics| A

```
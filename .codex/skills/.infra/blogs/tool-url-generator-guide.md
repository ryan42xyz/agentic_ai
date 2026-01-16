# URL Generator 使用指南

## 📋 功能概述

URL Generator 是一个智能监控 Dashboard URL 生成工具，用于快速生成各种 Grafana 监控面板和日志查询链接。它通过自动发现集群、模糊匹配和智能缓存，大大简化了日常运维中访问监控面板的流程。

### 核心功能

1. **自动集群/客户端发现**：从 VictoriaMetrics API 自动获取所有可用的集群和客户端列表
2. **智能模糊匹配**：支持模糊匹配和正则表达式匹配集群/客户端名称
3. **多类型 URL 生成**：一键生成 9 种不同类型的监控 Dashboard URL
4. **本地缓存机制**：24 小时有效期的本地缓存，提高响应速度
5. **Web 交互界面**：友好的 Web UI，支持输入提示和一键复制

### 技术架构

- **数据源**：VictoriaMetrics API (`https://vm-mgt-a.dv-api.com`)
- **缓存目录**：`.cache/` (clusters.json, clients.json)
- **缓存有效期**：24 小时
- **匹配算法**：精确匹配 → 大小写不敏感匹配 → 正则匹配 → 模糊匹配（difflib）

---

## 🎯 支持的监控 Dashboard 类型

### 1. MirrorMaker2 Dashboard (Kafka 镜像监控)

**用途**：监控 Kafka MirrorMaker2 的运行状态、延迟和主题同步情况

**URL 模板**：
```
https://grafana-mgt.dv-api.com/d/-N7cUPZNk/mirrorlag-v2
  ?orgId=1
  &var-cluster={cluster}
  &var-namespace=prod
  &var-source=cluster_a
  &var-target=cluster_b
  &from=now-5m
  &to=now
```

**参数说明**：
- `var-cluster`: 集群名称（自动替换）
- `var-namespace`: 命名空间（固定为 prod）
- `var-source`: 源集群（cluster_a）
- `var-target`: 目标集群（cluster_b）
- `from/to`: 时间范围（最近 5 分钟）

**支持的主题**（部分）：
- `api_command`, `api_command-group1`
- `backfillevent.{client}` (bdc, brighthorizons, cuoc, nasa, navan, sofi)
- `casemanagement-alertreview-prod.{client}`
- `casemanagement-postback-prod.{client}`
- `entity_alerts-prod.{client}`
- `extds.{client}`
- `prod_fp_velocity.{client}`

**使用场景**：
- 检查 Kafka 集群间的数据同步状态
- 监控 MirrorMaker lag 是否正常
- 定位主题同步延迟问题

---

### 2. Kafka Exporter Dashboard (Kafka 主题监控)

**用途**：监控 Kafka 所有主题的生产和消费情况

**URL 模板**：
```
https://grafana-mgt.dv-api.com/d/cluster_kafkfa_exporter/kafka-exporter-for-all
  ?orgId=1
  &var-PromDs=vms-victoria-metrics-single-server
  &var-job=kubernetes-pods
  &var-cluster={cluster}
  &var-namespace=prod
  &from=now-15m
  &to=now
```

**参数说明**：
- `var-PromDs`: Prometheus 数据源
- `var-job`: Kubernetes Pods 任务
- `var-cluster`: 集群名称
- `var-namespace`: 命名空间
- `from/to`: 时间范围（最近 15 分钟）

**使用场景**：
- 查看所有 Kafka 主题的消息吞吐量
- 监控消费者组的消费速率
- 检查主题分区分布和副本状态

---

### 3. Loki Error Logs (错误日志查询)

**用途**：在 Loki 中快速搜索 ERROR 级别的日志

**URL 模板**：
```
https://grafana-mgt.dv-api.com/explore
  ?orgId=1
  &left={"datasource":"Loki","queries":[{"refId":"A","expr":"{cluster=\"{cluster}\",namespace=\"prod\",pod=~\"fp-.*deployment.*\"} |~\"ERROR\" "}],"range":{"from":"now-15m","to":"now"}}
```

**查询参数**：
- `cluster`: 集群名称
- `namespace`: 命名空间（prod）
- `pod`: Pod 名称模式（fp-.*deployment.*）
- 日志级别：ERROR

**使用场景**：
- 快速定位 Feature Platform 的错误日志
- 调试线上问题
- 分析错误日志模式

---

### 4. SLA Dashboard (批处理和实时 SLA 监控)

**用途**：监控批处理任务和实时服务的 SLA 指标

**URL 模板**：
```
https://grafana-mgt.dv-api.com/d/p1KqfRAMk/sla-batch-and-realtime
  ?orgId=1
  &var-PromDs=vms-victoria-metrics-single-server
  &var-client={client}
  &var-sandbox_client=
  &var-pipeline=prod.realtime.rtserver.awsus
  &var-Batch_Pipeline=prod.awsus
  &from=now-15m
  &to=now
```

**参数说明**：
- `var-client`: 客户端名称（自动替换）
- `var-pipeline`: 实时处理管道
- `var-Batch_Pipeline`: 批处理管道
- `from/to`: 时间范围

**监控指标**：
- 批处理任务完成时间
- 实时服务响应延迟
- SLA 达标率
- P50/P90/P99 延迟

**使用场景**：
- 检查客户端 SLA 是否达标
- 分析批处理任务性能
- 实时服务延迟监控

---

### 5. Feature Platform Metrics (特征平台指标)

**用途**：监控 Feature Platform 的性能指标和资源使用情况

**URL 模板**：
```
https://grafana-mgt.dv-api.com/d/EP_yHg7Gk/feature-platform-metrics
  ?orgId=1
  &var-PromDs=vms-victoria-metrics-single-server
  &var-cluster={cluster}
  &var-namespace=prod
  &var-pod=fp-deployment-845489447f-t66t8
  &var-tenant={client}
```

**参数说明**：
- `var-cluster`: 集群名称
- `var-namespace`: 命名空间
- `var-pod`: FP Pod 名称
- `var-tenant`: 租户/客户端名称

**监控指标**：
- 特征计算 QPS
- 特征计算延迟
- 缓存命中率
- 内存使用情况

**使用场景**：
- 监控特征平台性能
- 分析特征计算瓶颈
- 优化特征缓存策略

---

### 6. Pod Resources Dashboard (Pod 资源监控)

**用途**：监控 Kubernetes Pod 的 CPU、内存、网络等资源使用情况

**URL 模板**：
```
https://grafana-mgt.dv-api.com/d/b_XlLjRMz/pod-resources
  ?orgId=1
  &var-PromDs=vms-victoria-metrics-single-server
  &var-cluster={cluster}
  &var-namespace=prod
  &var-pod=fp-deployment-845489447f-4xjff
  &var-containers=fp
```

**参数说明**：
- `var-cluster`: 集群名称
- `var-namespace`: 命名空间
- `var-pod`: Pod 名称
- `var-containers`: 容器名称

**监控指标**：
- CPU 使用率和限制
- 内存使用率和限制
- 网络流量（ingress/egress）
- 磁盘 I/O

**使用场景**：
- 检查 Pod 资源使用情况
- 定位 CPU/内存瓶颈
- 优化 Pod 资源配置

---

### 7. Multi-Cluster Traffic Distribution (多集群流量分布)

**用途**：比较不同集群间的流量分布情况

**URL 模板**：
```
https://grafana-mgt.dv-api.com/d/X2qhqpjSk/multi-cluster-traffic-distribution
  ?orgId=1
  &var-cluster={cluster_base}
  &var-client=All
  &var-interface=All
```

**参数说明**：
- `var-cluster`: 集群基础名称（自动去除 -a/-b 后缀）
- `var-client`: 客户端筛选（默认 All）
- `var-interface`: 接口筛选（默认 All）

**监控指标**：
- 集群间流量对比
- 客户端流量分布
- API 接口调用统计
- 流量切换监控

**使用场景**：
- 多集群流量切换时监控
- 检查流量分配是否均衡
- 验证 A/B 集群流量比例

---

### 8. YugabyteDB Dashboard (YugabyteDB 节点监控)

**用途**：监控 YugabyteDB 数据库节点的运行状态

**URL 模板**：
```
https://grafana-mgt.dv-api.com/d/oOSnZg7mz/yugabytedb-node-dashboard
  ?orgId=1
```

**监控指标**：
- YB-TServer 节点状态
- YB-Master 节点状态
- 读写 QPS 和延迟
- 磁盘和内存使用

**使用场景**：
- 监控 YugabyteDB 集群健康状态
- 分析数据库性能瓶颈
- 检查节点负载均衡

---

### 9. APISIX Logging Dashboard (APISIX 日志监控)

**用途**：监控 APISIX API 网关的请求日志和性能指标

**URL 模板**：
```
https://grafana-mgt.dv-api.com/d/0lpCu9kHk/apisix-logging
  ?orgId=1
```

**监控指标**：
- API 请求 QPS
- HTTP 状态码分布
- 响应延迟统计
- 错误率监控

**使用场景**：
- 监控 API 网关流量
- 分析 API 调用模式
- 检查网关错误率

---

## 🚀 使用方法

### Web UI 使用

1. **访问页面**：打开 `http://localhost:8000/urls`

2. **输入集群和客户端名称**：
   - 集群名称示例：`uswest2-prod-b`, `euwest1-prod-b`, `apsoutheast1`
   - 客户端名称示例：`syncbank`, `nasa`, `sofi`, `bdc`

3. **选择是否包含主题**：
   - 勾选"Include Kafka Topics"可以在 MirrorMaker URL 中包含所有常用主题

4. **生成 URL**：点击"Generate URLs"按钮

5. **复制使用**：在生成的 URL 列表中点击"Copy URL"按钮复制链接

### API 使用

#### 1. 生成 URL

```bash
curl -X POST "http://localhost:8000/urls/api/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "cluster": "uswest2-prod-b",
    "client": "syncbank",
    "include_topics": true
  }'
```

**响应示例**：
```json
{
  "success": true,
  "input_cluster": "uswest2-prod-b",
  "matched_cluster": "aws-uswest2-prod-b",
  "cluster_confidence": 0.9,
  "input_client": "syncbank",
  "matched_client": "syncbank",
  "client_confidence": 1.0,
  "urls": {
    "mirror_maker": {
      "name": "MirrorMaker2 Dashboard",
      "description": "Kafka MirrorMaker2 monitoring with topic parameters",
      "url": "https://grafana-mgt.dv-api.com/d/-N7cUPZNk/mirrorlag-v2?...",
      "topics_included": 120
    },
    "kafka_exporter": {
      "name": "Kafka Exporter Dashboard",
      "description": "Kafka exporter monitoring for all topics",
      "url": "https://grafana-mgt.dv-api.com/d/cluster_kafkfa_exporter/kafka-exporter-for-all?..."
    }
    // ... 其他 URL
  },
  "timestamp": "2025-12-28T10:00:00.000000"
}
```

#### 2. 获取所有可用集群

```bash
curl "http://localhost:8000/urls/api/clusters"
```

**响应示例**：
```json
{
  "success": true,
  "clusters": [
    "aws-afsouth1-prod-b",
    "aws-apsoutheast1-prod-b",
    "aws-cacentral1-prod-b",
    "aws-cawest1-prod-b",
    "aws-euwest1-prod-b",
    "aws-euwest2-prod-b",
    "aws-useast1-prod-b",
    "aws-uswest2-prod-b",
    "gcp-uswest1-prod-a",
    "gcp-uswest1-trial-a"
  ],
  "count": 10,
  "message": "Found 10 available clusters"
}
```

#### 3. 获取所有可用客户端

```bash
curl "http://localhost:8000/urls/api/clients"
```

**响应示例**：
```json
{
  "success": true,
  "clusters": [
    "baselane", "bdc", "brighthorizons", "cuoc", "moonpay", 
    "nasa", "navan", "pefcu", "qaautogroup1test", "qaautotest",
    "rippling", "snapprod", "sofi", "syncbank", "taskrabbit"
  ],
  "count": 15,
  "message": "Found 15 available clients"
}
```

#### 4. 刷新缓存

```bash
curl -X POST "http://localhost:8000/urls/api/refresh-cache"
```

---

## 📊 集群和客户端列表

### 支持的集群（10+）

| 区域 | 集群名称 | 说明 |
|------|---------|------|
| 🇺🇸 US West 2 | `aws-uswest2-prod-b` | 美国西部主要集群 |
| 🇺🇸 US East 1 | `aws-useast1-prod-b` | 美国东部主要集群 |
| 🇪🇺 EU West 1 | `aws-euwest1-prod-b` | 欧洲西部集群 |
| 🇪🇺 EU West 2 | `aws-euwest2-prod-b` | 欧洲西部集群 2 |
| 🇸🇬 Asia Pacific | `aws-apsoutheast1-prod-b` | 亚太新加坡集群 |
| 🇿🇦 Africa South | `aws-afsouth1-prod-b` | 非洲南部集群 |
| 🇨🇦 Canada Central | `aws-cacentral1-prod-b` | 加拿大中部集群 |
| 🇨🇦 Canada West | `aws-cawest1-prod-b` | 加拿大西部集群 |
| ☁️ GCP US West | `gcp-uswest1-prod-a` | GCP 美国西部集群 |
| ☁️ GCP Trial | `gcp-uswest1-trial-a` | GCP 试用集群 |

### 常用客户端（15+）

| 客户端名称 | 类型 | 说明 |
|-----------|------|------|
| `syncbank` | 金融 | Sync Bank |
| `bdc` | 金融 | BDC Bank |
| `sofi` | 金融 | SoFi |
| `nasa` | 金融 | NASA Federal Credit Union |
| `pefcu` | 金融 | PenFed Credit Union |
| `brighthorizons` | 教育 | Bright Horizons |
| `cuoc` | 金融 | CUOC |
| `navan` | 旅行 | Navan (formerly TripActions) |
| `rippling` | HR | Rippling |
| `taskrabbit` | 共享经济 | TaskRabbit |
| `moonpay` | 加密货币 | MoonPay |
| `baselane` | 房地产 | Baselane |
| `snapprod` | 金融 | Snap Finance |
| `qaautotest` | 测试 | QA 自动化测试 |
| `qaautogroup1test` | 测试 | QA 自动化组测试 |

---

## 🔧 高级功能

### 1. 模糊匹配算法

URL Generator 支持多种匹配方式，按以下优先级匹配：

1. **精确匹配**（Confidence: 1.0）
   ```
   输入: "aws-uswest2-prod-b" → 匹配: "aws-uswest2-prod-b"
   ```

2. **大小写不敏感匹配**（Confidence: 1.0）
   ```
   输入: "AWS-USWEST2-PROD-B" → 匹配: "aws-uswest2-prod-b"
   ```

3. **正则表达式匹配**（Confidence: 0.9）
   ```
   输入: "uswest2.*prod" → 匹配: "aws-uswest2-prod-b"
   ```

4. **模糊匹配**（Confidence: 0.6-0.9）
   ```
   输入: "uswest2" → 匹配: "aws-uswest2-prod-b"
   输入: "euwest" → 匹配: "aws-euwest1-prod-b"
   ```

### 2. 缓存机制

**缓存文件位置**：
- 集群缓存：`.cache/clusters.json`
- 客户端缓存：`.cache/clients.json`

**缓存策略**：
- 有效期：24 小时
- 自动刷新：缓存过期后自动从 VictoriaMetrics API 更新
- 手动刷新：通过 API 端点手动触发刷新

**缓存文件示例**：
```json
{
  "clusters": [
    "aws-uswest2-prod-b",
    "aws-useast1-prod-b",
    ...
  ],
  "timestamp": "2025-12-28T10:00:00.000000",
  "count": 10
}
```

### 3. Fallback 机制

当 VictoriaMetrics API 不可用时，自动使用预定义的 fallback 列表：

**Fallback 集群列表**：
```python
[
    "aws-uswest2-prod-b",
    "aws-useast1-prod-b", 
    "aws-euwest1-prod-b",
    "aws-euwest2-prod-b",
    "aws-apsoutheast1-prod-b",
    "aws-afsouth1-prod-b",
    "aws-cacentral1-prod-b",
    "aws-cawest1-prod-b",
    "gcp-uswest1-prod-a",
    "gcp-uswest1-trial-a"
]
```

**Fallback 客户端列表**：
```python
[
    "syncbank", "bdc", "brighthorizons", "cuoc", "nasa", 
    "navan", "sofi", "pefcu", "qaautogroup1test", "qaautotest", 
    "rippling", "snapprod", "taskrabbit", "moonpay", "baselane"
]
```

---

## 🎓 使用场景示例

### 场景 1：检查 SyncBank 在 US West 2 集群的 SLA

```bash
# 生成 URL
curl -X POST "http://localhost:8000/urls/api/generate" \
  -H "Content-Type: application/json" \
  -d '{"cluster": "uswest2", "client": "syncbank"}'
```

访问响应中的 `sla_dashboard` URL 即可查看 SyncBank 的 SLA 监控。

### 场景 2：排查 Feature Platform ERROR 日志

1. 生成 Loki Error Logs URL
2. 访问 URL 自动打开 Grafana Loki Explore
3. 查看最近 15 分钟的 ERROR 日志
4. 使用 Loki 查询语法进一步过滤

### 场景 3：监控 Kafka MirrorMaker 延迟

1. 生成 MirrorMaker Dashboard URL（包含所有主题）
2. 检查每个主题的 lag 情况
3. 定位延迟最大的主题
4. 分析主题同步瓶颈

### 场景 4：多集群流量切换监控

```bash
# 生成 Multi-Cluster Traffic URL
curl -X POST "http://localhost:8000/urls/api/generate" \
  -H "Content-Type: application/json" \
  -d '{"cluster": "uswest2-prod", "client": "All"}'
```

访问 `multi_cluster_traffic` URL 监控集群间流量分布。

---

## ⚙️ 配置说明

### VictoriaMetrics API 配置

```python
vm_api_base = "https://vm-mgt-a.dv-api.com"
vm_query_endpoint = "/api/v1/query"
```

**集群发现查询**：
```promql
count by (kubernetes_cluster) (kube_pod_info)
```

**客户端发现查询**：
```promql
count by(client) ({__name__=~"(controller:Health_UpTime|record:loki_kubernetes_monitoring_request_1m_qps_ingress_nginx|prod_job_finish_time)"})
```

### URL 模板自定义

URL 模板定义在 `url_generator.py` 的 `url_templates` 字典中，可以根据需要添加或修改：

```python
self.url_templates = {
    "custom_dashboard": {
        "name": "自定义 Dashboard",
        "description": "自定义监控面板",
        "template": "https://grafana-mgt.dv-api.com/d/YOUR_DASHBOARD_ID/your-dashboard?orgId=1&var-cluster={cluster}&var-client={client}"
    }
}
```

---

## 🐛 故障排查

### 问题 1：无法获取集群列表

**症状**：API 返回错误或使用 fallback 列表

**可能原因**：
- VictoriaMetrics API 不可达
- 网络连接问题
- API 查询超时（30秒）

**解决方案**：
1. 检查网络连接：`ping vm-mgt-a.dv-api.com`
2. 检查 VictoriaMetrics 服务状态
3. 手动刷新缓存：`POST /urls/api/refresh-cache`

### 问题 2：模糊匹配结果不准确

**症状**：匹配到错误的集群或客户端

**可能原因**：
- 输入名称太模糊
- 多个匹配结果得分相近

**解决方案**：
1. 使用更具体的名称（如 `uswest2-prod-b` 而不是 `uswest`）
2. 使用正则表达式精确匹配
3. 检查 `cluster_confidence` 和 `client_confidence` 得分

### 问题 3：生成的 URL 无法访问

**症状**：打开 URL 显示 404 或权限错误

**可能原因**：
- Dashboard ID 已更改
- 缺少 Grafana 访问权限
- 参数格式错误

**解决方案**：
1. 检查 Grafana 访问权限
2. 验证 Dashboard ID 是否正确
3. 检查 URL 参数格式

---

## 📈 性能优化建议

1. **启用缓存**：确保 `.cache/` 目录可写，利用 24 小时缓存
2. **批量查询**：一次生成所有需要的 URL，避免重复请求
3. **预加载集群列表**：在页面加载时提前获取集群和客户端列表
4. **使用正则匹配**：对于已知模式，使用正则表达式可以提高匹配准确性

---

## 🔗 相关链接

- **Grafana 主站**：https://grafana-mgt.dv-api.com
- **VictoriaMetrics API**：https://vm-mgt-a.dv-api.com
- **Luigi Debug Helper**：http://localhost:8000/luigi-debug
- **Jenkins Manager**：http://localhost:8000/jenkins

---

## 📝 更新日志

### v1.0.0 (2025-12-28)
- ✅ 初始版本发布
- ✅ 支持 9 种监控 Dashboard URL 生成
- ✅ 集成 VictoriaMetrics API 自动发现
- ✅ 实现模糊匹配和正则匹配
- ✅ 添加本地缓存机制（24小时）
- ✅ 提供 Web UI 和 REST API 接口
- ✅ 支持 10+ 集群和 15+ 客户端
- ✅ Fallback 机制确保高可用性

---

## 💡 最佳实践

1. **定期刷新缓存**：每周手动刷新一次缓存，确保集群列表最新
2. **使用精确名称**：尽量使用完整的集群和客户端名称，提高匹配准确性
3. **保存常用 URL**：将常用的监控 URL 添加到浏览器书签
4. **结合使用多个 Dashboard**：综合使用多个 Dashboard 进行全面监控
5. **自定义时间范围**：根据需要调整 URL 中的 `from` 和 `to` 参数

---

*最后更新：2025-12-28*
*作者：Infra Oncall Team*


# dCluster API 接口文档

## 概述

dCluster 是一个集群管理服务应用，提供 RESTful API 来管理 Spark 和 Flink 集群的生命周期。本文档详细描述了所有可用的 API 端点、请求参数和响应格式。

## 基础信息

- **基础URL**: `http://dcluster-host:8080`
- **内容类型**: `application/json`
- **认证**: 根据部署环境配置

### 实际环境URL示例

- **US East 1 生产环境 (Cluster A)**: `http://dcluster-useast1-prod-a-prod.dv-api.com`
- **US East 1 生产环境 (Cluster B)**: `http://dcluster-useast1-prod-b-prod.dv-api.com`
- **US West 2 生产环境**: `http://dcluster-uswest2-prod-a-prod.dv-api.com`

### 监控和日志查看

- **Grafana 日志面板**: [https://grafana-mgt.dv-api.com/d/9aBY8rWMz/logging](https://grafana-mgt.dv-api.com/d/9aBY8rWMz/logging)
  - 可以通过调整URL参数查看不同集群、命名空间、Pod的日志
  - 示例参数：
    - `var-cluster`: 集群名称 (如 `aws-useast1-prod-a`)
    - `var-namespace`: 命名空间 (如 `prod`)
    - `var-container`: 容器名称 (如 `dcluster-deployment`)
    - `var-level`: 日志级别 (如 `stdout`, `stderr`)
    - `var-search`: 搜索关键词 (如集群ID `10603`)

## API 端点分类

### 1. 集群管理 (ClusterController)

#### 1.1 服务状态检查

**GET** `/`

获取服务状态信息。

**响应示例:**
```json
"Cluster Service"
```

#### 1.2 创建 Spark 集群

**POST** `/launch/spark/cluster`

创建 Spark 集群（旧版本）。

**请求体:**
```json
{
  "tenant": "my-team",
  "workers": 3,
  "workerCpu": "2",
  "workerMemory": "8Gi",
  "masterCpu": "1", 
  "masterMemory": "4Gi",
  "type": "spark",
  "extraConfigs": "{\"spark.executor.instances\": 2}"
}
```

**响应:** 返回集群ID (int)

---

**POST** `/v2/launch/spark/cluster`

创建 Spark3 集群（新版本）。

**请求体 (ClusterEntity):**
```json
{
  "tenant": "my-team",
  "workers": 3,
  "workerCpu": "2",
  "workerMemory": "8Gi",
  "masterCpu": "1",
  "masterMemory": "4Gi", 
  "type": "spark3",
  "useOnDemandMaster": true,
  "extraConfigs": "{\"spark.executor.instances\": 2}",
  "launchNewNode": true,
  "launchDynamicDisk": false,
  "useExternalNamespace": false,
  "clusterSuffix": ""
}
```

**ClusterEntity 字段说明:**
- `tenant`: 租户名称
- `workers`: 工作节点数量
- `workerCpu`: 工作节点CPU配置
- `workerMemory`: 工作节点内存配置
- `masterCpu`: 主节点CPU配置
- `masterMemory`: 主节点内存配置
- `type`: 集群类型 (spark3, flink)
- `useOnDemandMaster`: 是否使用按需主节点
- `extraConfigs`: 额外配置 (JSON字符串)
- `launchNewNode`: 是否启动新节点
- `launchDynamicDisk`: 是否启用动态磁盘
- `useExternalNamespace`: 是否使用外部命名空间
- `clusterSuffix`: 集群名称后缀

**响应:** 返回集群ID (int)

#### 1.3 创建 Flink 集群

**POST** `/launch/flink/cluster`

创建 Flink 集群。

**请求体 (ClusterEntity):**
```json
{
  "tenant": "my-team",
  "workers": 2,
  "workerCpu": "2",
  "workerMemory": "8Gi",
  "masterCpu": "1",
  "masterMemory": "4Gi",
  "type": "flink",
  "useOnDemandMaster": true,
  "launchNewNode": true
}
```

**响应:** 返回集群ID (Integer)

#### 1.4 获取集群状态

**GET** `/status/cluster/{clusterId}`

获取 Flink 集群状态。

**路径参数:**
- `clusterId`: 集群ID (int)

**响应:** 返回集群状态信息 (String)

**实际示例:**
```bash
# 查看集群 10603 的状态
curl --location --request GET 'http://dcluster-useast1-prod-a-prod.dv-api.com/cluster/status/cluster/10603'

# 同时可以在 Grafana 查看该集群的日志
# https://grafana-mgt.dv-api.com/d/9aBY8rWMz/logging?orgId=1&var-cluster=aws-useast1-prod-a&var-namespace=prod&var-container=dcluster-deployment&var-search=10603
```

---

**GET** `/status/spark/cluster/{clusterId}`

获取 Spark 集群状态。

**路径参数:**
- `clusterId`: 集群ID (int)

**响应:** 返回集群状态信息 (String)

---

**GET** `/status/cluster/name/{clusterName}`

通过集群名称获取 Flink 集群状态。

**路径参数:**
- `clusterName`: 集群名称 (String)

**响应:** 返回集群状态信息 (String)

#### 1.5 终止集群

**DELETE** `/terminate/spark/{clusterId}`

终止 Spark 集群。

**路径参数:**
- `clusterId`: 集群ID (int)

**响应:** 返回操作结果 (String)

---

**GET** `/terminate/flink/{clusterId}`

终止 Flink 集群。

**路径参数:**
- `clusterId`: 集群ID (int)

**响应:** 返回操作结果 (String)

#### 1.6 实例日志记录

**POST** `/log/instance/{instanceId}`

记录实例信息。

**路径参数:**
- `instanceId`: 实例ID (String)

**请求体:** JSON格式的实例信息

**响应:** 无返回值

#### 1.7 服务状态检查

**GET** `/`

获取服务状态信息。

**响应:** 返回服务状态字符串

### 2. 作业管理 (JobController)

#### 2.1 提交作业

**POST** `/job/submit`

提交新作业。

**请求体 (JobsTableEntity):**
```json
{
  "client": "my-team",
  "module": "data-processing",
  "clusterName": "spark-dev-myteam-123",
  "extraCmd": "{\"spark.executor.instances\": 2}",
  "driverMemGb": 4,
  "workerMemGb": 8,
  "numWorkers": 3,
  "emailRecipients": "team@example.com",
  "pipelineVersion": "1.0.0",
  "pipelineConfig": "config.json",
  "codeVersion": "v1.0",
  "jobType": "spark",
  "moduleType": "spark",
  "keepAlive": false,
  "useLongLivingCluster": false,
  "useExternalCluster": false,
  "useExternalNamespace": false,
  "workerCpu": 2,
  "workerDaemonMemory": "2g",
  "masterMemory": "4g",
  "dockerImageName": "dv-spark:2.2.0"
}
```

**JobsTableEntity 主要字段说明:**
- `client`: 客户端名称
- `module`: 模块名称
- `clusterName`: 关联的集群名称
- `extraCmd`: 额外命令配置
- `driverMemGb`: 驱动程序内存 (GB)
- `workerMemGb`: 工作节点内存 (GB)
- `numWorkers`: 工作节点数量
- `emailRecipients`: 邮件接收者
- `pipelineVersion`: 流水线版本
- `pipelineConfig`: 流水线配置
- `codeVersion`: 代码版本
- `jobType`: 作业类型
- `moduleType`: 模块类型
- `keepAlive`: 是否保持活跃
- `useLongLivingCluster`: 是否使用长期存活集群
- `useExternalCluster`: 是否使用外部集群
- `useExternalNamespace`: 是否使用外部命名空间

**响应:** 返回作业提交结果 (JSON格式)

#### 2.2 终止作业

**POST** `/job/terminate/{jobId}`

终止指定作业。

**路径参数:**
- `jobId`: 作业ID (int)

**响应:** 返回操作结果 (String)

#### 2.3 获取作业状态

**GET** `/job/status/{jobId}`

获取作业状态。

**路径参数:**
- `jobId`: 作业ID (int)

**响应:** 返回作业状态 (String)

#### 2.4 获取作业信息

**GET** `/job/info/{jobId}`

获取作业详细信息。

**路径参数:**
- `jobId`: 作业ID (int)

**响应:** 返回作业详细信息 (JSON格式)

#### 2.5 列出作业

**GET** `/job/list`

根据状态列出作业。

**查询参数:**
- `status`: 作业状态 (String)

**响应:** 返回作业列表 (List<JobsTableEntity>)

#### 2.6 检查重复作业

**GET** `/job/check/{client}/{module}`

检查是否存在重复作业。

**路径参数:**
- `client`: 客户端名称 (String)
- `module`: 模块名称 (String)

**响应:** 返回是否存在重复作业 (boolean)

#### 2.7 停止客户端作业

**POST** `/job/stopped/{client}/{module}`

停止指定客户端的作业。

**路径参数:**
- `client`: 客户端名称 (String)
- `module`: 模块名称 (String)

**响应:** 返回操作结果 (boolean)

#### 2.8 检查客户端监控状态

**GET** `/job/monitor/{client}`

检查客户端作业监控是否启用。

**路径参数:**
- `client`: 客户端名称 (String)

**响应:** 返回监控状态 (boolean)

#### 2.9 触发长时间运行作业告警

**GET** `/job/monitor/alert`

触发长时间运行的 Spark 作业告警。

**响应:** 返回操作结果 (String)

#### 2.10 触发集群检查

**GET** `/cluster/check`

触发集群检查定时任务。

**响应:** 返回操作结果 (String)

### 3. 节点管理 (NodeController)

#### 3.1 启动 Kubernetes 节点

**POST** `/node/launch`

启动 Kubernetes 节点。

**请求体:**
```json
{
  "nodeCount": 3,
  "instanceType": "m5.large",
  "region": "us-west-2"
}
```

**响应:** 无返回值

#### 3.2 销毁 Kubernetes 节点

**POST** `/node/destroy`

销毁 Kubernetes 节点。

**请求体:**
```json
{
  "nodeIds": ["i-1234567890abcdef0"],
  "region": "us-west-2"
}
```

**响应:** 无返回值

#### 3.3 触发节点清理任务

**GET** `/node/croncleanup`

触发节点清理定时任务。

**响应:** 无返回值

### 4. 云平台管理 (CloudController)

#### 4.1 获取 EC2 实例类型信息

**GET** `/ec2-info`

获取可用的 EC2 实例类型信息。

**响应:** 返回实例类型集合 (Set<String>)

#### 4.2 获取 EC2 实例列表信息

**GET** `/ec2-list-info`

获取 EC2 实例列表详细信息。

**响应:** 返回操作结果 (int)

## 错误处理

### HTTP 状态码

- `200 OK`: 请求成功
- `400 Bad Request`: 请求参数错误
- `404 Not Found`: 资源不存在
- `500 Internal Server Error`: 服务器内部错误

### 错误响应格式

```json
{
  "error": "错误描述",
  "timestamp": "2024-01-01T00:00:00Z",
  "path": "/api/endpoint"
}
```

## 使用示例

### 创建 Spark 集群示例

```bash
# 创建 Spark3 集群 (v2 API)
curl -X POST http://dcluster-host:8080/v2/launch/spark/cluster \
  -H "Content-Type: application/json" \
  -d '{
    "tenant": "my-team",
    "workers": 3,
    "workerCpu": "2",
    "workerMemory": "8Gi",
    "masterCpu": "1",
    "masterMemory": "4Gi",
    "type": "spark3",
    "useOnDemandMaster": true,
    "extraConfigs": "{\"spark.executor.instances\": 2}",
    "launchNewNode": true,
    "launchDynamicDisk": false,
    "useExternalNamespace": false
  }'

# 创建 Flink 集群
curl -X POST http://dcluster-host:8080/launch/flink/cluster \
  -H "Content-Type: application/json" \
  -d '{
    "tenant": "my-team",
    "workers": 2,
    "workerCpu": "2",
    "workerMemory": "8Gi",
    "masterCpu": "1",
    "masterMemory": "4Gi",
    "type": "flink",
    "useOnDemandMaster": true,
    "launchNewNode": true
  }'
```

### 提交作业示例

```bash
curl -X POST http://dcluster-host:8080/job/submit \
  -H "Content-Type: application/json" \
  -d '{
    "client": "my-team",
    "module": "data-processing",
    "clusterName": "spark-dev-myteam-123",
    "extraCmd": "{\"spark.executor.instances\": 2}",
    "driverMemGb": 4,
    "workerMemGb": 8,
    "numWorkers": 3,
    "emailRecipients": "team@example.com",
    "pipelineVersion": "1.0.0",
    "pipelineConfig": "config.json",
    "codeVersion": "v1.0",
    "jobType": "spark",
    "moduleType": "spark",
    "keepAlive": false,
    "useLongLivingCluster": false,
    "useExternalCluster": false,
    "useExternalNamespace": false
  }'
```

### 获取集群状态示例

```bash
# 获取 Spark 集群状态
curl http://dcluster-host:8080/status/spark/cluster/123

# 获取 Flink 集群状态
curl http://dcluster-host:8080/status/cluster/456

# 通过名称获取集群状态
curl http://dcluster-host:8080/status/cluster/name/spark-dev-myteam-123

# 实际生产环境示例 - 查看集群 10603 的状态
curl --location --request GET 'http://dcluster-useast1-prod-a-prod.dv-api.com/cluster/status/cluster/10603'

# 配合 Grafana 日志查看集群运行情况
# https://grafana-mgt.dv-api.com/d/9aBY8rWMz/logging?orgId=1&var-cluster=aws-useast1-prod-a&var-namespace=prod&var-container=dcluster-deployment&var-search=10603
```

### 终止集群示例

```bash
# 终止 Spark 集群
curl -X DELETE http://dcluster-host:8080/terminate/spark/123

# 终止 Flink 集群
curl http://dcluster-host:8080/terminate/flink/456
```

### 作业管理示例

```bash
# 获取作业状态
curl http://dcluster-host:8080/job/status/789

# 获取作业详细信息
curl http://dcluster-host:8080/job/info/789

# 终止作业
curl -X POST http://dcluster-host:8080/job/terminate/789

# 终止特定作业 (实际示例)
curl -X POST http://dcluster-useast1-prod-b-prod.dv-api.com/cluster/job/terminate/570232

# 列出特定状态的作业
curl "http://dcluster-host:8080/job/list?status=running"

# 检查重复作业
curl http://dcluster-host:8080/job/check/my-team/data-processing

# 停止客户端作业
curl -X POST http://dcluster-host:8080/job/stopped/my-team/data-processing
```

### 节点管理示例

```bash
# 启动 Kubernetes 节点
curl -X POST http://dcluster-host:8080/node/launch \
  -H "Content-Type: application/json" \
  -d '{
    "nodeCount": 3,
    "instanceType": "m5.large",
    "region": "us-west-2"
  }'

# 销毁 Kubernetes 节点
curl -X POST http://dcluster-host:8080/node/destroy \
  -H "Content-Type: application/json" \
  -d '{
    "nodeIds": ["i-1234567890abcdef0"],
    "region": "us-west-2"
  }'

# 触发节点清理任务
curl http://dcluster-host:8080/node/croncleanup
```

### 云平台管理示例

```bash
# 获取 EC2 实例类型信息
curl http://dcluster-host:8080/ec2-info

# 获取 EC2 实例列表信息
curl http://dcluster-host:8080/ec2-list-info
```

### 监控和告警示例

```bash
# 触发长时间运行作业告警
curl http://dcluster-host:8080/job/monitor/alert

# 触发集群检查
curl http://dcluster-host:8080/cluster/check

# 检查客户端监控状态
curl http://dcluster-host:8080/job/monitor/my-team
```

## 故障排查和监控

### 使用 Grafana 查看 dCluster 日志

当需要排查集群或作业问题时，可以通过 Grafana 日志面板查看详细日志：

**Grafana 日志查看链接模板:**
```
https://grafana-mgt.dv-api.com/d/9aBY8rWMz/logging?orgId=1&var-PromDs=prometheus-pods&var-cluster={CLUSTER}&var-namespace={NAMESPACE}&var-pod=All&var-container=dcluster-deployment&var-level=stdout&var-level=stderr&var-search={SEARCH_KEYWORD}
```

**参数说明:**
- `var-cluster`: 集群名称
  - 示例: `aws-useast1-prod-a`, `aws-uswest2-prod-a`
- `var-namespace`: 命名空间
  - 通常为: `prod`, `preprod`, `dev`
- `var-container`: 容器名称
  - dCluster 服务: `dcluster-deployment`
- `var-level`: 日志级别
  - `stdout`: 标准输出
  - `stderr`: 标准错误
- `var-search`: 搜索关键词
  - 可以使用集群ID、作业ID、租户名称等

**实际使用示例:**
```bash
# 1. 首先通过 API 查询集群状态
curl --location --request GET 'http://dcluster-useast1-prod-a-prod.dv-api.com/cluster/status/cluster/10603'

# 2. 如果状态异常，通过 Grafana 查看详细日志
# 打开以下链接查看集群 10603 的日志:
# https://grafana-mgt.dv-api.com/d/9aBY8rWMz/logging?orgId=1&var-PromDs=prometheus-pods&var-cluster=aws-useast1-prod-a&var-namespace=prod&var-pod=All&var-container=dcluster-deployment&var-level=stdout&var-level=stderr&var-search=10603

# 3. 在日志中搜索错误信息，定位问题根源
```

### 常见问题排查步骤

1. **集群创建失败**
   - 检查资源配置是否合理 (CPU、内存、节点数)
   - 通过 Grafana 搜索集群ID查看创建日志
   - 检查是否有权限问题或资源配额限制

2. **作业提交失败**
   - 确认集群状态是否正常 (调用 `/status/cluster/{clusterId}`)
   - 检查作业配置参数是否正确
   - 查看 dCluster 日志中的错误信息

3. **集群终止失败**
   - 确认集群ID是否正确
   - 检查是否有正在运行的作业
   - 通过日志查看终止过程中的错误

4. **长时间运行的作业**
   - 使用 `/job/monitor/alert` 查看长时间运行的作业
   - 检查作业配置是否合理
   - 考虑是否需要优化资源配置

## 注意事项

1. **集群命名规则**: 系统会自动生成唯一的集群名称，格式通常为 `{type}-{env}-{tenant}-{timestamp}`
2. **资源限制**: 请根据实际需求合理配置 CPU 和内存资源
3. **权限要求**: 某些操作可能需要特定的权限配置
4. **监控告警**: 长时间运行的作业会自动触发告警机制
5. **资源清理**: 系统会定期清理未使用的节点和集群资源
6. **日志查看**: 遇到问题时，优先通过 Grafana 日志面板查看详细日志进行排查

## API 端点总结

### 集群管理 (ClusterController) - 8个端点
1. `GET /` - 服务状态检查
2. `POST /launch/spark/cluster` - 创建Spark集群(旧版本)
3. `POST /v2/launch/spark/cluster` - 创建Spark3集群(新版本)
4. `POST /launch/flink/cluster` - 创建Flink集群
5. `GET /status/cluster/{clusterId}` - 获取Flink集群状态
6. `GET /status/spark/cluster/{clusterId}` - 获取Spark集群状态
7. `GET /status/cluster/name/{clusterName}` - 通过名称获取集群状态
8. `DELETE /terminate/spark/{clusterId}` - 终止Spark集群
9. `GET /terminate/flink/{clusterId}` - 终止Flink集群
10. `POST /log/instance/{instanceId}` - 记录实例信息

### 作业管理 (JobController) - 10个端点
1. `POST /job/submit` - 提交作业
2. `POST /job/terminate/{jobId}` - 终止作业
3. `GET /job/status/{jobId}` - 获取作业状态
4. `GET /job/info/{jobId}` - 获取作业信息
5. `GET /job/list` - 列出作业
6. `GET /job/check/{client}/{module}` - 检查重复作业
7. `POST /job/stopped/{client}/{module}` - 停止客户端作业
8. `GET /job/monitor/{client}` - 检查客户端监控状态
9. `GET /job/monitor/alert` - 触发长时间运行作业告警
10. `GET /cluster/check` - 触发集群检查

### 节点管理 (NodeController) - 3个端点
1. `POST /node/launch` - 启动Kubernetes节点
2. `POST /node/destroy` - 销毁Kubernetes节点
3. `GET /node/croncleanup` - 触发节点清理任务

### 云平台管理 (CloudController) - 2个端点
1. `GET /ec2-info` - 获取EC2实例类型信息
2. `GET /ec2-list-info` - 获取EC2实例列表信息

**总计: 25个API端点**

## 版本信息

- **API 版本**: v1
- **支持集群类型**: Spark, Spark3, Flink
- **支持云平台**: AWS, GCP/GKE, 本地部署
- **最后更新**: 2024年1月 
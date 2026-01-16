# 系统架构：请求路由流程分析

## 概述

本文档详细说明了从客户端（Client）到 Kubernetes Pod 中的服务（Service）的完整请求路由流程，包括经过的各个组件和架构层次。

## 快速链接

### 📝 Nginx Ingress 日志监控

**Grafana Dashboard**: [Debug Logs for Ingress Nginx Controller](https://grafana-mgt.dv-api.com/d/HFAlVh2Nz/debug-logs-for-ingress-nginx-controller?orgId=1&var-cluster=aws-uswest2-prod-a&var-client=sofi&var-interface=update&var-status_code=200&var-request_time_operator=%3E&var-request_time_prerequisite=0&var-upstream_response_time_operator=%3E&var-upstream_response_time_prerequisite=0&from=now-50m&to=now-30m)

**可自定义的参数**:
- `var-cluster`: 集群名称（如 aws-uswest2-prod-a, aws-useast1-prod-b）
- `var-client`: 客户端名称（如 sofi, syncbank, nasa）
- `var-interface`: API 接口名称（如 update, query）
- `var-status_code`: HTTP 状态码（如 200, 500）
- `from` / `to`: 时间范围（如 now-50m, now-30m）

**使用场景**:
- 调试 API 请求延迟问题
- 查看特定客户端的请求日志
- 分析 HTTP 错误码分布
- 监控 Nginx Ingress Controller 性能

---

## 系统架构图

### 简化流程图

```
👥 Client
   ↓
🔀 API Gateway (apigateway, alb, imperva, apisix)
   ↓
🖥️ Cluster-A / Cluster-B
   ↓
🎯 Service (SVC)
   ↓
📦 FP Pod / FP-GROUP Pod
```

### 详细架构图 (Mermaid)

```mermaid
flowchart TD
    Client[👥 Client] --> APIGateway{🔀 API Gateway Layer}
    
    APIGateway --> |Route 1| APIGW[apigateway]
    APIGateway --> |Route 2| ALB[alb]
    APIGateway --> |Route 3| APISIX[apisix]
    APIGateway --> |Route 4| Imperva[imperva]
    
    APIGW --> ClusterA[Cluster-A]
    ALB --> ClusterA
    APISIX --> ClusterA
    Imperva --> ClusterA
    
    APIGW --> ClusterB[Cluster-B]
    ALB --> ClusterB
    APISIX --> ClusterB
    Imperva --> ClusterB
    
    subgraph ClusterA[🖥️ Cluster-A]
        direction TB
        SVC_A[🎯 Service SVC] --> FP_A[📦 FP Pod]
        SVC_A --> FPG_A[📦 FP-GROUP Pod]
    end
    
    subgraph ClusterB[🖥️ Cluster-B]
        direction TB
        SVC_B[🎯 Service SVC] --> FP_B[📦 FP Pod]
        SVC_B --> FPG_B[📦 FP-GROUP Pod]
    end
    
    style Client fill:#ffd700,stroke:#333,stroke-width:2px
    style APIGateway fill:#ff6b6b,stroke:#333,stroke-width:2px
    style APIGW fill:#4ecdc4,stroke:#333
    style ALB fill:#4ecdc4,stroke:#333
    style APISIX fill:#c92a2a,stroke:#333
    style Imperva fill:#1971c2,stroke:#333
    style ClusterA fill:#e9ecef,stroke:#667eea,stroke-width:3px
    style ClusterB fill:#e9ecef,stroke:#667eea,stroke-width:3px
    style SVC_A fill:#a5d8ff,stroke:#333
    style SVC_B fill:#a5d8ff,stroke:#333
    style FP_A fill:#b2f2bb,stroke:#333
    style FPG_A fill:#b2f2bb,stroke:#333
    style FP_B fill:#b2f2bb,stroke:#333
    style FPG_B fill:#b2f2bb,stroke:#333
```

---

## 详细组件说明

### 1️⃣ Client Layer (客户端层)

**功能**: 发起 API 请求的外部客户端

**特点**:
- 可以是 Web 应用、移动应用或其他后端服务
- 通过 HTTPS 协议发送请求
- 携带认证信息（API Key, JWT Token 等）

**示例**:
```bash
# 客户端发起的 API 请求示例
curl -X POST https://api.example.com/v1/fraud-detection \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"transaction_id": "12345"}'
```

---

### 2️⃣ API Gateway Layer (API 网关层)

**功能**: 统一入口点，处理路由、认证、限流等

#### 2.1 apigateway
`https://ca-central-1.console.aws.amazon.com/ec2/home?region=ca-central-1#Instances:tag:CostCenter=prod:aws-cacentral1-prod:apisix;v=3;$case=tags:true%5C,client:false;$regex=tags:false%5C,client:false`

```
/ack
/dection
/update
```
**职责**:
- API 路由和版本管理
- 请求认证和授权
- 请求/响应转换
- API 使用量统计和监控

**特点**:
- 支持多种认证机制（API Key, OAuth, JWT）
- 提供 API 版本控制
- 支持请求限流和配额管理

#### 2.2 alb (Application Load Balancer)

**职责**:
- Layer 7 负载均衡
- SSL/TLS 终止
- 基于路径的路由
- 健康检查

**特点**:
- AWS 托管服务，高可用性
- 支持 WebSocket 和 HTTP/2
- 集成 AWS Certificate Manager (ACM)
- 支持多种目标类型（EC2, IP, Lambda）

**示例路由规则**:
```yaml
# ALB 路由规则示例
/api/v1/* -> Cluster-A
/api/v2/* -> Cluster-B
/internal/* -> Private Cluster
```

#### 2.3 apisix

**职责**:
- 高性能 API 网关
- 动态路由配置
- 插件化架构
- 服务网格集成

**特点**:
- 基于 Nginx + Lua 实现
- 支持热更新配置
- 丰富的插件生态（认证、限流、日志、监控）
- 支持服务发现和负载均衡

**配置示例**:
```yaml
# APISIX 路由配置示例
routes:
  - uri: /api/fraud-detection
    upstream:
      type: roundrobin
      nodes:
        - cluster-a-svc:8080
        - cluster-b-svc:8080
    plugins:
      limit-req:
        rate: 100
        burst: 50
      prometheus:
        prefer_name: true
```

#### 2.4 imperva

**职责**:
- Web 应用防火墙 (WAF)
- DDoS 防护
- Bot 管理
- API 安全

**特点**:
- 企业级安全防护
- 自动威胁检测和阻断
- 合规性支持（PCI DSS, GDPR）
- 全球 CDN 加速

---

### 3️⃣ Cluster Layer (集群层)

#### Cluster-A / Cluster-B

**功能**: Kubernetes 集群，提供高可用性和地理分布

**特点**:
- **高可用性**: 多集群部署，单集群故障不影响服务
- **地理分布**: 不同地区的集群，降低延迟
- **负载均衡**: 流量在多个集群间分配
- **独立扩展**: 每个集群可独立扩展资源

**集群类型**:
- **Cluster-A**: 通常为主集群，处理主要流量
- **Cluster-B**: 备用集群或特定区域集群

**示例集群配置**:
```yaml
# Cluster-A (US West 2)
cluster_name: aws-uswest2-prod-a
region: us-west-2
nodes: 50
node_type: t3.xlarge
capacity:
  cpu: 200 cores
  memory: 800 GB

# Cluster-B (US West 2)
cluster_name: aws-uswest2-prod-b
region: us-west-2
nodes: 30
node_type: t3.large
capacity:
  cpu: 120 cores
  memory: 480 GB
```

---

### 4️⃣ Service Layer (服务层)

#### Service (SVC)

**功能**: Kubernetes Service，提供服务发现和负载均衡

**特点**:
- **服务发现**: 自动发现和注册 Pod
- **负载均衡**: 在多个 Pod 之间分配流量
- **健康检查**: 只将流量发送到健康的 Pod
- **DNS 解析**: 提供稳定的 DNS 名称

**Service 类型**:
- **ClusterIP**: 集群内部访问（默认）
- **NodePort**: 通过节点 IP 和端口访问
- **LoadBalancer**: 云厂商负载均衡器
- **Headless**: 直接访问 Pod IP

**示例 Service 配置**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: fp-service
  namespace: prod
spec:
  type: ClusterIP
  selector:
    app: fp-deployment
  ports:
    - name: http
      port: 8080
      targetPort: 8080
      protocol: TCP
  sessionAffinity: ClientIP  # 会话保持
```

**负载均衡算法**:
- **RoundRobin**: 轮询（默认）
- **SessionAffinity**: 基于客户端 IP 的会话保持
- **Least Connections**: 最少连接数（需要 Service Mesh）

---

### 5️⃣ Pod Layer (容器层)

#### 📦 FP Pod (Feature Platform Pod)

**功能**: 单租户特征平台服务

**特点**:
- **单租户处理**: 每个 Pod 处理单个客户端的请求
- **资源隔离**: 租户之间完全隔离
- **独立扩展**: 可以根据单个客户端的负载独立扩展
- **专用配置**: 每个租户可以有独立的配置

**使用场景**:
- 实时欺诈检测 API
- 单笔交易风险评分
- 实时特征提取

**示例 Pod 配置**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fp-deployment
  namespace: prod
spec:
  replicas: 10
  selector:
    matchLabels:
      app: fp-deployment
  template:
    metadata:
      labels:
        app: fp-deployment
        tier: frontend
        client: sofi
    spec:
      containers:
        - name: fp
          image: datavisor/feature-platform:v2.5.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: 2
              memory: 4Gi
            limits:
              cpu: 4
              memory: 8Gi
          env:
            - name: CLIENT_NAME
              value: "sofi"
            - name: MODE
              value: "single-tenant"
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 5
```

#### 📦 FP-GROUP Pod (Feature Platform Group Pod)

**功能**: 多租户批处理服务

**特点**:
- **多租户处理**: 单个 Pod 可以处理多个客户端的批处理请求
- **资源共享**: 多个租户共享 Pod 资源
- **批处理优化**: 针对大规模数据处理优化
- **成本效益**: 资源利用率更高，成本更低

**使用场景**:
- 批量特征计算
- 历史数据回填
- 定时任务处理
- 模型训练数据准备

**示例 Pod 配置**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fp-group-deployment
  namespace: prod
spec:
  replicas: 5
  selector:
    matchLabels:
      app: fp-group-deployment
  template:
    metadata:
      labels:
        app: fp-group-deployment
        tier: backend
    spec:
      containers:
        - name: fp-group
          image: datavisor/feature-platform:v2.5.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: 4
              memory: 16Gi
            limits:
              cpu: 8
              memory: 32Gi
          env:
            - name: MODE
              value: "multi-tenant"
            - name: BATCH_SIZE
              value: "10000"
            - name: MAX_CLIENTS
              value: "20"
          volumeMounts:
            - name: data-volume
              mountPath: /data
      volumes:
        - name: data-volume
          persistentVolumeClaim:
            claimName: fp-group-data-pvc
```

---

## 完整请求流程详解

### 1. 客户端发起请求

```bash
# 客户端发送 POST 请求到 API
POST https://api.datavisor.com/v1/fraud-detection
Headers:
  Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  Content-Type: application/json
  X-Client-ID: sofi
  X-Request-ID: 550e8400-e29b-41d4-a716-446655440000
Body:
  {
    "transaction_id": "TXN-12345",
    "amount": 1500.00,
    "currency": "USD",
    "merchant_id": "MERCHANT-789"
  }
```

### 2. DNS 解析

```
api.datavisor.com -> 54.123.45.67 (ALB IP)
```

### 3. API Gateway 层处理

#### 3.1 ALB 接收请求
- **SSL/TLS 终止**: 解密 HTTPS 流量
- **健康检查**: 确认后端集群健康
- **路由决策**: 根据路径和规则选择目标集群

```
/v1/fraud-detection -> aws-uswest2-prod-a (Cluster-A)
```

#### 3.2 Imperva WAF 检查（可选）
- **威胁检测**: SQL 注入、XSS 攻击检测
- **Bot 检测**: 识别和阻止恶意 Bot
- **速率限制**: 防止 DDoS 攻击

#### 3.3 APISIX 路由
- **认证验证**: 验证 JWT Token
- **限流检查**: 检查客户端 API 调用配额
- **插件执行**: 日志记录、监控等插件

### 4. Cluster 层处理

#### 4.1 Ingress Controller 接收
```
Nginx Ingress Controller -> fp-service:8080
```

**Ingress 配置**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fp-ingress
  namespace: prod
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: api.datavisor.com
      http:
        paths:
          - path: /v1/fraud-detection
            pathType: Prefix
            backend:
              service:
                name: fp-service
                port:
                  number: 8080
```

#### 4.2 Service 负载均衡
```
fp-service -> 选择 FP Pod (基于 RoundRobin 或 SessionAffinity)
```

**选择 Pod 的逻辑**:
1. 获取所有健康的 FP Pod 列表
2. 如果启用 SessionAffinity，根据客户端 IP 选择
3. 否则使用 RoundRobin 轮询选择

### 5. Pod 层处理

#### 5.1 FP Pod 接收请求
```
FP Pod (10.1.2.34:8080) -> 处理欺诈检测逻辑
```

**处理流程**:
1. **请求验证**: 验证请求格式和参数
2. **特征提取**: 从请求中提取特征
3. **模型推理**: 调用机器学习模型进行风险评分
4. **结果生成**: 生成欺诈检测结果

#### 5.2 返回响应
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "transaction_id": "TXN-12345",
  "risk_score": 0.85,
  "risk_level": "HIGH",
  "decision": "REVIEW",
  "reasons": [
    "Unusual transaction amount",
    "New device fingerprint"
  ],
  "timestamp": "2025-11-24T08:30:00Z"
}
```

### 6. 响应返回路径

```
FP Pod -> Service -> Ingress -> APISIX -> ALB -> Client
```

**每一层的处理**:
- **Pod**: 生成响应
- **Service**: 转发响应
- **Ingress**: 添加响应头（如 X-Request-ID）
- **APISIX**: 记录响应日志、更新监控指标
- **ALB**: SSL/TLS 加密
- **Client**: 接收并处理响应

---

## 监控和调试

### 1. Nginx Ingress 日志

**访问 Grafana Dashboard**:
```
https://grafana-mgt.dv-api.com/d/HFAlVh2Nz/debug-logs-for-ingress-nginx-controller
```

**关键指标**:
- `request_time`: 请求总时间
- `upstream_response_time`: 后端响应时间
- `status_code`: HTTP 状态码
- `client`: 客户端名称
- `interface`: API 接口

**示例查询**:
```
# 查看特定客户端的慢请求（> 1 秒）
cluster="aws-uswest2-prod-a"
client="sofi"
request_time > 1
```

### 2. VictoriaMetrics 指标

**关键指标**:
```promql
# API 请求 QPS
sum(rate(http_requests_total{cluster="aws-uswest2-prod-a",client="sofi"}[5m]))

# API 请求延迟 P95
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{cluster="aws-uswest2-prod-a"}[5m])) by (le))

# Pod CPU 使用率
sum(rate(container_cpu_usage_seconds_total{namespace="prod",pod=~"fp-deployment.*"}[5m])) by (pod)

# Pod 内存使用量
sum(container_memory_working_set_bytes{namespace="prod",pod=~"fp-deployment.*"}) by (pod)
```

### 3. 常见问题诊断

#### 问题 1: 请求延迟高

**排查步骤**:
1. **查看 Nginx 日志**: 检查 `upstream_response_time`
2. **检查 Pod 资源**: CPU/内存是否达到 limit
3. **查看 Pod 日志**: 是否有应用层错误
4. **检查网络**: 跨 AZ 或跨 Region 延迟

**示例命令**:
```bash
# 查看 Pod 资源使用
kubectl top pods -n prod -l app=fp-deployment

# 查看 Pod 日志
kubectl logs -n prod -l app=fp-deployment --tail=100 -f

# 查看 Pod 事件
kubectl describe pod -n prod <pod-name>
```

#### 问题 2: 5xx 错误增多

**排查步骤**:
1. **查看 Nginx 日志**: 确认错误码分布
2. **检查 Pod 健康**: Readiness/Liveness Probe 是否失败
3. **查看应用日志**: 应用层错误堆栈
4. **检查依赖服务**: 数据库、缓存、下游服务

**示例查询**:
```bash
# 查看 Pod 状态
kubectl get pods -n prod -l app=fp-deployment -o wide

# 查看 Pod 重启次数
kubectl get pods -n prod -l app=fp-deployment -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.containerStatuses[0].restartCount}{"\n"}{end}'

# 查看最近的事件
kubectl get events -n prod --sort-by='.lastTimestamp' | head -20
```

#### 问题 3: 流量不均衡

**排查步骤**:
1. **检查 Service SessionAffinity**: 是否启用了会话保持
2. **查看 Pod 数量**: 是否有足够的 Pod 副本
3. **检查 Pod 资源**: 是否有 Pod 资源不足导致健康检查失败
4. **查看 ALB 目标健康**: ALB Target Group 健康状态

**示例查询**:
```promql
# 查看每个 Pod 的请求分布
sum(rate(http_requests_total{namespace="prod",pod=~"fp-deployment.*"}[5m])) by (pod)

# 查看 Service Endpoints
kubectl get endpoints -n prod fp-service -o yaml
```

---

## 性能优化建议

### 1. API Gateway 层优化

- **启用缓存**: 对于可缓存的 API 响应，启用 CDN 或 API Gateway 缓存
- **压缩响应**: 启用 Gzip/Brotli 压缩
- **连接池**: 配置合理的连接池大小
- **超时设置**: 设置合理的超时时间

### 2. Cluster 层优化

- **HPA (水平自动扩展)**: 基于 CPU/内存/自定义指标自动扩展 Pod
- **VPA (垂直自动扩展)**: 自动调整 Pod 资源请求
- **Node Affinity**: 将 Pod 调度到性能更好的节点
- **Pod Disruption Budget**: 确保滚动更新时的高可用性

### 3. Pod 层优化

- **资源请求和限制**: 合理设置 requests 和 limits
- **健康检查**: 配置准确的 Readiness 和 Liveness Probe
- **优雅关闭**: 处理 SIGTERM 信号，优雅关闭连接
- **应用性能**: 优化应用代码、数据库查询、缓存策略

---

## 安全最佳实践

### 1. 网络安全

- **Network Policy**: 限制 Pod 之间的网络通信
- **Ingress TLS**: 强制 HTTPS 访问
- **Service Mesh**: 使用 Istio/Linkerd 实现 mTLS

**示例 Network Policy**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: fp-network-policy
  namespace: prod
spec:
  podSelector:
    matchLabels:
      app: fp-deployment
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: ingress-nginx
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              name: prod
      ports:
        - protocol: TCP
          port: 3306  # MySQL
        - protocol: TCP
          port: 6379  # Redis
```

### 2. 认证和授权

- **JWT Token**: 使用 JWT 进行 API 认证
- **RBAC**: Kubernetes RBAC 控制访问权限
- **Secret 管理**: 使用 Kubernetes Secrets 或 Vault
- **API Key 轮换**: 定期轮换 API Key

### 3. 日志和审计

- **集中式日志**: 使用 Loki/ELK 集中收集日志
- **审计日志**: 记录所有 API 调用和关键操作
- **敏感信息脱敏**: 日志中脱敏敏感信息（如密码、信用卡号）

---

## 高可用性设计

### 1. 多集群部署

- **地理分布**: 在多个 Region 部署集群
- **故障转移**: 自动故障转移到健康集群
- **流量分配**: 基于地理位置和负载分配流量

### 2. 灾难恢复

- **备份策略**: 定期备份配置和数据
- **恢复演练**: 定期进行灾难恢复演练
- **RTO/RPO**: 明确恢复时间目标和恢复点目标

### 3. 监控和告警

- **健康检查**: 多层次健康检查（ALB、Ingress、Pod）
- **告警规则**: 配置关键指标告警
- **On-call 流程**: 建立完善的 on-call 流程

---

## 相关文档

- [Luigi 进程调试助手使用指南](oncall-luigi-debug-helper.md)
- [DCluster API 操作手册](operation-dcluster-api-manual.md)
- [Kubernetes 网络指南](aws-k8s-networking-guide.md)
- [Ingress 设置指南](operation-k8s-ingress-setup-guide.md)
- [负载均衡器配置](operation-load-balancer-port-configuration.md)

---

## 更新日志

- **2025-11-24**: 初始版本，包含完整的请求路由流程和架构图
- 添加 Nginx Ingress 日志监控 Grafana Dashboard 链接
- 包含详细的组件说明和配置示例
- 添加监控、调试和优化建议

---

## 联系和支持

如有问题或建议：
1. 查看 Grafana Dashboard: https://grafana-mgt.dv-api.com/
2. 查看 URL Generator: http://localhost:8000/urls/
3. 联系 Oncall 团队









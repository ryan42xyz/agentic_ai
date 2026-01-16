# FP 服务基础设施指南

> **环境**: AWS US-West-2 Prod-A

## 服务概览

| 服务 | 职责 | 副本数 | 镜像 |
|------|------|--------|------|
| **FP** | 实时欺诈检测 | 4 | docker-registry.dv-api.com/cloud/fp:localtest |
| **FP-Async** | 异步批处理 | 4 | docker-registry.dv-api.com/cloud/fp-async:localtest |
| **FP-Cron** | 定时任务 | 1 | docker-registry.dv-api.com/cloud/fp-cron:localtest |

## 基础设施依赖

### 数据库

| 组件 | 连接地址 | 访问服务 |
|------|----------|----------|
| **MySQL** | `fp-mysql.prod:3306` | FP, FP-Async, FP-Cron |
| **YugabyteDB Primary** | `aws-uswest2-prod-a-yugabyte.dv-api.com` | FP, FP-Async, FP-Cron |
| **YugabyteDB Secondary** | `aws-uswest2-prod-b-yugabyte.dv-api.com:9042` | FP, FP-Async |
| **ClickHouse** | `clickhouse.prod:8123` | FP, FP-Async |
| **Cassandra** | `cassandra-0.cassandra-headless` | FP, FP-Async (已废弃) |

**MySQL 数据库**: `risk`, `ml`, `cron`

### 消息队列

| 组件 | 连接地址 | 访问服务 |
|------|----------|----------|
| **Kafka** | `kafka3.prod:9092` | FP (生产+消费), FP-Async (生产+消费), FP-Cron (仅生产) |

**Kafka Topics**: `prod_fp_velocity`, `api_command`, `replay_internal_prod_phase{1,2,3}`, `replay_rule_result`, `replayresult`, `case-management-prod`, `backfillcg.prod_a`

**Consumer Group**: `velocity.prod_a` (FP和FP-Async共享，竞争消费)
- FP: 3消费者/副本 (总计12)
- FP-Async: 9消费者/副本 (总计36) + 9回填消费者

### 其他依赖

| 组件 | 连接地址 | 访问服务 |
|------|----------|----------|
| **Nacos** | `nacos:8848` | FP, FP-Async |
| **Delay Queue** | `dq:8080` | FP, FP-Async |
| **Cluster Service** | `cluster.prod:8080` | FP, FP-Async, FP-Cron |
| **Ekata API** | `api.ekata.com` | FP, FP-Async |
| **S3** | `datavisor-prod-*` | FP, FP-Async |

## 资源配置

| 配置项 | FP | FP-Async | FP-Cron |
|--------|-----|----------|---------|
| **副本数** | 4 | 4 | 1 |
| **CPU** | 7 cores | 7 cores | 0.5-1 core |
| **内存** | 24Gi | 24Gi | 6Gi |
| **JVM Heap** | 20GB | 20GB | 4GB |
| **健康检查延迟** | 360s | 180s | 120s |

**最小资源需求**: ~80 cores, ~280GB内存, ~1.5TB存储

## 网络与端口

| 服务 | 端口 | 用途 |
|------|------|------|
| 所有服务 | 8080 | Web服务入口 |
| 所有服务 | 8777 | 特定Web服务 |
| 所有服务 | 9999, 5005 | 调试端口 |

**Ingress**: `fp-awsuswest2proda-prod.dv-api.com` → FP/FP-Async:8080

## 部署顺序

```
1. MySQL → 2. YugabyteDB → 3. ClickHouse → 4. Kafka → 5. Nacos → 
6. Delay Queue → 7. Cluster Service → 8. FP-Cron → 9. FP → 10. FP-Async
```

**关键依赖**:
- FP/FP-Async: MySQL, YugabyteDB, ClickHouse, Kafka, Nacos, Delay Queue
- FP-Cron: MySQL, YugabyteDB, Cluster Service

## 监控与健康检查

**Prometheus**: `/api-1.0-SNAPSHOT/actuator/prometheus` (端口8080)

**健康检查**:
- Liveness: `/api-1.0-SNAPSHOT/hello`
- Readiness: `/api-1.0-SNAPSHOT/actuator/health`

**关键监控指标**:
- `fp_request_latency_p99`, `fp_error_count`
- `yb_query_latency_p99`, `yb_connection_pool_usage`
- `kafka_consumer_lag{group="velocity.prod_a"}`

## 容量规划

| 服务 | QPS/吞吐量 | 平均延迟 |
|------|-----------|---------|
| FP | ~10,000 QPS | <50ms (P99<200ms) |
| FP-Async | ~34,000 events/s | N/A |

**扩容**: FP副本4→6, FP-Async consumerNum 9→12

## 故障排查

**延迟瓶颈优先级**: YugabyteDB (P0) > Ekata API (P1) > MySQL (P2) > 应用层 (P3)

**快速诊断**:
```bash
# 检查依赖
kubectl exec -it <fp-pod> -- mysql -h fp-mysql.prod -u root -p
kubectl exec -it <fp-pod> -- curl http://clickhouse.prod:8123

# 查看日志
kubectl logs <fp-pod> --tail=200
kubectl top pod -l app=fp

# Kafka Lag
kafka-consumer-groups --bootstrap-server kafka3.prod:9092 --describe --group velocity.prod_a
```

## 运维操作

```bash
# 重启
kubectl rollout restart deployment/fp
kubectl rollout restart deployment/fp-async

# 扩缩容
kubectl scale deployment/fp --replicas=6
kubectl scale deployment/fp-async --replicas=8
```

## 安全配置

- **镜像拉取**: FP/FP-Async 使用 `docker-registry` secret
- **数据库凭证**: MySQL/YugabyteDB 存储在 Kubernetes Secret
- **Kafka**: 内网无认证


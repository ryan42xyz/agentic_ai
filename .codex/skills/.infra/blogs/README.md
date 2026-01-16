# Blogs 文档索引

本文档整理了 `/blogs` 目录下的所有技术文档，按照主题进行分类，方便快速查找和参考。

---

## 📚 目录

- [架构文档](#架构文档-architecture)
- [运维操作指南](#运维操作指南-operation)
- [故障排查](#故障排查-oncalltroubleshooting)
- [监控相关](#监控相关-monitoring)
- [AWS/K8s 指南](#awsk8s-指南-awsk8s-guides)
- [Jenkins 相关](#jenkins-相关-jenkins)
- [成本相关](#成本相关-cost)
- [应用分析](#应用分析-application-analysis)
- [学习/其他](#学习其他-learningothers)

---

## 🏗️ 架构文档 (Architecture)

系统架构、业务架构、监控架构等核心架构文档。

| 文档 | 描述 |
|------|------|
| [architecture-core-business-job-workflow_luigi&dcluster&spark.md](./architecture-core-business-job-workflow_luigi&dcluster&spark.md) | DataVisor 核心业务运转架构分析：Cron、Luigi、DCluster、FP、数据存储等五大核心组件 |
| [architecture-request-routing-flow.md](./architecture-request-routing-flow.md) | 请求路由流程架构：从 Client 到 Pod Service 的完整调用链路 |
| [architecture-monitoring-system.md](./architecture-monitoring-system.md) | 监控系统架构：Prometheus、AlertManager、VictoriaMetrics、Loki 等组件 |
| [architecture-monitoring-configuration.md](./architecture-monitoring-configuration.md) | 监控配置架构：监控配置的详细说明 |
| [architecture-business-monitoring-system.md](./architecture-business-monitoring-system.md) | 业务监控系统架构：业务监控系统的设计 |
| [architecture-dv-applications.md](./architecture-dv-applications.md) | DataVisor 应用架构：平台应用的组织结构 |

---

## 🔧 运维操作指南 (Operation)

具体的操作步骤、部署流程、配置指南等运维文档。

| 文档 | 描述 |
|------|------|
| [operation-k8s-upgrade-plan.md](./operation-k8s-upgrade-plan.md) | K8s 升级计划：从 v1.27 升级到 v1.29 的详细操作步骤和 MirrorMaker 流量管理 |
| [operation-k8s-upgrade-guide.md](./operation-k8s-upgrade-guide.md) | K8s 升级指南：Kubernetes 集群升级的通用指南 |
| [operation-k8s-ingress-setup-guide.md](./operation-k8s-ingress-setup-guide.md) | K8s Ingress 设置指南：Ingress 配置和管理的详细步骤 |
| [operation-dapp-deployment-process.md](./operation-dapp-deployment-process.md) | DApp 部署流程：应用部署的完整流程 |
| [operation-dcluster-api-manual.md](./operation-dcluster-api-manual.md) | DCluster API 手册：DCluster API 的使用说明 |
| [operation-dns-configuration.md](./operation-dns-configuration.md) | DNS 配置指南：DNS 配置的详细说明 |
| [operation-dns-url-creation-procedure.md](./operation-dns-url-creation-procedure.md) | DNS URL 创建流程：创建 DNS URL 的步骤 |
| [operation-load-balancer-port-configuration.md](./operation-load-balancer-port-configuration.md) | 负载均衡器端口配置：LoadBalancer 端口配置指南 |
| [operation-mysql-backup-restore.md](./operation-mysql-backup-restore.md) | MySQL 备份恢复：MySQL 数据库备份和恢复操作 |
| [operation-mysql-database-size-analysis.md](./operation-mysql-database-size-analysis.md) | MySQL 数据库大小分析：数据库大小分析和优化 |
| [operation-clickhouse-data-extraction.md](./operation-clickhouse-data-extraction.md) | ClickHouse 数据提取：从 ClickHouse 提取数据的操作 |
| [operation-data-backfill-extraction.md](./operation-data-backfill-extraction.md) | 数据回填提取：数据回填和提取的操作流程 |
| [operation-jenkins-credential-management.md](./operation-jenkins-credential-management.md) | Jenkins 凭证管理：Jenkins 凭证的配置和管理 |

---

## 🚨 故障排查 (Oncall/Troubleshooting)

各种故障排查指南、检查清单和问题解决方案。

| 文档 | 描述 |
|------|------|
| [oncall-dcluster_trouble_shooting.md](./oncall-dcluster_trouble_shooting.md) | DCluster Spark Job 故障排查指南 |
| [oncall-luigi-debug-helper.md](./oncall-luigi-debug-helper.md) | Luigi 调试助手：Luigi 任务调试和排查 |
| [oncall-fp-latency-issues.md](./oncall-fp-latency-issues.md) | FP 延迟问题排查：Feature Platform 延迟问题的诊断 |
| [oncall-kafka-lag-issues.md](./oncall-kafka-lag-issues.md) | Kafka Lag 问题排查：Kafka 消费延迟问题 |
| [oncall-kafka-restart-failed.md](./oncall-kafka-restart-failed.md) | Kafka 重启失败排查：Kafka 重启失败的问题诊断 |
| [oncall-clickhouse_canot_connect.md](./oncall-clickhouse_canot_connect.md) | ClickHouse 连接问题排查：无法连接 ClickHouse 的解决方案 |
| [oncall-clickhouse_storage_issue.md](./oncall-clickhouse_storage-issue.md) | ClickHouse 存储问题排查：ClickHouse 存储相关问题 |
| [oncall-yugabyte-handler-issues.md](./oncall-yugabyte-handler-issues.md) | Yugabyte Handler 问题排查：Yugabyte 处理相关问题 |
| [oncall-database-issues.md](./oncall-database-issues.md) | 数据库问题排查：通用数据库问题排查指南 |
| [oncall_db_issue.md](./oncall_db_issue.md) | 数据库问题：数据库相关问题的快速参考 |
| [oncall-nginx_issue.md](./oncall-nginx_issue.md) | Nginx 问题排查：Nginx Ingress 相关问题 |
| [oncall-node-notready-issues.md](./oncall-node-notready-issues.md) | Node NotReady 问题排查：K8s 节点不可用问题 |
| [oncall-node-description-analysis.md](./oncall-node-description-analysis.md) | Node 描述分析：K8s 节点描述信息的分析 |
| [oncall-cluster-issues.md](./oncall-cluster-issues.md) | 集群问题排查：K8s 集群相关问题 |
| [oncall-resource-exhaustion-issues.md](./oncall-resource-exhaustion-issues.md) | 资源耗尽问题排查：资源不足问题的诊断 |
| [oncall-site-access-issues.md](./oncall-site-access-issues.md) | 站点访问问题排查：网站访问相关问题 |
| [oncall-data-copy-issues.md](./oncall-data-copy-issues.md) | 数据复制问题排查：数据复制相关问题 |
| [oncall-client-maqeta_too_many_alert.md](./oncall-client-maqeta_too_many_alert.md) | Marqeta 客户告警过多问题：Marqeta 客户告警问题的分析 |
| [oncall-aws_issue_checkbook.md](./oncall-aws_issue_checkbook.md) | AWS 问题检查清单：AWS 相关问题的检查清单 |
| [oncall-check_what.md](./oncall-check_what.md) | 故障排查检查清单：通用故障排查检查项 |
| [oncall_opsgen_general_checkbook.md](./oncall_opsgen_general_checkbook.md) | OpsGenie 通用检查清单：OpsGenie 告警的通用检查项 |

---

## 📊 监控相关 (Monitoring)

监控系统、Grafana 面板、SQL 查询、Yugabyte 监控等。

| 文档 | 描述 |
|------|------|
| [monitoring-latency_architecture.md](./monitoring-latency_architecture.md) | Grafana E2E Latency 面板架构分析：延迟监控的完整架构 |
| [monitoring-latency_troubleshooting_guide-with-nginx.md](./monitoring-latency_troubleshooting_guide-with-nginx.md) | 延迟故障排查指南（含 Nginx）：结合 Nginx 日志的延迟排查 |
| [monitoring-grafana_sla_ec2_summary.md](./monitoring-grafana_sla_ec2_summary.md) | Grafana SLA EC2 摘要：SLA 和 EC2 监控的 Grafana 面板说明 |
| [monitoring-useful_sql.md](./monitoring-useful_sql.md) | 常用监控 SQL：监控系统中常用的 SQL 查询 |
| [monitoring-yugabyte_monitoring_commands.md](./monitoring-yugabyte_monitoring_commands.md) | Yugabyte 监控命令：Yugabyte 数据库的监控命令集合 |

---

## ☁️ AWS/K8s 指南 (AWS/K8s Guides)

AWS 和 Kubernetes 相关的详细技术指南。

| 文档 | 描述 |
|------|------|
| [aws-k8s-networking-guide.md](./aws-k8s-networking-guide.md) | AWS/Kubernetes 网络架构学习指南：网络基础、K8s 网络模型、LoadBalancer 集成 |
| [aws-k8s-storage-guide.md](./aws-k8s-storage-guide.md) | AWS/Kubernetes 存储指南：EBS、PV、PVC、存储类等 |
| [aws-k8s-load-balancer-ingress-guide.md](./aws-k8s-load-balancer-ingress-guide.md) | AWS/K8s LoadBalancer 和 Ingress 指南：LoadBalancer 和 Ingress 的配置 |
| [aws-k8s-pod-storage-affinity-scheduling.md](./aws-k8s-pod-storage-affinity-scheduling.md) | Pod 存储亲和性调度：Pod 与存储的亲和性调度策略 |
| [aws-k8s-worker-node-interaction-guide.md](./aws-k8s-worker-node-interaction-guide.md) | Worker Node 交互指南：Worker Node 与 AWS 的交互机制 |

---

## 🔨 Jenkins 相关 (Jenkins)

Jenkins 相关的配置、问题排查和性能优化文档。

| 文档 | 描述 |
|------|------|
| [jenkins-multi-repo-performance.md](./jenkins-multi-repo-performance.md) | Jenkins 多仓库性能优化：多仓库构建的性能优化 |
| [jenkins-s3-permission-issues.md](./jenkins-s3-permission-issues.md) | Jenkins S3 权限问题：S3 权限配置和问题排查 |
| [jenkins-selenium-dns-failures.md](./jenkins-selenium-dns-failures.md) | Jenkins Selenium DNS 故障：Selenium 测试中的 DNS 问题 |

---

## 💰 成本相关 (Cost)

成本分析、成本记录和成本优化文档。

| 文档 | 描述 |
|------|------|
| [cloud_cost-tenant_cost.md](./cloud_cost-tenant_cost.md) | 云成本-租户成本分析：云成本和租户成本的分析 |
| [cost_record.md](./cost_record.md) | 成本记录：成本相关的记录和追踪 |

---

## 📱 应用分析 (Application Analysis)

应用相关的架构分析和功能说明。

| 文档 | 描述 |
|------|------|
| [dapp_authentication_routing_analysis.md](./dapp_authentication_routing_analysis.md) | DAPP 认证与路由机制分析：JWT 认证、多集群路由、流量切换等 |

---

## 📖 学习/其他 (Learning/Others)

学习目标、提示词模板和其他文档。

| 文档 | 描述 |
|------|------|
| [learning-probation-goals.md](./learning-probation-goals.md) | 试用期学习目标：试用期的学习目标和计划 |
| [prompt.md](./prompt.md) | 提示词模板：AI 提示词模板和使用说明 |

---

## 📁 其他资源

### 图片资源

`pic/` 目录包含以下图片：
- `alert-code-460.png` - 告警代码 460 相关图片
- `apisix-metrics.png` - APISIX 指标图片
- `client-cron-job-with-fp.png` - 客户端 Cron Job 与 FP 架构图
- `marqeta-qps1.png` - Marqeta QPS 图表
- `marqeta-sla.png` - Marqeta SLA 图表
- `marqeta-yb-cpu-mem.png` / `marqeta-yb-cpu-mem-2.png` - Marqeta Yugabyte CPU/内存图表

### JSON 配置文件

- `prometheus_alert_config.json` - Prometheus 告警配置

---

## 🔍 快速查找

### 按问题类型查找

- **K8s 升级问题** → [operation-k8s-upgrade-plan.md](./operation-k8s-upgrade-plan.md)
- **延迟问题** → [monitoring-latency_architecture.md](./monitoring-latency_architecture.md) | [monitoring-latency_troubleshooting_guide-with-nginx.md](./monitoring-latency_troubleshooting_guide-with-nginx.md)
- **DCluster 问题** → [oncall-dcluster_trouble_shooting.md](./oncall-dcluster_trouble_shooting.md)
- **Luigi 问题** → [oncall-luigi-debug-helper.md](./oncall-luigi-debug-helper.md)
- **Kafka 问题** → [oncall-kafka-lag-issues.md](./oncall-kafka-lag-issues.md) | [oncall-kafka-restart-failed.md](./oncall-kafka-restart-failed.md)
- **ClickHouse 问题** → [oncall-clickhouse_canot_connect.md](./oncall-clickhouse_canot_connect.md) | [oncall-clickhouse_storage_issue.md](./oncall-clickhouse_storage_issue.md)
- **数据库问题** → [oncall-database-issues.md](./oncall-database-issues.md) | [oncall_db_issue.md](./oncall_db_issue.md)
- **Nginx 问题** → [oncall-nginx_issue.md](./oncall-nginx_issue.md)
- **网络问题** → [aws-k8s-networking-guide.md](./aws-k8s-networking-guide.md)
- **存储问题** → [aws-k8s-storage-guide.md](./aws-k8s-storage-guide.md)

### 按组件查找

- **核心业务架构** → [architecture-core-business-job-workflow_luigi&dcluster&spark.md](./architecture-core-business-job-workflow_luigi&dcluster&spark.md)
- **监控系统** → [architecture-monitoring-system.md](./architecture-monitoring-system.md) | [monitoring-latency_architecture.md](./monitoring-latency_architecture.md)
- **请求路由** → [architecture-request-routing-flow.md](./architecture-request-routing-flow.md)
- **DApp** → [dapp_authentication_routing_analysis.md](./dapp_authentication_routing_analysis.md) | [operation-dapp-deployment-process.md](./operation-dapp-deployment-process.md)

---

## 📝 文档维护

- **最后更新**: 2025-01-XX
- **文档总数**: 57 个 Markdown 文件
- **分类数量**: 9 个主要分类

---

## 💡 使用建议

1. **新员工入职**: 建议先阅读 [learning-probation-goals.md](./learning-probation-goals.md) 了解学习目标
2. **架构理解**: 从 [architecture-core-business-job-workflow_luigi&dcluster&spark.md](./architecture-core-business-job-workflow_luigi&dcluster&spark.md) 开始了解核心业务架构
3. **故障排查**: 根据问题类型，参考对应的故障排查文档
4. **运维操作**: 在执行操作前，先查看对应的操作指南文档

---

## 🔗 相关链接

- [主项目 README](../README.md)
- [AI 文档目录](../ai_docs/)
- [K8s 升级操作目录](../k8s_upgrade_operation/)



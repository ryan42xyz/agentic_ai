
# Kubernetes 集群升级完整指南  
## Control Plane + Addons + Worker Nodes（1.24 → 1.26）

本文件是对你之前三个部分的深度分析内容进行整体整合，形成可长期保存、可复用的专业升级文档。包括：

- 控制面（master）升级  
- Addons（组件）升级  
- Worker Nodes（ASG + Spark）升级  

文档内容聚焦升级影响、机制、风险点与系统视角解读，而不仅是命令列表。

---

# 1. 控制面节点升级（master0 → master1/2）

控制面升级的核心目标是：

- 保持 etcd 数据一致性  
- 保持 API Server / Scheduler / Controller-manager 升级顺序正确  
- 保证 kubelet/kubeadm 版本对齐  
- 不破坏集群可用性  

升级流程分为 **leader master0** 与 **其它 master 节点**。

---

## 1.1 etcd 备份（只在 master0）

etcdctl snapshot save 会：

- 通过 TLS 连接当前 etcd  
- 导出全量 K/V 状态、租约、Kubernetes 所有对象  
- 写入 snapshot.db 到本地  

这是整个升级过程中最关键的安全步骤。  
一旦升级失败、证书错误或 etcd 出现版本兼容性问题，snapshot 能救命。

---

## 1.2 更换 apt 源（锁定 Kubernetes 版本）

影响：

- 决定 kubeadm/kubelet/kubectl 后续安装的 EXACT 版本  
- 避免自动更新到不期望的版本  
- 确保 kubeadm upgrade plan 正常工作  

---

## 1.3 升级 kubeadm

kubeadm 是整个控制面升级 orchestrator。  
安装 kubeadm 1.26.15 不会修改任何正在运行的组件，只影响接下来的 upgrade。

---

## 1.4 kubeadm upgrade plan

执行升级前检查：

- etcd 健康状况  
- API server 状态  
- 控制面组件版本  
- 集群配置  
- 镜像可拉取性  

没有副作用，是优化升级策略的关键步骤。

---

## 1.5 kubeadm upgrade apply（master0）

这是整个控制面升级的核心动作。

它会：

1. 更新 /etc/kubernetes/manifests 里的静态 Pod（apiserver/scheduler/controller/etcd）  
2. 切换镜像版本  
3. 根据配置更新证书  
4. 触发 kubelet 重建控制面组件  

影响：

- 控制面短暂不可用（秒级）  
- 业务 Pod 不受影响  
- 副作用最低但至关重要  

需要 **--force** 来跳过部分镜像验证。

---

## 1.6 drain 当前节点

Drain 的作用是：

- 驱逐运行中的 workload  
- 避免 kubelet 重启导致 Pod 无故消亡  
- 维持集群调度稳定性  

---

## 1.7 升级 kubelet & kubectl

重启 kubelet 影响：

- worker 或 master Node 会有短暂 NotReady  
- 控制面功能立即使用新 kubelet  

kubectl 升级是为了避免版本 skew。

---

## 1.8 uncordon 返回集群

恢复调度能力，升级完成 master0。

---

## 1.9 master1 / master2 使用 `kubeadm upgrade node`

区别：

- 不执行控制面全局升级  
- 仅同步本节点的 kubelet/证书/静态 pod 版本  
- 保证多控 HA 的一致性  

流程类似，不再重复。

---

# 2. Addons 组件升级

组件升级的本质目标：

- 使控制面功能的外部依赖对齐新版 API  
- 提升可观测性、自动伸缩能力  
- 让 ingress、cloudprovider、监控等体系不出现版本漂移  

你升级的组件有：

1. AWS Cloud Controller Manager  
2. Cluster Autoscaler  
3. Kube-state-metrics  
4. Ingress Nginx  

以下是系统级影响分析。

---

## 2.1 AWS Cloud Controller Manager（CCM）

作用：

- Node 初始化（Ready 条件）  
- ELB/Route/Subnet 管理  
- cloudProvider AWS 相关生命周期  

升级影响：

- 影响 Node Ready 状态判断  
- ELB/Ingress 会受到影响  
- RBAC/values 更新错误会阻断所有新节点的初始化流程  

这是 addon 里最重要的组件之一。

---

## 2.2 Cluster Autoscaler（CA）

作用：

- Pod Pending 时自动扩容  
- ASG scale-in/scale-out  
- 与 Cloud Provider 协调节点删除和创建  

升级影响：

- 影响扩容性能  
- 若配置错误，集群无法自动扩容  
- 必须验证新节点 join 是否正常  

和 CCM 强相关。

---

## 2.3 Kube-state-metrics（KSM）

作用：

- 提供 Kubernetes 状态给 Prometheus  
- Grafana 数据源  

升级影响：

- 不影响业务  
- 错误配置将导致监控仪表盘空白  
- Prometheus scrape 会短暂失败  

整体风险低。

---

## 2.4 Ingress Nginx

作用：

- 集群对外访问入口  
- 维护 Nginx controller + admission webhook  
- LB 转发规则更新  

升级影响：

- Ingress 路由可能短暂中断  
- 配置不当会导致 502/503  
- 必须验证 ingress-access  

四个 addons 里对业务影响最大的就是 ingress nginx。

---

# 3. Worker 节点升级（不可变基础设施方式）

Worker 不像 master 采用原地升级，而是：

- 通过 packer 构建新的 AMI  
- 替换 ASG Launch Template  
- 滚动更新节点  

这是云上最佳实践。

---

## 3.1 修改 k8s.yaml（节点基因模板）

影响：

- 决定 kubelet/containerd/cni 的版本  
- 决定系统级别 setup（sysctl/systemd）  
- 错误会导致节点无法 Ready  

这是 worker 的核心基础配置。

---

## 3.2 Packer 构建 Worker AMI

流程：

1. packer 启动临时 EC2  
2. 安装 kubelet/containerd/CNI  
3. 固化为不可变镜像  

影响：

- 未来加入 ASG 的所有 worker 节点都将基于该镜像  
- 镜像错误影响所有扩容和滚动升级  

注意：

- AMI 名不能冲突  
- 是否启用 IMDSv2 关键取决于脚本依赖  

---

## 3.3 替换 ASG Launch Template

这是 worker 升级真正生效的时刻。

影响：

- 所有 scale-out 节点变成新版本  
- 可以触发 rolling 来逐步替换旧 worker  

这是整个 worker 升级的最终落地操作。

---

# 4. Spark Worker 节点升级

Spark 节点是 worker 的定制版，因此流程是继承 +扩展。

---

## 4.1 基于 worker AMI 再构建 Spark AMI

影响：

- Worker 的 kubelet/containerd/CNI 保持一致  
- Spark 的 JDK、Hadoop libs、runtime 单独集成  
- 错误配置可能导致 executor 启动失败  

---

## 4.2 修改 dcluster 的 values（Spark 节点池）

影响：

- 决定 Spark 节点的标签/污点  
- 决定 Spark Pod 的调度范围  
- 决定 Spark worker 所属 AMI  

这是 Spark 节点身份定义的核心部分。

---

# 5. 整体升级逻辑总结

以下是整个系统升级路径的结构化理解：

| 层级 | 升级方法 | 核心影响 |
|------|-----------|-----------|
| Control Plane | kubeadm upgrade（master0 → master1/2） | 整个控制面能力一致性 |
| etcd | snapshot + 静态 Pod 替换 | 集群状态数据库安全 |
| Addons | helm upgrade | 扩容能力、云资源管理、监控、流量入口 |
| Worker 节点 | ASG + Packer AMI | kubelet/containerd 版本一致性、调度能力 |
| Spark Worker | 二次 AMI 构建 + values | Spark workload 行为与性能 |

最终目标：

**保证整个集群（控制面、数据面、流量面、调度面、监控面）在 1.26 上保持一致性与稳定性。**

---

# 6. 生产环境升级实战：aws-uswest2-prod-b（1.26 → 1.29）

本章节记录了 aws-uswest2-prod-b 集群从 1.26 升级到 1.29 的完整过程，包括准备工作、升级步骤、流量切换和验证。

---

## 6.0 升级前准备（Pre-upgrade Checklist）

### 6.0.1 准备 AMI 镜像

- **Worker AMI**: 基于新版本 Kubernetes 构建
- **Spark AMI**: 基于 Worker AMI 二次构建

### 6.0.2 代码准备

- 将 dcluster 配置变更合并到 git 分支
- 应用 admin-ui 配置

### 6.0.3 集群信息收集

**基本信息**:
- **Cluster Name**: aws-uswest2-prod-b
- **Region**: us-west-2
- **IMDS Version**: IMDSv2
- **dcluster version**: v1
- **spark-long-living**: v1

**AWS ASG 配置**: 
- 记录当前 ASG 配置和实例数量

**dcluster 环境**:
```bash
kubectl get pod -A | grep -i dcluster | awk '{print $1}' | sort | uniq -c | awk '{print $2}'
# Output: prod
```

**Dedicated Namespaces**:
- apsoutheastprod
- automation
- qaautotest
- useastprod

---

## 6.1 MySQL 主从状态检查（关键前置步骤）

### 6.1.1 检查所有 MySQL 实例（prod-a 和 prod-b）

确保升级集群时，endpoints 指向备用集群：

```bash
# 检查 MySQL endpoints
kubectl get endpoints -n prod | grep 'mysql '

# 进入 MySQL pod 检查复制状态
kubectl exec -it dcluster-mysql-0 -n prod bash
mysql -p$MYSQL_ROOT_PASSWORD
show slave status \G
```

### 6.1.2 远程 MySQL 切换方法

使用 **Mysql Service Switch Operator** 进行主从切换：

**west-a 集群**:
```bash
kubectl edit ServiceSwitch -n prod
```

**west-b 集群**:
```bash
kubectl edit ServiceSwitch -n prod
```

---

## 6.2 流量切换和消息队列管理

### 6.2.1 切换流量到 west-a（设置 west-b 为维护状态）

将 west-b 集群状态设置为 maintaining，确保用户流量不进入。

### 6.2.2 停止 MirrorMaker（west-a 和 west-b）

停止 Kafka MirrorMaker 服务，避免升级期间消息同步问题。

### 6.2.3 等待 west-b 消息消费完成

**监控地址**:
```
https://grafana-mgt.dv-api.com/d/cluster_kafkfa_exporter/kafka-exporter-for-all?orgId=1&var-cluster=aws-euwest1-prod-b&var-namespace=prod
```

**关键 Topic**:
- cluster_a.xxxx
- backfill.xxxx
- velocity-al.xxx
- velocity.xxx

**关键 Consumer Groups**:
- 确保所有 consumer group 的 lag < 1k

---

## 6.3 Kubernetes 升级（1.26 → 1.27）

### 6.3.1 Master 节点升级（1.26 → 1.27）

参考第 1 章节的标准流程：

1. etcd 备份（master0）
2. 更换 apt 源到 1.27
3. 升级 kubeadm 到 1.27.x
4. kubeadm upgrade plan
5. kubeadm upgrade apply（master0）
6. drain → 升级 kubelet & kubectl → uncordon
7. master1/master2 使用 `kubeadm upgrade node`

**升级后检查**:
```bash
# 检查 node 状态
kubectl get nodes

# 检查 pod 状态
kubectl get pods -A
```

### 6.3.2 组件升级（1.26 → 1.27）

**Cloud Provider**:
- 检查相关 Pod 状态
- 验证 LB Service 工作正常
- 验证 Ingress 访问正常

**Cluster Autoscaler**:
- 检查相关 Pod 状态
- 验证新节点能正常加入集群

**Kube-state-metrics**:
- 检查相关 Pod 状态
- 验证 Dashboard 数据正常
- 监控地址: `https://grafana-mgt.dv-api.com/d/devasd_XlLjRMz/dev-pod-resources?orgId=1`

### 6.3.3 Worker 节点升级（1.26 → 1.27）

**数据库节点** (MySQL/Kafka/YugabyteDB/ClickHouse):
```bash
# 识别所有数据库节点
kubectl get pod -A -o wide | grep -E 'mysql|yb-|kafka|chi' | grep -o 'ip-.*internal' | sort | uniq -c
```

**其他节点**:
- 按照第 3 章节流程使用 Packer + ASG 方式滚动升级

**升级后检查**:
- 检查 node 状态
- 检查 pod 状态

### 6.3.4 其他检查项

**应用层检查**:
- 检查 app pod/endpoints 状态
- 检查应用日志

**网络连通性检查**:
- Pod → Pod 通信（chi-pod → mysql-pod）
- Node → Pod 通信（node → chi-pod）
- Pod → External 通信（chi-pod → external）

**Ingress 访问检查**:
- Grafana 访问
- Jumpserver 访问

---

## 6.4 Kubernetes 升级（1.27 → 1.29）

### 6.4.1 Master 节点升级（1.27 → 1.28 → 1.29）

**步骤 1: 1.27 → 1.28**
- 重复 6.3.1 的流程，使用 1.28 版本

**步骤 2: 1.28 → 1.29**
- 重复 6.3.1 的流程，使用 1.29 版本

**每次升级后检查**:
```bash
kubectl get nodes
kubectl get pods -A
```

### 6.4.2 组件升级（1.27 → 1.29）

**Calico**:
- 检查相关 Pod 状态
- 验证 Pod-to-Pod 通信正常

**Cloud Provider**:
- 检查相关 Pod 状态
- 验证 LB Service 工作正常
- 验证 Ingress 访问正常

**Cluster Autoscaler**:
- 检查相关 Pod 状态
- 验证新节点能正常加入集群

**Kube-state-metrics**:
- 检查相关 Pod 状态
- 验证 Dashboard 数据正常
- 监控地址: `https://grafana-mgt.dv-api.com/d/devasd_XlLjRMz/dev-pod-resources?orgId=1`

### 6.4.3 Worker 节点升级（1.27 → 1.29）

**数据库节点识别**:
```bash
kubectl get pod -A -o wide | grep -E 'mysql|yb-|kafka|chi' | grep -o 'ip-.*internal' | sort | uniq -c
```

**升级流程**:
- 参考第 3 章节 Worker 节点升级流程
- 使用新构建的 1.29 版本 AMI
- 通过 ASG 滚动更新

**升级后检查**:
- 检查 node 状态
- 检查 pod 状态

### 6.4.4 其他检查项

**应用层检查**:
- 检查 app pod 状态
- 检查应用日志

**网络连通性检查**:
- Pod → Pod 通信（chi-pod → mysql-pod）
- Node → Pod 通信（node → chi-pod）
- Pod → External 通信（chi-pod → external）

**Ingress 访问检查**:
- Grafana 访问
- Loki 访问
- Jumpserver 访问

---

## 6.5 恢复服务和流量切换

### 6.5.1 启动 MirrorMaker（west-a 和 west-b）

启动 Kafka MirrorMaker 服务，恢复消息同步。

### 6.5.2 监控 Mirror Lag

**监控 mirror lag** (目标: < 1k):
```
https://grafana-mgt.dv-api.com/d/-N7cUPZNk/mirrorlag-v2?orgId=1&var-cluster=aws-euwest1-prod-b&var-namespace=prod&var-source=cluster_a&var-target=cluster_b
```

**同时检查消费者 lag** (目标: < 1k):
```
https://grafana-mgt.dv-api.com/d/cluster_kafkfa_exporter/kafka-exporter-for-all?orgId=1&var-cluster=aws-euwest1-prod-b&var-namespace=prod
```

### 6.5.3 设置 west-b DAPP 状态为 available

将 west-b 集群状态从 maintaining 改为 available。

### 6.5.4 切换流量到 west-b（5-10 分钟观察）

将部分流量切换到 west-b，观察：
- SLA 指标
- 延迟指标
- 错误率

### 6.5.5 切回 west-a，恢复正常流量分配

如果观察期间一切正常，可以恢复正常的流量分配；如果发现问题，立即切回 west-a。

---

## 6.6 升级总结和最佳实践

### 6.6.1 关键成功因素

1. **充分的准备工作**: 
   - AMI 提前构建并测试
   - 配置变更提前合并
   - 集群信息完整收集

2. **MySQL 主从切换**:
   - 确保升级集群时，应用连接到备用集群
   - 避免数据库连接中断

3. **消息队列管理**:
   - 停止 MirrorMaker 避免升级期间同步问题
   - 等待消息消费完成（lag < 1k）
   - 升级后恢复同步并监控

4. **流量切换策略**:
   - 升级前切走流量（maintaining 状态）
   - 升级后小流量验证（5-10 分钟）
   - 验证通过后恢复正常流量

5. **分阶段升级**:
   - 1.26 → 1.27 → 1.28 → 1.29
   - 每个版本升级后充分验证
   - 避免跨多个大版本升级

6. **全方位检查**:
   - 控制面状态
   - 组件状态
   - 应用状态
   - 网络连通性
   - Ingress 访问
   - 监控仪表盘

### 6.6.2 风险点和注意事项

1. **数据库节点升级**:
   - 需要特别小心
   - 提前识别所有数据库节点
   - 考虑分批升级

2. **消息队列影响**:
   - MirrorMaker 停止期间，跨集群消息不同步
   - 必须等待消费完成再升级

3. **流量切换时机**:
   - 选择业务低峰期
   - 确保监控系统正常
   - 准备好回滚方案

4. **版本兼容性**:
   - 组件版本必须与 Kubernetes 版本兼容
   - 参考官方兼容性矩阵

5. **网络插件（Calico）**:
   - 升级后必须验证 Pod-to-Pod 通信
   - 网络问题影响整个集群

### 6.6.3 监控和告警

**关键监控指标**:
- Node Ready 状态
- Pod 运行状态
- Kafka consumer lag
- MirrorMaker lag
- SLA 和延迟指标
- Ingress 访问成功率

**告警阈值**:
- Consumer lag > 1k
- Mirror lag > 1k
- Node NotReady > 1min
- Pod CrashLoopBackOff

---

# 7. 升级流程速查表

## 7.1 升级前检查清单

- [ ] 准备新版本 Worker AMI
- [ ] 准备新版本 Spark AMI
- [ ] 合并代码变更到 git
- [ ] 收集集群信息（namespace、ASG、节点等）
- [ ] 检查 MySQL 主从状态
- [ ] 验证备用集群可用性
- [ ] 确认监控系统正常
- [ ] 准备回滚方案

## 7.2 升级执行流程

1. **流量切换**:
   - 将流量切换到备用集群
   - 设置目标集群为 maintaining 状态

2. **消息队列准备**:
   - 停止 MirrorMaker
   - 等待消息消费完成（lag < 1k）

3. **MySQL 切换**:
   - 使用 ServiceSwitch 切换到备用集群

4. **Kubernetes 升级**:
   - Master 节点升级（按版本逐步升级）
   - 组件升级（CCM、CA、KSM、Calico 等）
   - Worker 节点升级（Packer AMI + ASG）

5. **验证检查**:
   - Node/Pod 状态
   - 组件功能
   - 网络连通性
   - Ingress 访问
   - 应用日志

6. **恢复服务**:
   - 启动 MirrorMaker
   - 监控 mirror lag（< 1k）
   - 设置集群状态为 available

7. **流量验证**:
   - 小流量切换（5-10 分钟）
   - 监控 SLA/延迟/错误率
   - 恢复正常流量或回滚

## 7.3 关键命令速查

```bash
# 集群信息收集
kubectl get pod -A | grep -i dcluster | awk '{print $1}' | sort | uniq -c
kubectl get pod -A -o wide | grep -E 'mysql|yb-|kafka|chi' | grep -o 'ip-.*internal' | sort | uniq -c

# MySQL 检查
kubectl get endpoints -n prod | grep 'mysql '
kubectl exec -it dcluster-mysql-0 -n prod bash
show slave status \G

# MySQL 切换
kubectl edit ServiceSwitch -n prod

# etcd 备份
etcdctl snapshot save /backup/etcd-snapshot.db

# kubeadm 升级
kubeadm upgrade plan
kubeadm upgrade apply v1.27.x --force
kubeadm upgrade node

# 节点维护
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
kubectl uncordon <node>

# 状态检查
kubectl get nodes
kubectl get pods -A
kubectl get componentstatuses
```

## 7.4 监控地址

- **Pod Resources Dashboard**: `https://grafana-mgt.dv-api.com/d/devasd_XlLjRMz/dev-pod-resources?orgId=1`
- **Kafka Exporter**: `https://grafana-mgt.dv-api.com/d/cluster_kafkfa_exporter/kafka-exporter-for-all`
- **Mirror Lag**: `https://grafana-mgt.dv-api.com/d/-N7cUPZNk/mirrorlag-v2`

---

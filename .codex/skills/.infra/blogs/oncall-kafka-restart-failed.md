# Kafka KRaft 集群周期性重启问题

## 问题现象

Kafka KRaft 集群在运行过程中，三个 broker 出现了周期性重启。具体表现：

- **症状**：节点依次退出、再自动拉起，形成循环
- **日志特征**：未出现明确的 Fatal 错误或 OOM（Out of Memory）
- **集群影响**：
  - 控制器（Controller）角色频繁切换
  - Kafka 无法稳定提供服务
  - 集群出现重启风暴

## 原因分析

### 根本原因

**不是 Kafka 自己挂了，是 Kubernetes 探针把它杀挂了。**

### 问题链路

```
Kubernetes livenessProbe 配置过于激进
  ↓
periodSeconds 短 + failureThreshold 小
  ↓
Kafka 启动时、或 CPU/IO 抖动时 probe 超时
  ↓
Kubernetes 误判 Kafka 不健康
  ↓
触发强制重启
  ↓
导致 KRaft quorum 多次重选 Controller
  ↓
最终形成全集群重启风暴
```

### 关键问题点

1. **探针配置过于敏感**：
   - `periodSeconds` 太短，没有给 Kafka 足够的恢复时间
   - `failureThreshold` 太小，短暂抖动就被判定为不健康

2. **Kafka 启动特性**：
   - Kafka 启动时需要时间完成 metadata 同步
   - Controller 选举和心跳需要稳定的网络环境
   - CPU/IO 抖动时可能短暂影响响应

3. **误杀循环**：
   - 一个 broker 被误杀 → Controller 重选
   - Controller 重选期间其他 broker 可能响应变慢
   - 其他 broker 也被误杀 → 形成循环

## 解决方案

### 调整 livenessProbe 参数

修改 Kubernetes Deployment/StatefulSet 中的 livenessProbe 配置，使其留出更多可恢复时间：

```yaml
livenessProbe:
  failureThreshold: 99      # 大幅增加失败阈值，避免短暂抖动导致重启
  initialDelaySeconds: 50     # 给 Kafka 足够的启动时间
  periodSeconds: 50           # 增加探测间隔，减少对 Kafka 的压力
  timeoutSeconds: 5           # 保持合理的超时时间
```

### 参数说明

- **`failureThreshold: 99`**：
  - 允许连续失败 99 次才判定为不健康
  - 给 Kafka 足够的时间完成 metadata 同步和 controller 心跳
  - 避免因短暂抖动而被误杀

- **`initialDelaySeconds: 50`**：
  - Kafka 启动需要时间初始化 metadata、选举 controller
  - 50 秒的初始延迟确保启动过程不被中断

- **`periodSeconds: 50`**：
  - 每 50 秒探测一次，减少对 Kafka 的频繁访问
  - 降低因探测导致的性能影响

- **`timeoutSeconds: 5`**：
  - 保持合理的超时时间，避免探测本身卡住

### 推荐配置示例

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kafka
spec:
  template:
    spec:
      containers:
      - name: kafka
        livenessProbe:
          httpGet:
            path: /metrics
            port: 9092
          failureThreshold: 99
          initialDelaySeconds: 50
          periodSeconds: 50
          timeoutSeconds: 5
        readinessProbe:
          httpGet:
            path: /ready
            port: 9092
          failureThreshold: 3
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
```

**注意**：`readinessProbe` 可以保持相对敏感，因为它只影响流量路由，不会触发重启。

## 结果

调整后：

- ✅ **三个 broker 运行稳定**：不再出现周期性重启
- ✅ **Controller 不再频繁切换**：集群控制器角色稳定
- ✅ **集群恢复正常服务**：Kafka 可以稳定提供服务

### 验证方法

```bash
# 检查 broker 状态
kubectl get pods -l app=kafka

# 查看 controller 选举日志
kubectl logs -l app=kafka | grep -i controller

# 检查集群健康状态
kubectl exec -it kafka-0 -- kafka-broker-api-versions --bootstrap-server localhost:9092
```

## 经验总结

### 关键教训

1. **Kubernetes 探针配置需要根据服务特性调整**：
   - 不要使用过于激进的探针配置
   - 对于有状态服务（如 Kafka），需要更宽松的失败阈值

2. **理解 Kafka KRaft 的特性**：
   - Controller 选举需要时间
   - Metadata 同步可能短暂影响响应
   - 需要给集群足够的恢复时间

3. **避免误杀循环**：
   - 一个节点的重启可能影响整个集群
   - 需要全局考虑探针配置的影响

### 最佳实践

1. **LivenessProbe 配置原则**：
   - 对于有状态服务，使用较大的 `failureThreshold`
   - 根据服务启动时间设置 `initialDelaySeconds`
   - 避免过短的 `periodSeconds`，减少对服务的压力

2. **ReadinessProbe vs LivenessProbe**：
   - `readinessProbe`：可以相对敏感，只影响流量路由
   - `livenessProbe`：需要更保守，避免误杀导致的服务中断

3. **监控和告警**：
   - 监控 Controller 切换频率
   - 监控 broker 重启次数
   - 设置合理的告警阈值

### 预防措施

1. **测试探针配置**：
   - 在测试环境验证探针配置
   - 模拟高负载、网络抖动等场景

2. **渐进式调整**：
   - 不要一次性大幅修改探针参数
   - 逐步调整，观察效果

3. **文档化配置**：
   - 记录每个探针配置的原因
   - 便于后续维护和问题排查

## 相关资源

- [Kubernetes Liveness and Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Kafka KRaft Controller](https://kafka.apache.org/documentation/#kraft)






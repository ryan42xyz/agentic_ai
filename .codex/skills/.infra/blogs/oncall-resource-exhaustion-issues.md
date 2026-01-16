# Kubernetes 资源不足问题处理指南

在 Kubernetes 环境中进行 oncall 期间，资源不足是常见的问题之一。本文档提供了处理各种资源限制问题的指导，包括但不限于磁盘空间不足、CPU 和内存压力等。

## 1. AWS 磁盘资源不足

### 1.1 问题识别

磁盘资源不足的常见症状：

- Pod 调度失败，错误信息包含 `no space left on device`
- 节点状态显示 `DiskPressure: True`
- 服务突然变得不可用或响应缓慢
- 日志写入失败

检查方法：

```bash
# 查看节点状态
kubectl get nodes
kubectl describe node <node-name>

# 查看特定节点的磁盘使用情况
df -h

# 获取 AWS EC2 实例的磁盘信息
aws ec2 describe-instances --instance-ids <instance-id> --query "Reservations[*].Instances[*].[InstanceId, BlockDeviceMappings[*].Ebs.VolumeId, BlockDeviceMappings[*].Ebs.VolumeSize]" --output table
```

### 1.2 磁盘清理方法

1. **清理 Docker 资源**：

```bash
# 清理未使用的 Docker 镜像、容器和网络
docker system prune -f

# 更深层次清理，包括未被引用的卷
docker system prune -a --volumes -f
```

2. **清理日志文件**：

```bash
# 找出大型日志文件
find /var/log -type f -name "*.log" -size +100M

# 清理或压缩日志
journalctl --vacuum-time=1d  # 仅保留最近一天的 journald 日志
```

3. **清理 kubelet 和容器运行时相关文件**：

```bash
# 清理已经终止的容器
crictl rmi --prune
```

4. **清理临时文件**：

```bash
# 清理 /tmp 目录
find /tmp -type f -atime +10 -delete
```

### 1.3 Node Drain 操作

当磁盘清理无法解决问题时，可能需要排空（drain）节点以重新分配资源：

```bash
# 标记节点为不可调度
kubectl cordon <node-name>

# 将节点上的 Pod 迁移到其他节点
kubectl drain <node-name> --ignore-daemonsets --delete-local-data
```

**潜在影响**：
- 服务可能短暂中断，特别是没有足够副本的服务
- 如果集群资源紧张，Pod 可能无法在其他节点上重新调度
- StatefulSet 的 Pod 会重新创建，但保留相同的 PVC
- 本地存储数据可能会丢失（如果使用了 `--delete-local-data` 选项）

**最佳实践**：
- 在非高峰时段执行 drain 操作
- 确保关键服务有足够的副本数
- 为关键服务设置 PodDisruptionBudget 限制同时中断的 Pod 数量
- 先测试单个非关键节点

### 1.4 磁盘扩容

当清理无效时，需要扩展 AWS EBS 卷：

```bash
# 获取卷 ID
aws ec2 describe-instances --instance-ids <instance-id> --query "Reservations[*].Instances[*].BlockDeviceMappings[*].Ebs.VolumeId" --output text

# 修改卷大小
aws ec2 modify-volume --volume-id <volume-id> --size <new-size-in-gb>

# 扩展文件系统（在实例上执行）
resize2fs /dev/<device-name>  # 对于 ext4 文件系统
xfs_growfs /mountpoint  # 对于 XFS 文件系统
```

**注意事项**：
- 增加卷大小不需要停止实例，但可能需要重启特定服务
- AWS EBS 卷只能增大不能减小
- 扩容后需要扩展文件系统以使用新增的空间

## 2. 节点 CPU/内存资源不足

### 2.1 问题识别

```bash
# 检查节点资源使用情况
kubectl top nodes
kubectl describe node <node-name>

# 检查高 CPU/内存使用的 Pod
kubectl top pods --all-namespaces
```

### 2.2 解决方法

1. **调整 Pod 资源限制**：

```bash
# 编辑 deployment 调整资源请求和限制
kubectl edit deployment <deployment-name>
```

修改 `resources.requests` 和 `resources.limits` 对 CPU 和内存的设置。

2. **水平扩展 Pod**：

```bash
kubectl scale deployment <deployment-name> --replicas=<number>
```

3. **驱逐低优先级 Pod**：

```bash
# 手动删除不重要的 Pod
kubectl delete pod <pod-name>
```

4. **节点操作**：
   - 如上所述执行 drain 操作
   - 考虑添加新节点到集群

## 3. PersistentVolume 容量问题

### 3.1 问题识别

```bash
# 检查 PVC 状态
kubectl get pvc --all-namespaces
kubectl describe pvc <pvc-name>
```

### 3.2 解决方法

1. **扩展现有 PVC** (如果 StorageClass 支持卷扩展)：

```bash
kubectl edit pvc <pvc-name>
# 修改 spec.resources.requests.storage 字段
```

2. **创建新的更大 PVC 并迁移数据**：
   - 创建新 PVC
   - 部署临时 Pod 挂载两个 PVC
   - 从旧卷拷贝数据到新卷
   - 更新应用使用新 PVC

### 3.3 使用 AWS EBS 扩容

对于 AWS EBS 后端的 PVC，可以：

```bash
# 获取 PV 对应的 EBS 卷 ID
kubectl describe pv <pv-name>

# 使用 AWS CLI 扩容
aws ec2 modify-volume --volume-id <volume-id> --size <new-size-in-gb>

# 更新 PVC 对象以请求新大小
kubectl patch pvc <pvc-name> -p '{"spec":{"resources":{"requests":{"storage":"<new-size>Gi"}}}}'
```

## 4. 其他资源限制问题

### 4.1 网络资源限制

症状与解决方案：
- **节点网络接口达到带宽限制**
  - 监控网络流量并识别高流量 Pod
  - 考虑使用更高带宽的实例类型
  - 实现网络流量限制策略

- **连接数达到限制**
  - 增加节点 `fs.file-max` 和 `net.ipv4.ip_local_port_range`
  - 确保应用适当关闭连接
  - 考虑使用连接池

### 4.2 API Server 资源限制

症状与解决方案：
- **API Server 请求过多**
  - 优化客户端请求频率
  - 增加 API Server 资源
  - 实现流量控制和请求限速

- **etcd 性能问题**
  - 监控 etcd 指标
  - 清理不必要的资源
  - 考虑使用 SSD 存储和更高性能实例

## 5. 预防措施

### 5.1 主动监控

设置以下指标的告警：
- 节点磁盘使用率（警告：>75%，严重：>85%）
- 节点 CPU 和内存使用率
- Pod 资源使用与限制比例
- PVC 使用率

### 5.2 资源配额

对命名空间设置资源配额：

```bash
kubectl create quota <quota-name> --namespace=<namespace> \
  --hard=requests.cpu=<cpu-limit>,requests.memory=<memory-limit>,limits.cpu=<cpu-limit>,limits.memory=<memory-limit>
```

### 5.3 集群自动伸缩

配置 Kubernetes Cluster Autoscaler 以自动调整集群大小应对资源需求。

### 5.4 定期清理

建立定期清理任务：
- 删除完成的作业和相关 Pod
- 清理不使用的 Docker 镜像
- 归档旧日志文件

## 6. 文档资源

- [Kubernetes 官方文档：资源压力](https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/)
- [AWS EBS 卷修改指南](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/requesting-ebs-volume-modifications.html)
- [Kubernetes 最佳实践：资源管理](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

# On-Call 事件复盘：ClickHouse 服务连接失败

## 📅 事件时间
2025-09-29  

## 📝 现象
- Spring Boot 应用启动时，HikariPool 初始化失败。
- 日志报错：
  ```
  Connection refused (Connection refused), server ClickHouseNode [uri=http://clickhouse:8123/default]
  ```
- `kubectl get endpoints` 显示 `clickhouse` 和 `clickhouse-dv` Service 的 `ENDPOINTS <none>`，导致无法通过 Service DNS 访问 ClickHouse。

## 🔍 排查过程
1. **检查 Service**  
   - 查看 `clickhouse`、`clickhouse-dv` Service，发现 `ENDPOINTS <none>`。  
   - Service selector 要求 `clickhouse.altinity.com/ready=yes`。

2. **检查 Pod 状态**  
   - Pod `chi-dv-datavisor-0-0-0` Running 且容器 Ready。  
   - 但 Pod 标签 `clickhouse.altinity.com/ready=no`，与 Service selector 不匹配。

3. **分析原因**  
   - ClickHouse Operator 使用 `ready=yes/no` 标记 Pod 的对外可用状态。  
   - Pod 因异常重启导致 Operator 未及时刷新状态，label 仍为 `no`，因此 Service 没有 endpoint，导致连接拒绝。

4. **临时绕过**  
   - 使用 Pod DNS `chi-dv-datavisor-0-0-0.qa-security.svc.cluster.local:8123` 可直接访问 ClickHouse，验证 ClickHouse 实际运行正常。

5. **最终解决**  
   - 执行 Pod 重启：  
     ```bash
     kubectl rollout restart statefulset chi-dv-datavisor-0-0 -n qa-security
     ```
   - Pod 重启后，Operator 将 `ready` 改为 `yes`，Service endpoint 恢复正常。

## 🛠 原因定位
- ClickHouse Pod 异常重启后，Altinity ClickHouse Operator 未正确刷新 `clickhouse.altinity.com/ready` 标签。
- Service selector 要求 `ready=yes`，导致无 endpoint。
- 应用通过 Service 访问 ClickHouse 失败，引发 `Connection refused`。

## ✅ 解决方案
- 重启 ClickHouse Pod / StatefulSet，使 Operator 重新标记 `ready=yes`。
- Spring Boot 应用恢复正常连接。

## 🚀 预防措施
- 对 ClickHouse Pod 增加健康检查和告警，监控 `clickhouse.altinity.com/ready` 状态。
- 关键路径增加 Pod DNS 直连或重试机制，避免因 Service endpoint 短暂丢失导致应用启动失败。
- 定期升级 ClickHouse Operator，修复可能的状态刷新 bug。

```bash
kwestdeva logs -n qa-security sdg-apiserver-856fbbc948-pw7h7 --tail=100

kwestdeva get -n qa-security pod | grep chi 
kwestdeva get -n qa-security svc
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                                                      AGE
admin-ui                  NodePort    10.104.227.250   <none>        8080:32051/TCP                                                               376d
admin-ui-dummy-service    ClusterIP   None             <none>        8888/TCP                                                                     376d
chi-dv-datavisor-0-0      ClusterIP   None             <none>        9000/TCP,8123/TCP,9009/TCP                                                   376d
clickhouse                NodePort    10.106.64.96     <none>        9000:30782/TCP,8123:30299/TCP,9009:31071/TCP,8001:30395/TCP,9004:32545/TCP   376d
clickhouse-dv             ClusterIP   10.98.200.195    <none>        8123/TCP,9000/TCP,9009/TCP,8001/TCP,9004/TCP                                 376d


kwestdeva get -n qa-security pod chi-dv-datavisor-0-0-0
chi-dv-datavisor-0-0-0                              2/2     Running            0                25h

kwestdeva exec -it -n qa-security pod chi-dv-datavisor-0-0-0
kwestdeva exec -it chi-dv-datavisor-0-0-0 -n qa-security -- bash

kwestdeva get endpoints clickhouse-dv -n qa-security

kwestdeva get pods -n qa-security --show-labels | grep chi-dv-datavisor

kwestdeva get svc clickhouse-dv -n qa-security -o yaml | grep -A5 selector
kwestdeva get svc clickhouse -n qa-security -o yaml | grep -A5 selector

kwestdeva describe pod chi-dv-datavisor-0-0-0 -n qa-security
kwestdeva logs chi-dv-datavisor-0-0-0 -n qa-security -c <clickhouse-container>

  kwestdeva get endpoints clickhouse -n qa-security
NAME         ENDPOINTS                                                              AGE
clickhouse   192.168.82.84:8123,192.168.82.84:8001,192.168.82.84:9009 + 2 more...   377d
```
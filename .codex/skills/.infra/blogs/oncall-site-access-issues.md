1. 打不开某个网站 - 找到对应的cluster - 找到对应的pod/service - check service's status
    - The service is okay. And i can open on my side..  / Can you try with incognito mode?"

    - 能不能ping 通？
        - 能
        - 不能
            - 服务是否存在
                - service / ingress 等
                    - 这一块如何工作的，还不是特别清楚
                    - 特别是增加了aws 之后
                - 另外还有一些api gateway
                    - 某个链路上有哪些服务？我怎么看？
                    --- 表层是一个dns，深层是什么？
```
   # 在Kubernetes Pod内部测试
   kubectl --kubeconfig=/path/to/config -n default run dnsutils --rm -it --image=gcr.io/kubernetes-e2e-test-images/dnsutils:1.3 -- bash
   # 执行诊断
   dig +short service.namespace.svc.cluster.local
   dig +short external-service.example.com
```

# 网站无法访问的完整调试指南

## 1. 隔离问题范围

### 初步检查
* **用户端检查**：
  - 询问用户是否只有特定页面无法访问，还是整个网站
  - 请用户尝试无痕模式/清除缓存后再试
  - 确认是否特定设备或特定网络环境下出现问题
  - 请用户提供错误截图或错误代码

### 基础网络检查
* **DNS解析检查**：
  ```bash
  dig +short <网站域名>
  nslookup <网站域名>
  ```
* **连通性测试**：
  ```bash
  ping <网站域名或IP>
  telnet <网站域名或IP> 80/443
  curl -v <网站URL>
  ```

## 2. 服务端检查 (Kubernetes)

### 确定对应的集群和资源
* **列出集群**：
  ```bash
  kubectl config get-contexts
  # 或使用已设置的别名
  # kdev / kwest / keast 等
  ```

* **定位相关资源**：
  ```bash
  # 假设我们知道相关命名空间和服务名
  kubectl --kubeconfig=/path/to/config get ns
  kubectl --kubeconfig=/path/to/config -n <namespace> get pods,svc,ing
  ```

### 检查Pod状态
* **检查Pod是否运行正常**：
  ```bash
  kubectl --kubeconfig=/path/to/config -n <namespace> get pods
  kubectl --kubeconfig=/path/to/config -n <namespace> describe pod <pod-name>
  ```

* **检查Pod日志**：
  ```bash
  kubectl --kubeconfig=/path/to/config -n <namespace> logs <pod-name> -c <container-name> --tail=100
  # 如果Pod重启过，检查上一个容器的日志
  kubectl --kubeconfig=/path/to/config -n <namespace> logs <pod-name> -c <container-name> --previous
  ```

### 检查Service和Ingress
* **检查Service**：
  ```bash
  kubectl --kubeconfig=/path/to/config -n <namespace> describe svc <service-name>
  # 确认endpoints是否有正常的Pod IP
  ```

* **检查Ingress资源**：
  ```bash
  kubectl --kubeconfig=/path/to/config -n <namespace> get ing
  kubectl --kubeconfig=/path/to/config -n <namespace> describe ing <ingress-name>
  ```

### 从集群内部测试服务
* **创建临时测试Pod**：
  ```bash
  kubectl --kubeconfig=/path/to/config -n <namespace> run temp-debug --rm -i --tty --image=nicolaka/netshoot -- /bin/bash
  # 进入Pod后进行测试
  curl http://<service-name>:<port>
  ```

## 3. AWS相关检查

### 负载均衡器检查
* **确定关联的ALB/NLB/CLB**：
  ```bash
  # 查看ingress-controller的Service类型为LoadBalancer的ELB
  kubectl --kubeconfig=/path/to/config -n <ingress-namespace> get svc
  
  # 通过AWS CLI查询负载均衡器
  aws elbv2 describe-load-balancers | grep <部分ELB名称>
  aws elbv2 describe-target-groups --load-balancer-arn <ALB-ARN>
  aws elbv2 describe-target-health --target-group-arn <Target-Group-ARN>
  ```

* **检查安全组设置**：
  ```bash
  # 获取负载均衡器关联的安全组
  aws elbv2 describe-load-balancers --names <ALB-Name> --query 'LoadBalancers[0].SecurityGroups'
  
  # 检查安全组规则
  aws ec2 describe-security-groups --group-ids <Security-Group-ID>
  ```

### 网络与路由检查
* **检查VPC和子网配置**：
  ```bash
  # 查看VPC和子网
  aws ec2 describe-subnets --filters "Name=vpc-id,Values=<VPC-ID>"
  
  # 检查路由表
  aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<VPC-ID>"
  ```

* **检查ACL和网络策略**：
  ```bash
  aws ec2 describe-network-acls --filters "Name=vpc-id,Values=<VPC-ID>"
  ```

### Route 53和CDN检查
* **检查DNS记录**：
  ```bash
  aws route53 list-hosted-zones
  aws route53 list-resource-record-sets --hosted-zone-id <Zone-ID> | grep <domain-name>
  ```

* **如果使用CloudFront**：
  ```bash
  aws cloudfront list-distributions | grep <domain-name>
  aws cloudfront get-distribution --id <Distribution-ID>
  ```

## 4. 深入排查技巧

### 链路追踪
* **使用aws X-Ray或兼容工具**查找服务调用链中的问题
* **检查Prometheus/Grafana**中的服务指标和延迟数据
* **用tcpdump或wireshark**分析网络流量

### 服务网格(如使用Istio)
* **检查VirtualService和Gateway**:
  ```bash
  kubectl --kubeconfig=/path/to/config -n <namespace> get virtualservice,gateway
  kubectl --kubeconfig=/path/to/config -n <namespace> describe virtualservice <name>
  ```

* **检查服务网格状态**:
  ```bash
  istioctl analyze -n <namespace>
  istioctl proxy-status
  ```

## 5. 服务接入链路梳理

### 从用户到服务的完整链路
1. **用户 → DNS解析**
   - 通过Route 53或其他DNS服务将域名解析到ELB IP

2. **DNS → 负载均衡器**
   - ALB/NLB/CLB接收流量
   - WAF/Shield(如果配置)进行过滤

3. **负载均衡器 → Kubernetes Ingress**
   - 流量转发至Ingress Controller Pod
   - Ingress Controller根据规则路由流量

4. **Ingress → Service → Pod**
   - 流量路由到对应Service
   - kube-proxy将流量分发到Pod

5. **Pod内应用处理请求**
   - 应用可能进一步调用其他后端服务

### 如何查看完整链路
* **绘制网络拓扑图**可视化流量路径
* **使用追踪工具**如Jaeger追踪请求流程
* **检查API Gateway配置**如果使用API Gateway

## 6. 常见问题和解决方案

### Pod无法启动或频繁重启
* 检查资源限制(CPU/内存)
* 检查liveness/readiness探针配置
* 检查镜像版本和配置

### 网络连接问题
* 检查网络策略/NetworkPolicy
* 验证DNS解析(CoreDNS)正常
* 检查Service CIDR和Pod CIDR配置

### 负载均衡器问题
* 健康检查失败
* 后端实例注册问题
* 安全组或ACL限制

### 安全相关问题
* 证书过期或配置错误
* WAF规则错误拦截请求
* CORS配置问题

## 7. 扩展监控和报警

* 设置**黑盒监控**定期检查服务可用性
* 配置**SLO/SLI**监控关键服务性能指标
* 使用**分布式追踪**发现服务间调用问题
* 实现**合成监控**模拟真实用户行为

## 8. 防止问题再次发生

* 建立详细的**运维手册**记录解决步骤
* 实施**渐进式发布**和**自动回滚**机制
* 引入**混沌工程**测试系统弹性
* 进行**事后分析**并更新监控和报警策略
# Kubernetes Ingress 配置完整指南

本指南详细说明如何为 Kubernetes Deployment 配置 Ingress，包括创建所需的所有资源，从 Kubernetes 集群内的配置到 AWS 上的资源设置。

## 目录
- [Kubernetes Ingress 配置完整指南](#kubernetes-ingress-配置完整指南)
  - [目录](#目录)
  - [前提条件](#前提条件)
  - [步骤 1: 验证 Deployment](#步骤-1-验证-deployment)
  - [步骤 2: 创建 Service](#步骤-2-创建-service)
  - [步骤 3: 确认 AWS Load Balancer Controller](#步骤-3-确认-aws-load-balancer-controller)
  - [步骤 4: 创建 Ingress](#步骤-4-创建-ingress)
  - [步骤 5: Route 53 DNS 配置](#步骤-5-route-53-dns-配置)
  - [步骤 6: 验证配置](#步骤-6-验证配置)
  - [故障排查](#故障排查)
  - [参考资料](#参考资料)

## 前提条件

- 已有运行的 Kubernetes 集群
- 已安装 `kubectl` 并配置正确的集群访问权限
- 已安装 AWS CLI 并配置正确的凭证
- 已有 AWS 证书管理器（ACM）证书（如需 HTTPS）
- 已有 Route 53 托管区域

## 步骤 1: 验证 Deployment

确认现有 Deployment 状态：

```bash
# 检查 Deployment 状态
kubectl get deployment <deployment-name> -n <namespace>

# 确认 Pod 是否正常运行
kubectl get pods -n <namespace> | grep <deployment-name>
```

## 步骤 2: 创建 Service

1. 创建 Service 配置文件 `service.yaml`：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <service-name>
  namespace: <namespace>
spec:
  selector:
    app: <deployment-label>  # 必须匹配 Deployment 中 Pod 的标签
  ports:
    - protocol: TCP
      port: 80              # Service 端口
      targetPort: 8080      # 容器端口
  type: ClusterIP          # 使用 ClusterIP，因为我们会通过 Ingress 暴露服务
```

2. 应用 Service 配置：

```bash
kubectl apply -f service.yaml
```

## 步骤 3: 确认 AWS Load Balancer Controller

1. 检查控制器状态：

```bash
# 检查 AWS Load Balancer Controller 是否运行
kubectl get deployment -n kube-system aws-load-balancer-controller

# 检查 IngressClass 是否存在
kubectl get ingressclass
```

## 步骤 4: 创建 Ingress

1. 创建 Ingress 配置文件 `ingress.yaml`：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <ingress-name>
  namespace: <namespace>
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": {"Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:region:account-id:certificate/certificate-id
    alb.ingress.kubernetes.io/security-groups: sg-xxx,sg-yyy
spec:
  rules:
    - host: your-domain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: <service-name>
                port:
                  number: 80
```

2. 应用 Ingress 配置：

```bash
kubectl apply -f ingress.yaml
```

## 步骤 5: Route 53 DNS 配置

1. 获取 ALB DNS 名称：

```bash
export ALB_DNS=$(kubectl get ingress <ingress-name> -n <namespace> -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo $ALB_DNS
```

2. 创建 Route 53 记录集：

```bash
# 获取托管区域 ID
export ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "your-domain.com." \
  --query "HostedZones[0].Id" --output text | sed 's/\/hostedzone\///')

# 创建 JSON 配置文件
cat > route53-change.json << EOF
{
  "Comment": "Creating alias record for ALB",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "your-domain.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "ZXXXXXXXXXX",  # ALB 的托管区域 ID
          "DNSName": "$ALB_DNS",
          "EvaluateTargetHealth": true
        }
      }
    }
  ]
}
EOF

# 应用 DNS 更改
aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch file://route53-change.json
```

注意：
- 替换 `ZXXXXXXXXXX` 为实际的 ALB 托管区域 ID（这是固定值，取决于 ALB 所在的 AWS 区域）
- 确保 `your-domain.com` 替换为实际的域名
- 如果需要添加子域名，修改 "Name" 字段（例如：`api.your-domain.com`）

## 步骤 6: 验证配置

1. 检查资源状态：

```bash
# 检查 Service 状态
kubectl get svc <service-name> -n <namespace>

# 检查 Ingress 状态
kubectl get ingress <ingress-name> -n <namespace>

# 检查 ALB 状态
aws elbv2 describe-load-balancers

# 检查 DNS 传播
dig your-domain.com
```

2. 测试访问：

```bash
# 测试 HTTP 访问
curl -v http://your-domain.com

# 测试 HTTPS 访问
curl -v https://your-domain.com
```

## 故障排查

如果遇到问题，按以下步骤排查：

1. 检查 Pod 状态：
```bash
kubectl get pods -n <namespace>
kubectl logs -f <pod-name> -n <namespace>
```

2. 检查 Service 端点：
```bash
kubectl get endpoints <service-name> -n <namespace>
```

3. 检查 Ingress 控制器日志：
```bash
kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller
```

4. 检查 ALB 配置：
```bash
# 检查目标组健康状态
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# 检查安全组配置
aws ec2 describe-security-groups --group-ids sg-xxx
```

5. 检查 DNS 解析：
```bash
# 检查 DNS 记录
aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID \
  --query "ResourceRecordSets[?Name == 'your-domain.com.']"

# 验证 DNS 解析
dig +trace your-domain.com
```

常见问题：
1. ALB 安全组配置不正确
2. 目标组健康检查失败
3. DNS 记录未正确配置
4. 证书 ARN 不正确或证书无效
5. Pod 未就绪或服务端口配置错误

## 参考资料

- [AWS Load Balancer Controller 文档](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Kubernetes Ingress 文档](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Route 53 开发者指南](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/) 
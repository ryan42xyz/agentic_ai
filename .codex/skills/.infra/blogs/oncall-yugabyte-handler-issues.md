一个典型的yuga 处理过程，涉及到业务（fp）和基础组件（mirror maker）

1. offerup 切到A
2. 关闭Kafka mirror maker (a&b)
kubectl scale --replicas 0 deployment -n prod  mirrormaker2 
3. 重启yugabyte yb-master all node
systemctl restart yb-master
4. 重启yugabyte yb-tserver all node
systemctl restart yb-tserver
5. 等待yugabyte balance
6. 添加new node 到 aws-useast1-prod-b-yb-ext-prod  LB https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#TargetGroup:targetGroupArn=arn:aws:elasticloadbalancing:us-east-1:480609039449:targetgroup/aws-useast1-prod-b-yb-ext-prod/acf8b6179eda946b
7. 重启fp/fp-async
8. 启动 kafka mirror maker
8. offerup 切回B


```mermaid
sequenceDiagram
    participant OfferUp
    participant FP
    participant MirrorMaker
    participant YBMaster
    participant YBTServer
    participant AWS_LB

    Note over OfferUp: 切流量到A区
    OfferUp->>FP: 切流量至A区

    Note over MirrorMaker: 停止Kafka双向同步
    FP->>MirrorMaker: kubectl scale --replicas=0

    Note over YBMaster,YBTServer: 重启Yugabyte各节点
    FP->>YBMaster: systemctl restart yb-master (all)
    FP->>YBTServer: systemctl restart yb-tserver (all)

    Note over YBMaster,YBTServer: 等待集群balance完成
    YBMaster->>YBMaster: 等待Balance完成

    Note over AWS_LB: 添加新节点进B区LB
    FP->>AWS_LB: Add node to aws-useast1-prod-b-yb-ext-prod LB

    Note over FP: 重启FP服务
    FP->>FP: restart fp / fp-async

    Note over MirrorMaker: 恢复Kafka同步
    FP->>MirrorMaker: kubectl scale --replicas=N

    Note over OfferUp: 切流量回B区
    OfferUp->>FP: 切回流量至B区

```

```mermaid
graph TD
  subgraph Cluster_A [Cluster A - Primary]
    A_Kafka[Kafka A]
    A_YBMaster[YB-Master A]
    A_YBTServer[YB-TServer A]
    FP_A[FP A]
    FPAsync_A[FP-Async A]
  end

  subgraph Cluster_B [Cluster B - Backup]
    B_Kafka[Kafka B]
    B_YBMaster[YB-Master B]
    B_YBTServer[YB-TServer B]
    FP_B[FP B]
    FPAsync_B[FP-Async B]
  end

  subgraph Sync_Layer [Kafka MirrorMaker]
    MirrorMaker1[MirrorMaker A to B]
    MirrorMaker2[MirrorMaker B to A]
  end

  %% Kafka 消费流向
  A_Kafka --> FP_A
  A_Kafka --> FPAsync_A
  B_Kafka --> FP_B
  B_Kafka --> FPAsync_B

  %% MirrorMaker 双向同步
  A_Kafka --> MirrorMaker1 --> B_Kafka
  B_Kafka --> MirrorMaker2 --> A_Kafka

  %% FP写入 Yugabyte
  FP_A --> A_YBTServer --> A_YBMaster
  FP_B --> B_YBTServer --> B_YBMaster

  %% Yugabyte 跨集群同步（如果有）
  A_YBMaster -.-> B_YBMaster
  A_YBTServer -.-> B_YBTServer

```
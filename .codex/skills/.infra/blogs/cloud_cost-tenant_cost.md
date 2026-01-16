# OneFinance 成本占比计算总结（2025-09）

## Cluster 架构
| 集群 | 类型 | 实例规格 | 节点数 | 存储配置 |
|------|------|-----------|--------|-----------|
| aws-useast1-prod-a | Yugabyte | i4i.8xlarge | 6 | 3.5 T × 2 |
| aws-useast1-prod-b | Yugabyte | i4i.8xlarge | 6 | 3.5 T × 2 |
| aws-useast1-prod-a | ClickHouse A | r7i.8xlarge | 1 |
| aws-useast1-prod-b | ClickHouse B | r7i.8xlarge | 1 |

---

## 1️⃣ Yugabyte 成本来源

```bash
# cluster a
aws ce get-cost-and-usage \
  --region us-east-1 \
  --time-period Start=2025-09-01,End=2025-10-01 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --filter '{"Tags": {"Key": "CostCenter","Values": ["prod:aws-useast1-prod-a:yugabytes"]}}' \
  --group-by Type=DIMENSION,Key=SERVICE \
  --output table

# cluster b
aws ce get-cost-and-usage \
  --region us-east-1 \
  --time-period Start=2025-09-01,End=2025-10-01 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --filter '{"Tags": {"Key": "CostCenter","Values": ["prod:aws-useast1-prod-b:yugabytes"]}}' \
  --group-by Type=DIMENSION,Key=SERVICE \
  --output table
```

| 集群 | Compute (EC2) | EC2-Other | Inspector | 小计 USD |
|------|---------------:|-----------:|-----------:|----------:|
| prod-a | 8699.33 | 18.38 | 0.72 | **8718.43** |
| prod-b | 8699.33 | 18.39 | 0.72 | **8718.44** |
| **合计 Yugabyte** | — | — | — | **11 447.15 USD** |

**存储占比**
```sql
SELECT
    database,
    formatReadableSize(sum(bytes_on_disk)) AS total_size,
    round((sum(bytes_on_disk) * 100.) / (
        SELECT sum(bytes_on_disk)
        FROM system.parts
        WHERE active
    ), 2) AS percent_of_total
FROM system.parts
WHERE active
GROUP BY database
ORDER BY sum(bytes_on_disk) DESC;
```
- Cluster A = 44.75 %  
- Cluster B = 44.4 %

---

## 2️⃣ ClickHouse 成本来源

```bash
# cluster a
aws ce get-cost-and-usage \
  --region us-east-1 \
  --time-period Start=2025-09-01,End=2025-10-01 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --filter '{"Tags":{"Key":"Name","Values":["k8s-aws-useast1-prod-a-r7i.8xlarge"]}}' \
  --query 'ResultsByTime[].Total.UnblendedCost.Amount' \
  --output text

# cluster b
aws ce get-cost-and-usage \
  --region us-east-1 \
  --time-period Start=2025-09-01,End=2025-10-01 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --filter '{"Tags":{"Key":"aws:autoscaling:groupName","Values":["k8s-aws-useast1-prod-b-r7i.8xlarge"]}}' \
  --query 'ResultsByTime[].Total.UnblendedCost.Amount' \
  --output text
```

| 集群 | EC2 Cost (USD) | 备注 |
|------|----------------:|------|
| prod-a | **3196.59** | `Name=k8s-aws-useast1-prod-a-r7i.8xlarge` |
| prod-b | **0** | 无账单数据 |

**ClickHouse 存储**
| 集群 | onefinance DB 占比 |
|------|--------------------|
| prod-a | 3.81 TiB → 36.12 % |
| prod-b | 3.72 TiB → 37.95 % |

---

## 3️⃣ Yugabyte 节点存储采样
```sh
curl https://cloud.dv-api.com/scripts_aws/count_yugabyte_disk.sh | bash -s -- "172.30.66.222:7100,172.30.76.58:7100,172.30.64.149:7100" onefinance
```
```
aws-useast1-prod-a
172.30.66.222: 1724.83 GB
172.30.76.58:  1727.51 GB
172.30.64.149: 1868.45 GB
172.30.68.74:  1777.32 GB
172.30.76.106: 1763.20 GB
172.30.67.229: 1695.92 GB
→ Total 10 556 GB (44.75 %)

aws-useast1-prod-b
172.30.47.4:   1686.55 GB
172.30.34.212: 1742.90 GB
172.30.44.161: 1690.27 GB
172.30.39.204: 1845.35 GB
172.30.34.5:   1852.91 GB
172.30.34.93:  1654.79 GB
→ Total 10 473 GB (44.4 %)
```

---

## 4️⃣ ClickHouse 节点存储采样

**查询命令**
```sql
SELECT
    database,
    formatReadableSize(sum(bytes_on_disk)) AS total_size,
    round((sum(bytes_on_disk) * 100.) / (
        SELECT sum(bytes_on_disk)
        FROM system.parts
        WHERE active
    ), 2) AS percent_of_total
FROM system.parts
WHERE active
GROUP BY database
ORDER BY sum(bytes_on_disk) DESC;
```

**aws-useast1-prod-a (Cluster A)**
```
    ┌─database────────────────┬─total_size─┬─percent_of_total─┐
 1. │ galileo                 │ 4.02 TiB   │            38.16 │
 2. │ onefinance              │ 3.81 TiB   │            36.12 │
 3. │ system                  │ 916.83 GiB │              8.5 │
 4. │ offerup                 │ 847.21 GiB │             7.85 │
 5. │ affirm                  │ 603.73 GiB │             5.59 │
 6. │ westernunion            │ 106.21 GiB │             0.98 │
 7. │ tabapay                 │ 96.79 GiB  │              0.9 │
 8. │ dci                     │ 90.13 GiB  │             0.84 │
 9. │ mybambu                 │ 74.07 GiB  │             0.69 │
10. │ aspiration              │ 24.79 GiB  │             0.23 │
11. │ uopx                    │ 7.65 GiB   │             0.07 │
12. │ nymbus                  │ 3.68 GiB   │             0.03 │
13. │ acorns                  │ 3.07 GiB   │             0.03 │
14. │ dcibankoforrick         │ 537.30 MiB │                0 │
15. │ westernunionib          │ 417.57 MiB │                0 │
16. │ happymoney              │ 320.08 MiB │                0 │
17. │ fedex                   │ 218.70 MiB │                0 │
18. │ broxel                  │ 56.27 MiB  │                0 │
19. │ dciponcebank            │ 3.93 MiB   │                0 │
20. │ internal_sink_connector │ 3.63 MiB   │                0 │
21. │ qaautotest              │ 3.40 MiB   │                0 │
22. │ avidxchange             │ 3.36 MiB   │                0 │
23. │ autoswitchtraffic       │ 2.90 KiB   │                0 │
24. │ peoplesbank             │ 2.89 KiB   │                0 │
25. │ anb                     │ 2.89 KiB   │                0 │
    └─────────────────────────┴────────────┴──────────────────┘
→ onefinance: 3.81 TiB (36.12 %)
```

**aws-useast1-prod-b (Cluster B)**
```
    ┌─database────────────────┬─total_size─┬─percent_of_total─┐
 1. │ onefinance              │ 3.72 TiB   │            37.95 │
 2. │ galileo                 │ 3.56 TiB   │            36.26 │
 3. │ offerup                 │ 854.35 GiB │              8.5 │
 4. │ system                  │ 748.04 GiB │             7.44 │
 5. │ affirm                  │ 599.37 GiB │             5.96 │
 6. │ westernunion            │ 105.49 GiB │             1.05 │
 7. │ tabapay                 │ 96.81 GiB  │             0.96 │
 8. │ dci                     │ 77.04 GiB  │             0.77 │
 9. │ mybambu                 │ 73.97 GiB  │             0.74 │
10. │ aspiration              │ 24.36 GiB  │             0.24 │
11. │ uopx                    │ 7.29 GiB   │             0.07 │
12. │ nymbus                  │ 3.62 GiB   │             0.04 │
13. │ acorns                  │ 889.46 MiB │             0.01 │
14. │ dcibankoforrick         │ 475.13 MiB │                0 │
15. │ westernunionib          │ 413.13 MiB │                0 │
16. │ happymoney              │ 259.12 MiB │                0 │
17. │ fedex                   │ 218.70 MiB │                0 │
18. │ broxel                  │ 56.99 MiB  │                0 │
19. │ dciponcebank            │ 3.74 MiB   │                0 │
20. │ avidxchange             │ 3.35 MiB   │                0 │
21. │ qaautotest              │ 3.31 MiB   │                0 │
22. │ internal_sink_connector │ 60.97 KiB  │                0 │
23. │ autoswitchtraffic       │ 3.91 KiB   │                0 │
24. │ peoplesbank             │ 3.91 KiB   │                0 │
25. │ anb                     │ 2.89 KiB   │                0 │
26. │ juntest20220712         │ 230.00 B   │                0 │
    └─────────────────────────┴────────────┴──────────────────┘
→ onefinance: 3.72 TiB (37.95 %)
```

---

## 5️⃣ 成本汇总与 OneFinance 占比

### Yugabyte
```
Total = 8718.43 + 8718.44 = 17 436.87 USD
OneFinance ≈ 17 436.87 × (44.75 % + 44.4 %) / 2 ≈ 7 800 USD
```

### ClickHouse
```
Total = 3196.59 USD
OneFinance ≈ 3196.59 × (36.12 % + 37.95 %) / 2 ≈ 1 150 USD
```

---

## ✅ 最终结果
| 项目 | Cluster A 占比 | Cluster B 占比 | OneFinance 成本 (USD) |
|------|----------------|----------------|----------------------:|
| **Yugabyte** | 44.75 % | 44.4 % | ≈ 7 800 |
| **ClickHouse** | 36.12 % | 37.95 % | ≈ 1 150 |
| **总计 (OneFinance)** | — | — | **≈ 8 950 USD /月** |

---

## 📘 数据来源
- AWS Cost Explorer (`aws ce get-cost-and-usage`)
- EC2 Tags: `CostCenter`, `Name`, `aws:autoscaling:groupName`
- ClickHouse `system.parts` 数据库存储查询
- Yugabyte 节点 `du -sm table-*` 采样
- ClickHouse 节点数据库占比分析

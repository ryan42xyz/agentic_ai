# Oncall 排查流程（DB/业务故障场景）

## 一、看 DB 层面

1. **确认 ClickHouse 是否恢复**
   - 检查 pod 状态：
     ```bash
     kubectl get pods -n <namespace> | grep clickhouse
     ```
   - 检查 error log：
     ```bash
     kubectl logs <clickhouse-pod>
     ```
   - 这是最基本的确认动作。

2. **确认 ClickHouse 什么时候挂的**
   - **Pod status**：看 RESTARTS、LAST RESTART TIME
   - **日志**：分析挂掉的原因（资源不足 / crash / 网络）。

## 二、看业务层面

1. **确认业务是否恢复**
   - 检查 fp 等依赖 DB 的服务：
     ```bash
     kubectl get pods -n <namespace> | grep fp
     ```
   - 看 error log：
     ```bash
     kubectl logs <fp-pod>
     ```

2. **是否需要重启业务**
   - 如果业务自己还没恢复，要确认是否需要重启（但不要自己动手，应让业务 owner 操作）。

## Mermaid 流程图
```mermaid
flowchart TD
    A[发现 ClickHouse/yt/MySQL 挂了] --> B[检查 DB 状态]
    B --> B1[确认是否恢复: Pod status 和 error log]
    B --> B2[确认挂掉时间: Pod status 和日志原因]

    A --> C[检查业务服务状态]
    C --> C1[确认是否恢复: status 和 error log]
    C --> C2{业务是否恢复正常}
    C2 -->|是| D[记录结果 完成]
    C2 -->|否| E[是否需要重启业务服务]

    E --> F[联系业务 owner 由其决定是否重启]
    F --> D
```

## 总结
这样排下来：
- 先看 DB → 再看业务 → 最后决定是否需要业务重启。
- 严格区分责任边界：DB 这边确认、记录，业务服务重启交给 owner。
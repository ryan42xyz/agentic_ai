# Data Copy Strategies

## MySQL / ClickHouse 的方案

复制数据时，直接利用 AWS 的 EBS 快照（snapshot）。

### 流程
1. 创建 EBS snapshot
2. 用 snapshot 恢复出新的卷
3. 替换原来的 PVC / PV
4. 达到数据复制的效果

**好处**: 速度快，直接在存储层面复制  
**缺点**: 强依赖 EBS。

---

## YugabyteDB 的方案

Yugabyte 不走 EBS 快照的方式，而是用官方或自定义的 backup/restore 脚本。

也就是说，不是直接复制底层磁盘，而是通过 Yugabyte 提供的逻辑备份机制（如 `yb_backup.py` 之类的工具）。

当触发 copydata 流程时，会根据传入的参数（比如数据库名、目标集群、命名空间等）去启动一个 restore job，自动执行备份数据的恢复操作。

### 换句话说：
- **MySQL/ClickHouse**: 像是“复制硬盘”的方式（EBS snapshot）。
- **YugabyteDB**: 像是“用数据库自己的备份/恢复工具重新导入”的方式。

---

## 流程图

```mermaid
flowchart TB
    subgraph MySQL
        A1[触发 CopyData 请求] --> A2[创建 AWS EBS Snapshot]
        A2 --> A3[用 Snapshot 恢复新卷]
        A3 --> A4[替换 PVC / PV]
        A4 --> A5[完成数据复制]
    end

    subgraph ClickHouse
        B1[触发 CopyData 请求] --> B2[创建 AWS EBS Snapshot]
        B2 --> B3[用 Snapshot 恢复新卷]
        B3 --> B4[替换 PVC / PV]
        B4 --> B5[完成数据复制]
    end

    subgraph YugabyteDB
        C1[触发 CopyData 请求] --> C2[根据参数生成 Restore Job]
        C2 --> C3[执行 Yugabyte Backup & Restore 脚本]
        C3 --> C4[恢复数据到目标集群/命名空间]
        C4 --> C5[完成数据复制]
    end
```

---

## 1. MySQL / ClickHouse – 基于 EBS Snapshot 的复制

### 原理

EBS 是 AWS 的块存储服务，PVC/PV 本质上就是挂在 Pod 上的 EBS 卷。

当你对一个 EBS 卷做 snapshot 时，AWS 会把卷的所有数据在存储层面做一个快照副本。

之后你可以用这个 snapshot 在另一个集群或命名空间恢复出新的卷。

Kubernetes 通过更新 PVC/PV 的绑定关系，把数据库 Pod 挂到新的卷上。

### Copy 的数据

Copy 的是整个磁盘块级别的数据（底层文件、表、日志等一切内容）。

所以不需要关心数据库结构、表、记录，快照就是一模一样的卷拷贝。

**缺点**: 卷级别的“粗粒度复制”，不能只挑选部分表/库。

---

## 2. YugabyteDB – 基于 Backup & Restore 脚本 的复制

### 原理

Yugabyte 提供了官方的备份工具（如 `yb_backup.py`），可以导出和恢复数据：

- **Backup**: 从源集群里，把数据库内容（表、索引、元数据、数据文件）打包到对象存储（如 S3）。
- **Restore**: 在目标集群中运行 restore job，从备份位置读取文件，重新导入到 YugabyteDB。

这样做不依赖 EBS 快照，而是走数据库层的数据导出/导入。

### Copy 的数据

Copy 的是逻辑层面的数据库内容：表结构、行数据、索引等。

比如 `CREATE TABLE ...` 和对应的 SSTable 文件会在恢复时重建。

这种方式能做到跨集群、跨存储类型的复制（不依赖某个云厂商的 EBS）。

**缺点**: 速度通常比 EBS snapshot 慢，因为要逐条导出/导入数据。

---

## 对比总结

- **MySQL / ClickHouse**: 存储层复制，快，简单，但颗粒度粗（整个卷）。
- **YugabyteDB**: 数据库层复制，通用性强，可以跨云/跨集群，但会更慢，依赖脚本执行。

---

## Scripts

```bash
#!/bin/bash
# Script to extract data from ClickHouse and upload to target server
# Usage: ./copy_data.sh <cluster_alias> <namespace> <pod_name> <tenant> <sql_query> <output_filename> <target_path>

# Parameters
CLUSTER_ALIAS=$1
NAMESPACE=$2
POD_NAME=$3
TENANT=$4
SQL_QUERY=$5
OUTPUT_FILENAME=$6
TARGET_PATH=$7

# Validate parameters
if [ -z "$CLUSTER_ALIAS" ] || [ -z "$NAMESPACE" ] || [ -z "$POD_NAME" ] || [ -z "$TENANT" ] || [ -z "$SQL_QUERY" ] || [ -z "$OUTPUT_FILENAME" ] || [ -z "$TARGET_PATH" ]; then
    echo "Usage: ./copy_data.sh <cluster_alias> <namespace> <pod_name> <tenant> <sql_query> <output_filename> <target_path>"
    exit 1
fi

echo "Starting data extraction process..."

# Create extraction commands file
cat > clickhouse_extract.sh << EOL
mkdir -p /tmp/${TENANT}_extract
cd /tmp/${TENANT}_extract
clickhouse-client --query="${SQL_QUERY}" --format=CSVWithNames > ${OUTPUT_FILENAME}
ls -la ${OUTPUT_FILENAME}
wc -l ${OUTPUT_FILENAME}
head -5 ${OUTPUT_FILENAME}
EOL

# Copy extract script to pod
echo "Copying extraction script to pod..."
${CLUSTER_ALIAS} cp clickhouse_extract.sh ${POD_NAME}:/tmp/clickhouse_extract.sh -n ${NAMESPACE} -c clickhouse

# Execute extraction
echo "Executing data extraction..."
${CLUSTER_ALIAS} exec -it ${POD_NAME} -n ${NAMESPACE} -c clickhouse -- bash /tmp/clickhouse_extract.sh

# Copy data from pod
echo "Copying data from pod to local machine..."
${CLUSTER_ALIAS} cp ${POD_NAME}:/tmp/${TENANT}_extract/${OUTPUT_FILENAME} ./${OUTPUT_FILENAME} -n ${NAMESPACE} -c clickhouse

# Upload to target server
echo "Uploading to target server..."
scp ${OUTPUT_FILENAME} root@172.30.72.53:${TARGET_PATH}

# Verify upload
echo "Verifying upload..."
ssh root@172.30.72.53 "ls -la ${TARGET_PATH}"
ssh root@172.30.72.53 "wc -l ${TARGET_PATH}"

# Cleanup
echo "Cleaning up temporary files..."
${CLUSTER_ALIAS} exec -it ${POD_NAME} -n ${NAMESPACE} -c clickhouse -- rm -rf /tmp/${TENANT}_extract /tmp/clickhouse_extract.sh
rm clickhouse_extract.sh
rm ${OUTPUT_FILENAME}

echo "Data extraction and upload complete!"
```


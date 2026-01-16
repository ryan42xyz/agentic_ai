# Loki 直接查询快速参考

## 可用的 Loki 实例

根据你的 Kubernetes 配置，有以下 Loki 实例：

- **loki-scalable**: `https://loki-scalable.dv-api.com`
- **loki**: `https://loki.dv-api.com`  
- **loki-cluster**: `https://loki-cluster.dv-api.com`

## 核心 API 端点（Read-Only）

### 1. 列出所有标签名
```bash
curl -s "https://loki-scalable.dv-api.com/loki/api/v1/labels?start=<START_NS>&end=<END_NS>" | jq
```

### 2. 列出特定标签的值
```bash
curl -s "https://loki-scalable.dv-api.com/loki/api/v1/label/app/values?start=<START_NS>&end=<END_NS>" | jq
```

### 3. 查询日志（query_range）
```bash
curl -s "https://loki-scalable.dv-api.com/loki/api/v1/query_range?query={app=\"nginx\"}&start=<START_NS>&end=<END_NS>&limit=10&direction=backward" | jq
```

### 4. 获取统计信息
```bash
curl -s "https://loki-scalable.dv-api.com/loki/api/v1/index/stats?query={app=\"nginx\"}&start=<START_NS>&end=<END_NS>" | jq
```

## 时间戳格式

Loki API 使用 **Unix 纳秒时间戳**（不是秒，不是毫秒）

```bash
# 当前时间（纳秒）
date +%s000000000

# 1小时前（纳秒）
echo $(($(date +%s) - 3600))000000000

# 30分钟前（纳秒）
echo $(($(date +%s) - 1800))000000000

# RFC3339 转纳秒（需要 gdate 在 macOS）
gdate -d "2024-01-01T00:00:00Z" +%s000000000
```

## 常用查询示例

### 基础查询
```bash
# 查询特定应用的日志
LOKI="https://loki-scalable.dv-api.com"
NOW=$(date +%s)000000000
HOUR_AGO=$(($(date +%s) - 3600))000000000

curl -s "${LOKI}/loki/api/v1/query_range?query={app=\"nginx\"}&start=${HOUR_AGO}&end=${NOW}&limit=10&direction=backward" | jq
```

### 带过滤的查询
```bash
# 查询包含 "error" 的日志
curl -s "${LOKI}/loki/api/v1/query_range?query={app=\"nginx\"} |= \"error\"&start=${HOUR_AGO}&end=${NOW}&limit=10&direction=backward" | jq
```

### 多标签查询
```bash
# 查询 app=nginx 且 env=prod 的日志
curl -s "${LOKI}/loki/api/v1/query_range?query={app=\"nginx\",env=\"prod\"}&start=${HOUR_AGO}&end=${NOW}&limit=10&direction=backward" | jq
```

### 正则匹配
```bash
# 匹配多个应用
curl -s "${LOKI}/loki/api/v1/query_range?query={app=~\"nginx|apache\"}&start=${HOUR_AGO}&end=${NOW}&limit=10&direction=backward" | jq
```

### 查询特定 Pod
```bash
curl -s "${LOKI}/loki/api/v1/query_range?query={pod=\"your-pod-name\"}&start=${HOUR_AGO}&end=${NOW}&limit=20&direction=backward" | jq
```

## 格式化输出

### 只显示日志内容
```bash
curl -s "${LOKI}/loki/api/v1/query_range?query={app=\"nginx\"}&start=${HOUR_AGO}&end=${NOW}&limit=10&direction=backward" | \
  jq -r '.data.result[].values[][1]'
```

### 显示时间戳和日志
```bash
curl -s "${LOKI}/loki/api/v1/query_range?query={app=\"nginx\"}&start=${HOUR_AGO}&end=${NOW}&limit=10&direction=backward" | \
  jq -r '.data.result[].values[] | "\(.[0] | tonumber / 1000000000 | strftime("%Y-%m-%d %H:%M:%S")) | \(.[1])"'
```

## LogQL 语法速查

| 语法 | 说明 | 示例 |
|------|------|------|
| `{app="nginx"}` | 精确匹配标签 | `{app="nginx"}` |
| `{app=~"nginx\|apache"}` | 正则匹配 | `{app=~"nginx\|apache"}` |
| `{app!="nginx"}` | 不等于 | `{app!="nginx"}` |
| `{app=~".*nginx.*"}` | 包含匹配 | `{app=~".*nginx.*"}` |
| `\|= "error"` | 包含字符串 | `{app="nginx"} \|= "error"` |
| `\|!~ "debug"` | 不匹配正则 | `{app="nginx"} \|!~ "debug"` |
| `\| json` | JSON 解析 | `{app="nginx"} \| json` |
| `\| json \| level="error"` | JSON 解析后过滤 | `{app="nginx"} \| json \| level="error"` |

## 参数说明

### query_range 参数

- `query`: LogQL 查询语句（必需）
- `start`: 开始时间（Unix 纳秒时间戳，必需）
- `end`: 结束时间（Unix 纳秒时间戳，必需）
- `limit`: 返回的日志行数（默认 100，最大取决于配置）
- `direction`: 查询方向
  - `forward`: 从旧到新
  - `backward`: 从新到旧（默认）

## 认证

如果需要认证，添加以下 header：

```bash
# Bearer Token
curl -H "Authorization: Bearer <token>" ...

# Basic Auth
curl -u username:password ...

# API Key（如果支持）
curl -H "X-API-Key: <key>" ...
```

## 测试连接

```bash
# 测试是否能访问（列出标签）
LOKI="https://loki-scalable.dv-api.com"
NOW=$(date +%s)000000000
HOUR_AGO=$(($(date +%s) - 3600))000000000

curl -s "${LOKI}/loki/api/v1/labels?start=${HOUR_AGO}&end=${NOW}" | jq
```

## 故障排查

1. **返回空结果**: 检查时间范围是否正确，标签值是否存在
2. **401/403 错误**: 需要添加认证信息
3. **404 错误**: 检查 URL 是否正确，确认 Loki 实例是否可访问
4. **时间戳错误**: 确保使用纳秒时间戳（9 个零），不是秒或毫秒

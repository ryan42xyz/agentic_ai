#!/bin/bash
# Loki Read-Only Query Commands
# 直接通过 curl 查询 Loki 日志，无需通过 Grafana

# 配置 Loki 实例 URL（根据你的环境选择）
LOKI_SCALABLE="https://loki-scalable.dv-api.com"
LOKI_MONITORING="https://loki.dv-api.com"
LOKI_CLUSTER="https://loki-cluster.dv-api.com"

# 默认使用 loki-scalable
LOKI_URL="${LOKI_SCALABLE}"

# 时间范围设置（Unix 纳秒时间戳）
# 默认：最近1小时
END_TIME=$(date +%s)000000000  # 当前时间（纳秒）
START_TIME=$(($(date +%s) - 3600))000000000  # 1小时前（纳秒）

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Loki Read-Only Query Commands ===${NC}\n"

# 1. 列出所有可用的标签名
echo -e "${YELLOW}1. 列出所有标签名:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/labels?start=${START_TIME}&end=${END_TIME}\" | jq"
echo ""

# 2. 列出特定标签的所有值（例如：app, pod, namespace 等）
echo -e "${YELLOW}2. 列出标签 'app' 的所有值:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/label/app/values?start=${START_TIME}&end=${END_TIME}\" | jq"
echo ""

# 3. 查询日志 - 简单标签匹配
echo -e "${YELLOW}3. 查询特定应用的日志（示例：app=nginx）:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={app=\\\"nginx\\\"}&start=${START_TIME}&end=${END_TIME}&limit=10&direction=backward\" | jq"
echo ""

# 4. 查询日志 - 带过滤条件
echo -e "${YELLOW}4. 查询包含 'error' 的日志:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={app=\\\"nginx\\\"} |= \\\"error\\\"&start=${START_TIME}&end=${END_TIME}&limit=10&direction=backward\" | jq"
echo ""

# 5. 查询多个标签组合
echo -e "${YELLOW}5. 查询多个标签组合（示例：app=nginx, env=prod）:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={app=\\\"nginx\\\",env=\\\"prod\\\"}&start=${START_TIME}&end=${END_TIME}&limit=10&direction=backward\" | jq"
echo ""

# 6. 获取日志统计信息
echo -e "${YELLOW}6. 获取日志统计信息（streams, chunks, entries, bytes）:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/index/stats?query={app=\\\"nginx\\\"}&start=${START_TIME}&end=${END_TIME}\" | jq"
echo ""

# 7. 查询特定 pod 的日志
echo -e "${YELLOW}7. 查询特定 pod 的日志:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={pod=\\\"your-pod-name\\\"}&start=${START_TIME}&end=${END_TIME}&limit=20&direction=backward\" | jq"
echo ""

# 8. 查询特定 namespace 的日志
echo -e "${YELLOW}8. 查询特定 namespace 的日志:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={namespace=\\\"default\\\"}&start=${START_TIME}&end=${END_TIME}&limit=10&direction=backward\" | jq"
echo ""

# 9. 使用 LogQL 正则表达式
echo -e "${YELLOW}9. 使用正则表达式匹配标签值:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={app=~\\\"nginx|apache\\\"}&start=${START_TIME}&end=${END_TIME}&limit=10&direction=backward\" | jq"
echo ""

# 10. 查询并提取 JSON 字段
echo -e "${YELLOW}10. 解析 JSON 日志并提取字段:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={app=\\\"nginx\\\"} | json | level=\\\"error\\\"&start=${START_TIME}&end=${END_TIME}&limit=10&direction=backward\" | jq"
echo ""

# 11. 时间范围查询（自定义时间）
echo -e "${YELLOW}11. 自定义时间范围查询（最近30分钟）:${NC}"
CUSTOM_END=$(date +%s)000000000
CUSTOM_START=$(($(date +%s) - 1800))000000000
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={app=\\\"nginx\\\"}&start=${CUSTOM_START}&end=${CUSTOM_END}&limit=10&direction=backward\" | jq"
echo ""

# 12. 格式化输出 - 只显示日志内容
echo -e "${YELLOW}12. 只提取日志内容（不显示元数据）:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={app=\\\"nginx\\\"}&start=${START_TIME}&end=${END_TIME}&limit=10&direction=backward\" | jq -r '.data.result[].values[][1]'"
echo ""

# 13. 格式化输出 - 显示时间戳和日志内容
echo -e "${YELLOW}13. 显示时间戳和日志内容:${NC}"
echo "curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={app=\\\"nginx\\\"}&start=${START_TIME}&end=${END_TIME}&limit=10&direction=backward\" | jq -r '.data.result[].values[] | \"\(.[0] | tonumber / 1000000000 | strftime(\\\"%Y-%m-%d %H:%M:%S\\\")) | \(.[1])\"'"
echo ""

echo -e "${GREEN}=== 使用说明 ===${NC}"
echo "1. 替换示例中的标签值（app, pod, namespace 等）为实际值"
echo "2. 调整时间范围：修改 START_TIME 和 END_TIME（Unix 纳秒时间戳）"
echo "3. 切换 Loki 实例：修改 LOKI_URL 变量"
echo "4. 需要认证时，添加 -H 'Authorization: Bearer <token>' 或 -u user:pass"
echo ""
echo -e "${GREEN}=== 时间戳转换 ===${NC}"
echo "当前时间（纳秒）: $(date +%s)000000000"
echo "1小时前（纳秒）: $(($(date +%s) - 3600))000000000"
echo "RFC3339 转纳秒: date -d '2024-01-01T00:00:00Z' +%s000000000"
echo ""
echo -e "${GREEN}=== LogQL 查询语法示例 ===${NC}"
echo "{app=\"nginx\"}                          # 简单标签匹配"
echo "{app=\"nginx\",env=\"prod\"}              # 多标签匹配"
echo "{app=~\"nginx|apache\"}                  # 正则匹配"
echo "{app=\"nginx\"} |= \"error\"              # 包含字符串"
echo "{app=\"nginx\"} != \"debug\"              # 不包含字符串"
echo "{app=\"nginx\"} | json | level=\"error\"  # JSON 解析和过滤"
echo "{app=\"nginx\"} | regexp \"(?P<ip>.*)\"  # 正则提取"

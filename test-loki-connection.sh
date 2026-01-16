#!/bin/bash
# 快速测试 Loki 连接和查询

# 配置
LOKI_SCALABLE="https://loki-scalable.dv-api.com"
LOKI_MONITORING="https://loki.dv-api.com"
LOKI_CLUSTER="https://loki-cluster.dv-api.com"

# 默认使用 loki-scalable
LOKI_URL="${1:-${LOKI_SCALABLE}}"

# 时间范围（最近1小时）
END_TIME=$(date +%s)000000000
START_TIME=$(($(date +%s) - 3600))000000000

echo "=========================================="
echo "测试 Loki 连接: ${LOKI_URL}"
echo "时间范围: 最近1小时"
echo "=========================================="
echo ""

# 测试 1: 列出标签名
echo "1. 测试列出所有标签名..."
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "${LOKI_URL}/loki/api/v1/labels?start=${START_TIME}&end=${END_TIME}")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ 成功！找到以下标签："
    echo "$BODY" | jq -r '.data[]' | head -10
    echo ""
    
    # 获取第一个标签用于后续测试
    FIRST_LABEL=$(echo "$BODY" | jq -r '.data[0]' 2>/dev/null)
    if [ -n "$FIRST_LABEL" ] && [ "$FIRST_LABEL" != "null" ]; then
        echo "2. 测试列出标签 '${FIRST_LABEL}' 的值..."
        LABEL_VALUES=$(curl -s "${LOKI_URL}/loki/api/v1/label/${FIRST_LABEL}/values?start=${START_TIME}&end=${END_TIME}")
        if echo "$LABEL_VALUES" | jq -e '.data' > /dev/null 2>&1; then
            echo "✓ 成功！找到以下值："
            echo "$LABEL_VALUES" | jq -r '.data[]' | head -5
            echo ""
            
            # 使用第一个值进行查询测试
            FIRST_VALUE=$(echo "$LABEL_VALUES" | jq -r '.data[0]' 2>/dev/null)
            if [ -n "$FIRST_VALUE" ] && [ "$FIRST_VALUE" != "null" ]; then
                echo "3. 测试查询日志: {${FIRST_LABEL}=\"${FIRST_VALUE}\"}..."
                QUERY="{\"${FIRST_LABEL}\"=\"${FIRST_VALUE}\"}"
                QUERY_ENCODED=$(echo "$QUERY" | sed 's/"/\\"/g')
                LOGS=$(curl -s "${LOKI_URL}/loki/api/v1/query_range?query={${FIRST_LABEL}=\"${FIRST_VALUE}\"}&start=${START_TIME}&end=${END_TIME}&limit=5&direction=backward")
                
                if echo "$LOGS" | jq -e '.data.result' > /dev/null 2>&1; then
                    RESULT_COUNT=$(echo "$LOGS" | jq '.data.result | length')
                    if [ "$RESULT_COUNT" -gt 0 ]; then
                        echo "✓ 成功！找到 ${RESULT_COUNT} 个日志流"
                        echo "前3条日志："
                        echo "$LOGS" | jq -r '.data.result[0].values[0:3][] | "\(.[0] | tonumber / 1000000000 | strftime("%Y-%m-%d %H:%M:%S")) | \(.[1])"' 2>/dev/null || echo "$LOGS" | jq -r '.data.result[0].values[0:3][] | .[1]' 2>/dev/null
                    else
                        echo "⚠ 查询成功但无日志结果"
                    fi
                else
                    echo "✗ 查询失败或返回格式错误"
                    echo "$LOGS" | jq '.' 2>/dev/null || echo "$LOGS"
                fi
            fi
        else
            echo "✗ 获取标签值失败"
            echo "$LABEL_VALUES" | jq '.' 2>/dev/null || echo "$LABEL_VALUES"
        fi
    fi
else
    echo "✗ 连接失败 (HTTP $HTTP_CODE)"
    echo "响应："
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
    echo ""
    echo "提示："
    echo "  - 检查 URL 是否正确"
    echo "  - 检查是否需要认证（添加 -H 'Authorization: Bearer <token>'）"
    echo "  - 检查网络连接"
fi

echo ""
echo "=========================================="
echo "测试完成"
echo ""
echo "使用示例："
echo "  # 列出所有标签"
echo "  curl -s \"${LOKI_URL}/loki/api/v1/labels?start=${START_TIME}&end=${END_TIME}\" | jq"
echo ""
echo "  # 查询日志"
echo "  curl -s \"${LOKI_URL}/loki/api/v1/query_range?query={app=\\\"your-app\\\"}&start=${START_TIME}&end=${END_TIME}&limit=10&direction=backward\" | jq"
echo "=========================================="

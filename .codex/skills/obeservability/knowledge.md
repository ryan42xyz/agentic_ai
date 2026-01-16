```sh
# victoriametrics usage:
# codex mcp


# grafana usage:
# GRAFANA_URL='https://grafana-mgt.dv-api.com'
# GRAFANA_USERNAME='rui.shao@datavisor.com'
# GRAFANA_PASSWORD='Autodeploy123!'
# curl -fsS -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" "$GRAFANA_URL/api/health"

# loki usage:
# LOKI="https://loki.dv-api.com" && NOW=$(date +%s)000000000 && HOUR_AGO=$(($(date +%s) - 3600))000000000 && echo "=== 查询包含 'error' 的日志 ===" && curl -s -G "${LOKI}/loki/api/v1/query_range" --data-urlencode "query={app=\"admin-ui\"} |= \"error\"" --data-urlencode "start=${HOUR_AGO}" --data-urlencode "end=${NOW}" --data-urlencode "limit=5" --data-urlencode "direction=backward" | jq '.data.result'

# LOKI="https://loki.dv-api.com"

# END_NS="$(date +%s)000000000"
# START_NS="$(($(date +%s) - 1800))000000000"   # now-30m

# QUERY='{cluster="aws-useast1-prod-a",namespace="prod",pod=~".*",stream=~"stdout|stderr",container="ngsc"} |~ ""'

# curl -s -G "${LOKI}/loki/api/v1/query_range" \
#   --data-urlencode "query=${QUERY}" \
#   --data-urlencode "start=${START_NS}" \
#   --data-urlencode "end=${END_NS}" \
#   --data-urlencode "limit=50" \
#   --data-urlencode "direction=backward" \
# | jq -r '.data.result[].values[] | "\(.[0] | tonumber / 1000000000 | strftime("%Y-%m-%d %H:%M:%S")) | \(.[1])"'
```
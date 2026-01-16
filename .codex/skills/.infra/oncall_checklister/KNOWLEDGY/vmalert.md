# VMAlert

VMAlert API endpoints for validating alert firing and rules.

## API Endpoints

### Rules
URL: `https://vm-mgt-a.dv-api.com/vmalert/api/v1/rules`

Usage:
- List all active alert rules
- Validate rule configuration
- Check rule evaluation status

### Alerts
URL: `https://vm-mgt-a.dv-api.com/vmalert/api/v1/alerts`

Usage:
- List currently firing alerts
- Check alert state (firing, pending, resolved)
- Validate alert is not flapping
- Detect transient alerts (already resolved)

## Principles

- Always validate alert quality before deep inspection
- Check if alert is still firing
- Verify alert is not a false positive
- Check alert history for patterns
- Do NOT proceed with inspection if alert is invalid/flapping

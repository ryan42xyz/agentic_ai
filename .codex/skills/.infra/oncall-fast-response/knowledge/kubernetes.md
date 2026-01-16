# Kubernetes

Kubernetes command reference and safety rules.

## Allowed Commands (Read-Only)

- `get` - Retrieve resource information
- `describe` - Get detailed resource description
- `logs` - View pod logs
- `top` - View resource usage (CPU, memory)
- `diff` - Compare configurations
- `lint` - Validate configurations
- `test` - Test configurations
- `fmt` - Format configurations

## Forbidden Commands (By Default)

- `delete` - Delete resources
- `patch` - Modify resources
- `apply` - Apply configurations
- `scale` - Scale resources
- `rollout restart` - Restart deployments

## Principles

- Read-only by default
- Generate commands only, never execute automatically
- All prod write operations require manual intervention
- Never mutate production systems without human confirmation

## Usage

- Use kubectl aliases from `clusters.md` for cluster access
- Generate commands with parameters from signal extraction
- Suggest commands to human operator, do not execute

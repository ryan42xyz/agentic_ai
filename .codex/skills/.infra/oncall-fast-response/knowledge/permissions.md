# Permissions Model

Security and permissions principles for oncall operations.

## Core Principles

- Read-only by default
- Never mutate prod automatically
- Human-in-the-loop for any write
- Preserve audit trail

## Read-Only Operations (Allowed)

- Query dashboards and metrics
- View logs and traces
- Inspect resource status
- Generate diagnostic commands (but not execute)

## Write Operations (Forbidden)

- Resource modifications
- Configuration changes
- Scaling operations
- Restart/rollout operations
- Database mutations

## Human-in-the-Loop Requirements

Any operation that would:
- Change system state
- Modify configurations
- Affect production traffic
- Update database records

Must require explicit human confirmation and execution.

## Audit Trail

- Document all inspection steps
- Preserve uncertainty and decision points
- Record what was checked and why
- Note what was not checked and why

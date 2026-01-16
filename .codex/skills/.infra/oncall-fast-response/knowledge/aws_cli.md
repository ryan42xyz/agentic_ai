# AWS CLI

AWS CLI command reference and safety rules.

## Allowed Commands (Read-Only)

- `get` - Retrieve resource information
- `describe` - Get detailed resource description
- `logs` - View CloudWatch logs

## Forbidden Operations

- Any write operations (create, update, delete)
- Resource modifications
- Configuration changes

## Principles

- Generate commands only, never execute
- No write operations without manual confirmation
- Read-only inspection only
- Use with extracted signals from alert text

## Usage

- Generate AWS CLI commands with parameters from signal extraction
- Suggest commands to human operator, do not execute
- Use for gathering evidence, not for remediation

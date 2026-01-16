# Verification Skill

This skill collects engineering validation signals for an OpenSpec change as auditable evidence.

## Role

- Skill is the judge; validators are evidence sources.
- In OpenSpec strict mode, this skill MUST NOT issue a pass/fail/block verdict; it only produces evidence.

## Non-Negotiables

- This skill does not modify code.
- This skill does not bypass failures or reinterpret outputs.
- Overrides and “go/no-go” decisions are human decisions based on captured evidence.

## OpenSpec strict mode (hard-require)

Preconditions (ALL required):
- `openspec/changes/<change-name>/` exists
- `openspec/changes/<change-name>/request.md` exists
- `openspec/project.md` exists
- `openspec/AGENTS.md` exists

If any precondition is missing, STOP and ask the human to run OpenSpec init/scaffold (or point you at the correct repo).

## Output contract (evidence-only)

Write only:
- `openspec/changes/<change-name>/evidence/verification/verification.md`

The report MUST include (verbatim, no interpretation):
- validator name
- exact command(s) executed (or “not provided”)
- cwd / required env notes (only what the human provided)
- time window / timestamps
- exit codes
- raw stdout/stderr excerpts (or file paths if too large)

## Inputs

- Current working tree or patch
- Change proposal context
- Validation policy and validators

## Outputs

- A validation evidence report (no verdict)

## Procedure

1. Read `./policy.md` (this skill folder inside ) to determine required validators.
2. For each required validator, locate the human-defined command(s) (from change docs or explicit human instruction).
3. If a required validator command is missing, STOP and ask the human to provide it (do not guess).
4. Execute each required validator in order with bounded timeouts.
5. Record outputs verbatim in `openspec/changes/<change-name>/evidence/verification/verification.md`.

# Shell API Test Format (`endpoints.txt`)

This skill scaffolds a shell-only API smoke test suite under `scripts/api_test/` with support for:
- **Testing**: Basic HTTP endpoint validation
- **Output Comparison**: Status codes, substring matching, and JSON field comparison
- **Negative Test Cases**: Automatic generation and validation of error scenarios
- **Boundary Checking**: Parameter length, numeric range, and value validation

## `endpoints.txt` format

### Basic Format

One endpoint per line:

```
METHOD PATH EXPECT_STATUS [EXPECT_GREP] [TEST_OPTIONS]
```

### Examples

**Basic test (substring check):**
```
GET /healthz 200 ok
GET /metrics 200
POST /v1/login 200 '"token":'
```

**Negative test (expects failure):**
```
POST /api/invalid 400 NEGATIVE
GET /api/nonexistent 404 NEGATIVE
POST /api/login 401 NEGATIVE
```

**JSON field comparison:**
```
GET /api/user/123 200 JSON:$.name=John
GET /api/user/123 200 JSON:$.age=30 JSON:$.status=active
GET /api/data 200 JSON:$.token=*
```
- Uses `jq` syntax for JSON paths (e.g., `$.field`, `$.nested.field`)
- `*` means field must exist and be non-empty
- Falls back to grep if `jq` is not available

**Boundary checking:**
```
POST /api/users 201 BOUNDARY:name=1,100 BOUNDARY:age=0,150
GET /api/search?q=test 200 BOUNDARY:q=1,255
```
- Format: `BOUNDARY:param=min,max`
- For strings: checks length boundaries
- For numbers: checks numeric range
- Validates URL parameters against constraints

**Combined options:**
```
POST /api/login 200 JSON:$.token=* BOUNDARY:email=5,255
GET /api/user 200 JSON:$.id=* NEGATIVE
```

## Test Options

| Option | Description | Example |
|--------|-------------|---------|
| `NEGATIVE` | Expects 4xx/5xx error status | `POST /api/invalid 400 NEGATIVE` |
| `JSON:path=value` | Check JSON field value | `JSON:$.name=John` |
| `BOUNDARY:param=min,max` | Validate parameter boundaries | `BOUNDARY:age=0,150` |
| Plain string | Legacy: substring grep check | `ok` (checks for "ok" in response) |

## Auto-generating Test Cases

Use the included `generate_test_cases.py` script to automatically generate negative and boundary test cases:

```bash
# Generate negative test cases
python scripts/api_test/generate_test_cases.py --negative --endpoints-file scripts/api_test/endpoints.txt

# Generate boundary test cases
python scripts/api_test/generate_test_cases.py --boundary --endpoints-file scripts/api_test/endpoints.txt

# Generate both
python scripts/api_test/generate_test_cases.py --negative --boundary
```

Generated cases are saved to `scripts/api_test/endpoints.generated.txt`.

## Notes

- Blank lines and lines starting with `#` are ignored.
- JSON field comparison requires `jq` for full support, but falls back to grep-based matching if unavailable.
- Boundary checks validate URL query parameters and can be combined with request body validation.
- Negative tests invert the status code expectation (expects 4xx/5xx instead of exact match).


#!/usr/bin/env python3
"""
Generate negative test cases and boundary test cases automatically.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


def generate_negative_cases(method: str, path: str, base_status: str = "200") -> list[str]:
    """Generate negative test cases for an endpoint."""
    cases = []
    
    # Invalid methods
    if method != "GET":
        cases.append(f"GET {path} 405 NEGATIVE")
    if method != "POST":
        cases.append(f"POST {path} 405 NEGATIVE")
    
    # Invalid paths
    if "/" in path:
        parts = path.split("/")
        if len(parts) > 1:
            # Missing required path param
            invalid_path = "/".join(parts[:-1]) + "/invalid-id"
            cases.append(f"{method} {invalid_path} 404 NEGATIVE")
    
    # Missing auth (if path suggests protected endpoint)
    if any(x in path.lower() for x in ["/api/", "/admin/", "/user/"]):
        cases.append(f"{method} {path} 401 NEGATIVE")
    
    return cases


def generate_boundary_cases(
    method: str,
    path: str,
    param: str,
    min_val: int,
    max_val: int,
    param_type: str = "string"
) -> list[str]:
    """Generate boundary test cases for a parameter."""
    cases = []
    
    if param_type == "string":
        # Empty string
        cases.append(f"{method} {path}?{param}= 400 BOUNDARY:{param}=0,{max_val}")
        # Too long
        too_long = "x" * (max_val + 1)
        cases.append(f"{method} {path}?{param}={too_long} 400 BOUNDARY:{param}={min_val},{max_val}")
        # At boundaries
        if min_val > 0:
            at_min = "x" * min_val
            cases.append(f"{method} {path}?{param}={at_min} 200 BOUNDARY:{param}={min_val},{max_val}")
        at_max = "x" * max_val
        cases.append(f"{method} {path}?{param}={at_max} 200 BOUNDARY:{param}={min_val},{max_val}")
    elif param_type == "integer":
        # Below min
        cases.append(f"{method} {path}?{param}={min_val-1} 400 BOUNDARY:{param}={min_val},{max_val}")
        # Above max
        cases.append(f"{method} {path}?{param}={max_val+1} 400 BOUNDARY:{param}={min_val},{max_val}")
        # At boundaries
        cases.append(f"{method} {path}?{param}={min_val} 200 BOUNDARY:{param}={min_val},{max_val}")
        cases.append(f"{method} {path}?{param}={max_val} 200 BOUNDARY:{param}={min_val},{max_val}")
    
    return cases


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate negative and boundary test cases"
    )
    parser.add_argument(
        "--endpoints-file",
        default="scripts/api_test/endpoints.txt",
        help="Input endpoints file",
    )
    parser.add_argument(
        "--output",
        default="scripts/api_test/endpoints.generated.txt",
        help="Output file for generated cases",
    )
    parser.add_argument(
        "--negative",
        action="store_true",
        help="Generate negative test cases",
    )
    parser.add_argument(
        "--boundary",
        action="store_true",
        help="Generate boundary test cases",
    )
    args = parser.parse_args()

    if not Path(args.endpoints_file).exists():
        print(f"Error: {args.endpoints_file} not found", file=sys.stderr)
        return 1

    generated = []
    
    with open(args.endpoints_file) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            
            parts = line.split()
            if len(parts) < 3:
                continue
            
            method = parts[0]
            path = parts[1]
            status = parts[2]
            
            if args.negative:
                negative_cases = generate_negative_cases(method, path, status)
                generated.extend(negative_cases)
            
            # Extract boundary specs from existing line
            if args.boundary:
                for part in parts[3:]:
                    if part.startswith("BOUNDARY:"):
                        spec = part[9:]  # Remove "BOUNDARY:"
                        if "=" in spec and "," in spec:
                            param_part, range_part = spec.split("=", 1)
                            if "," in range_part:
                                min_val, max_val = range_part.split(",", 1)
                                try:
                                    min_val = int(min_val)
                                    max_val = int(max_val)
                                    boundary_cases = generate_boundary_cases(
                                        method, path, param_part, min_val, max_val
                                    )
                                    generated.extend(boundary_cases)
                                except ValueError:
                                    pass

    if generated:
        with open(args.output, "w") as f:
            f.write("# Auto-generated test cases\n")
            f.write("# Run: python scripts/generate_test_cases.py --negative --boundary\n\n")
            for case in generated:
                f.write(f"{case}\n")
        print(f"Generated {len(generated)} test cases: {args.output}")
    else:
        print("No test cases generated")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

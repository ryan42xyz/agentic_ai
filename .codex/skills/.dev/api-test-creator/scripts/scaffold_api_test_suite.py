#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
import stat
from pathlib import Path


def _skill_dir() -> Path:
    return Path(__file__).resolve().parents[1]


def _copy_file(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Scaffold a minimal, shell-only API test suite into the current repo."
    )
    parser.add_argument(
        "--out-dir",
        default="scripts/api_test",
        help="Output directory inside the target repo (default: scripts/api_test)",
    )
    parser.add_argument("--force", action="store_true", help="Overwrite existing files if present.")
    args = parser.parse_args()

    out_dir = Path(args.out_dir)
    if out_dir.exists() and not args.force:
        raise SystemExit(f"refusing to overwrite existing {out_dir}; pass --force")

    if out_dir.exists() and args.force:
        shutil.rmtree(out_dir)

    out_dir.mkdir(parents=True, exist_ok=True)

    skill_dir = _skill_dir()
    endpoints_src = skill_dir / "assets" / "endpoints.example.txt"
    run_sh_src = skill_dir / "assets" / "run.sh"
    start_and_test_src = skill_dir / "assets" / "start_and_test.sh"
    generate_script_src = skill_dir / "scripts" / "generate_test_cases.py"

    _copy_file(endpoints_src, out_dir / "endpoints.example.txt")
    _copy_file(endpoints_src, out_dir / "endpoints.txt")
    _copy_file(run_sh_src, out_dir / "run.sh")
    _copy_file(start_and_test_src, out_dir / "start_and_test.sh")
    
    # Copy test case generator script
    scripts_out_dir = Path(args.out_dir).parent / "scripts" / "api_test"
    if scripts_out_dir != out_dir:
        scripts_out_dir.mkdir(parents=True, exist_ok=True)
    _copy_file(generate_script_src, scripts_out_dir / "generate_test_cases.py")
    (scripts_out_dir / "generate_test_cases.py").chmod(
        (scripts_out_dir / "generate_test_cases.py").stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH
    )

    for script in ["run.sh", "start_and_test.sh"]:
        path = out_dir / script
        path.chmod(path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    print(f"[OK] Scaffolded: {out_dir}")
    print("Next:")
    print(f"  - Edit {out_dir / 'endpoints.txt'} to add endpoints")
    print(f"  - Run: BASE_URL=http://localhost:8080 {out_dir / 'run.sh'}")
    print(f"  - Or:  START_CMD='...' BASE_URL=http://localhost:8080 {out_dir / 'start_and_test.sh'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

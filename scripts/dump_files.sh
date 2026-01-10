#!/usr/bin/env bash

set -e

TARGET="$1"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <file-or-directory-path>" >&2
  exit 1
fi

print_file() {
  local file="$1"
  echo "===== FILE: $file ====="
  cat "$file"
  echo
}

if [ -f "$TARGET" ]; then
  print_file "$TARGET"
  exit 0
fi

if [ -d "$TARGET" ]; then
  # 1️⃣ 先打印 SKILL.md（如果存在）
  if [ -f "$TARGET/SKILL.md" ]; then
    print_file "$TARGET/SKILL.md"
  fi

  # 2️⃣ 打印其余文件（排除 SKILL.md），按路径排序
  find "$TARGET" -type f \
    ! -path "$TARGET/SKILL.md" \
    | sort \
    | while read -r file; do
        print_file "$file"
      done

  exit 0
fi

echo "Error: $TARGET is neither a file nor a directory" >&2
exit 1

# chmod +x scripts/dump_files.sh

# ./scripts/dump_files.sh .codex/skills/.dev/openspec_change_apply > openspec_change_apply.md
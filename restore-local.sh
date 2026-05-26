#!/bin/bash
# 恢复本地版本
set -e
cd "$(dirname "$0")"

if [ -f SKILL.md.bak ]; then
  mv SKILL.md.bak SKILL.md
  echo "✅ 已恢复本地 SKILL.md"
else
  echo "⚠️ 没有找到备份文件"
fi

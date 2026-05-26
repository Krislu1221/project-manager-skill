#!/bin/bash
# ClawHub 发布脚本
# 用法: ./publish-clawhub.sh [version]
# 会临时用 SKILL.clawhub.md 替换 SKILL.md，发布后恢复

set -e
cd "$(dirname "$0")"

VERSION="${1:-$(jq -r .version clawhub.json 2>/dev/null || echo 'unknown')}"
echo "📦 发布版本: $VERSION"

# 备份原始 SKILL.md
cp SKILL.md SKILL.md.bak

# 替换为 ClawHub 合规版本
cp SKILL.clawhub.md SKILL.md

echo "✅ 已切换到 ClawHub 合规版本"
echo "👉 现在可以执行 clawhub publish"
echo "👉 发布完成后运行 ./restore-local.sh 恢复本地版本"

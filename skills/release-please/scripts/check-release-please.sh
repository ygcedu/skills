#!/usr/bin/env bash
set -euo pipefail

project_dir="${1:-.}"
config="$project_dir/.github/release-please-config.json"
manifest="$project_dir/.github/.release-please-manifest.json"
workflow="$project_dir/.github/workflows/release-please.yml"
failed=false

for file in "$config" "$manifest" "$workflow"; do
  if [[ ! -f "$file" ]]; then
    echo "错误：缺少文件 $file" >&2
    failed=true
  fi
done

if [[ "$failed" == "true" ]]; then
  exit 1
fi

command -v jq >/dev/null || { echo "错误：需要安装 jq" >&2; exit 1; }
jq empty "$config" "$manifest"

package_paths="$(jq -r '.packages // {} | keys[]' "$config")"
if [[ -z "$package_paths" ]]; then
  echo "错误：配置中没有 packages；manifest 模式将无法处理任何路径" >&2
  failed=true
else
  while IFS= read -r path; do
    if ! jq -e --arg path "$path" 'has($path)' "$manifest" >/dev/null; then
      echo "错误：manifest 中没有包路径对应的版本：$path" >&2
      failed=true
    fi
  done <<<"$package_paths"
fi

if ! grep -Eq '^[[:space:]]*contents:[[:space:]]*write([[:space:]]|$)' "$workflow"; then
  echo "错误：workflow 未授予 contents: write 权限" >&2
  failed=true
fi

if ! grep -Eq '^[[:space:]]*pull-requests:[[:space:]]*write([[:space:]]|$)' "$workflow"; then
  echo "错误：workflow 未授予 pull-requests: write 权限" >&2
  failed=true
fi

if ! grep -Fq 'googleapis/release-please-action@' "$workflow"; then
  echo "错误：workflow 未使用 googleapis/release-please-action" >&2
  failed=true
fi

if [[ "$failed" == "true" ]]; then
  exit 1
fi

echo "release-please 配置检查通过。"

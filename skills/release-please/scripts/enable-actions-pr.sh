#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
用法：enable-actions-pr.sh [--repo OWNER/REPO] [--apply]

检查 GitHub Actions 是否可以创建和批准拉取请求。
不传 --apply 时仅执行只读检查。传入 --apply 时，本机 gh CLI
登录使用的令牌必须具有仓库管理写入权限。
EOF
}

repo=""
apply=false

while (($#)); do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || { echo "错误：--repo 需要 OWNER/REPO 参数" >&2; exit 2; }
      repo="$2"
      shift 2
      ;;
    --apply)
      apply=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "错误：未知参数：$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

command -v gh >/dev/null || { echo "错误：需要安装 gh CLI" >&2; exit 1; }
command -v jq >/dev/null || { echo "错误：需要安装 jq" >&2; exit 1; }

if [[ -z "$repo" ]]; then
  repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
fi

if [[ ! "$repo" =~ ^[^/]+/[^/]+$ ]]; then
  echo "错误：仓库名称必须使用 OWNER/REPO 格式，当前值：$repo" >&2
  exit 2
fi

endpoint="repos/${repo}/actions/permissions/workflow"
settings="$(gh api "$endpoint")"
default_permission="$(jq -r '.default_workflow_permissions' <<<"$settings")"
can_create_pr="$(jq -r '.can_approve_pull_request_reviews' <<<"$settings")"

case "$default_permission" in
  read) default_permission_label="只读" ;;
  write) default_permission_label="读写" ;;
  *) default_permission_label="$default_permission" ;;
esac

case "$can_create_pr" in
  true) can_create_pr_label="是" ;;
  false) can_create_pr_label="否" ;;
  *) can_create_pr_label="$can_create_pr" ;;
esac

echo "仓库：$repo"
echo "GITHUB_TOKEN 默认权限：$default_permission_label"
echo "Actions 是否可创建或批准拉取请求：$can_create_pr_label"

if [[ "$can_create_pr" == "true" ]]; then
  echo "无需修改。"
  exit 0
fi

if [[ "$apply" != "true" ]]; then
  echo "该权限尚未开启。请添加 --apply 参数后重新运行以启用。"
  exit 3
fi

gh api \
  --method PUT \
  "$endpoint" \
  -f default_workflow_permissions="$default_permission" \
  -F can_approve_pull_request_reviews=true \
  >/dev/null

verified="$(gh api "$endpoint" --jq '.can_approve_pull_request_reviews')"
if [[ "$verified" != "true" ]]; then
  echo "错误：GitHub 返回的权限状态仍未开启" >&2
  exit 1
fi

echo "已为 $repo 开启 Actions 创建拉取请求的权限。"

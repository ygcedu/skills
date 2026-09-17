# Release Please 配置参考

仅在创建或调整配置时读取本文件。以项目已有版本文件和发布约定为准。

## 单包 manifest 配置

`.github/release-please-config.json`：

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "packages": {
    ".": {
      "release-type": "node",
      "changelog-path": "CHANGELOG.md"
    }
  }
}
```

`.github/.release-please-manifest.json`：

```json
{
  ".": "0.0.0"
}
```

将 `0.0.0` 替换为仓库的当前版本。不要在已有标签或 Release 的仓库中盲目重置为 `0.0.0`。

## GitHub Actions workflow

`.github/workflows/release-please.yml`：

```yaml
name: Release Please

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - id: release
        uses: googleapis/release-please-action@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          target-branch: main
          config-file: .github/release-please-config.json
          manifest-file: .github/.release-please-manifest.json
```

把 `main` 替换为实际默认分支。release-please 本身不要求 checkout；只有后续构建或发布步骤需要仓库文件时才添加 `actions/checkout`。

发布步骤应使用：

```yaml
      - name: Publish
        if: steps.release.outputs.release_created == 'true'
        run: <项目已有且已验证的发布命令>
```

不要用 `pull_request_created` 触发制品发布。Release PR 合并后，后续 push 才会创建 GitHub Release，并令 `release_created` 为 `true`。

## 常见 release type

| 项目 | `release-type` | 常见版本文件 |
|---|---|---|
| Node.js / npm | `node` | `package.json`、`package-lock.json` |
| Python | `python` | `pyproject.toml`、`setup.py` 等 |
| Rust | `rust` | `Cargo.toml`、`Cargo.lock` |
| Go | `go` | 通常以 Git tag 为主 |
| Java Maven | `maven` | `pom.xml` |
| 通用仓库 | `simple` | `version.txt` |

若项目布局或 release type 不确定，查阅 release-please 官方文档或 schema，不要凭表格强行套用。

## Monorepo

每个发布单元在 `packages` 和 manifest 中使用相同路径：

```json
{
  "packages": {
    "packages/api": { "release-type": "node" },
    "packages/web": { "release-type": "node" }
  }
}
```

```json
{
  "packages/api": "1.2.3",
  "packages/web": "2.0.0"
}
```

需要统一版本或组件联动时，再配置 `group-pull-request-title-pattern`、`linked-versions` 等插件；普通单包仓库不需要这些复杂项。

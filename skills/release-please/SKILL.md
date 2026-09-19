---
name: release-please
description: 为 GitHub 仓库配置、修复或排查 googleapis/release-please-action 自动生成 CHANGELOG、Release PR、版本标签和 GitHub Release。用户提到 release-please、自动发版、自动更新版本、生成 changelog、Release PR 未创建或 Actions 无权创建 PR 时触发。
license: MIT
metadata:
  author: ygcedu
---

# Release Please 自动发版

为当前仓库建立可维护的 release-please manifest 工作流。先检查现有发布历史和项目类型，再修改配置；不要假定所有项目都是 Node.js。

## 配置流程

1. 询问用户希望哪个分支触发 release-please workflow；默认使用当前分支（`git branch --show-current`）。读取远程仓库信息、现有 workflow、版本文件、标签和 GitHub Releases。保留用户已有的发布逻辑与未提交修改。将用户指定的分支名写入 workflow 的 `branches:` 字段，不写死 `main`。
2. 根据项目选择 release type 和版本文件。需要配置示例或判断 release type 时，读取 [references/configuration.md](references/configuration.md)。
3. 使用 manifest 模式时同时创建或更新 `.github/release-please-config.json`、`.github/.release-please-manifest.json` 和 `.github/workflows/release-please.yml`。
4. 确保配置包含 `packages`。单包根目录至少为 `"packages": { ".": { "release-type": "..." } }`；缺少它会导致日志出现 `Splitting 0 commits by path`，Action 成功但不创建 PR。
5. workflow 至少授予 `contents: write` 与 `pull-requests: write`。仅在用户确实需要发布制品时添加发布步骤，不要臆造 registry、凭证或发布命令。
6. 使用 `scripts/check-release-please.sh <仓库目录>` 校验文件、JSON 和关键权限。
7. 检查仓库级 Actions PR 权限。先运行 `scripts/enable-actions-pr.sh --repo OWNER/REPO`；只有当前任务已明确授权配置仓库时，才追加 `--apply`。执行外部变更前告知用户。
8. 提交或推送前展示变更。只有用户要求时才提交、推送、重跑 workflow 或合并 Release PR。

## 版本与提交规则

- 从最近的有效 GitHub Release、标签和项目版本文件推导 manifest 版本；三者冲突时先说明冲突，不要静默重置版本。
- 没有任何发布历史时，优先采用项目现有版本；项目也没有版本时才使用 `0.0.0`。
- release-please 默认根据 Conventional Commits 决定版本：`fix:` 触发 patch，`feat:` 触发 minor，`!` 或 `BREAKING CHANGE:` 触发 major。
- `chore:`、`docs:` 是否进入 CHANGELOG 由项目配置决定；不要为了触发发布伪造空提交。

## 仓库权限约束

workflow 文件里的 `pull-requests: write` 不能打开仓库设置 **Allow GitHub Actions to create and approve pull requests**。该设置需要 Repository Administration: write。

- 优先用本机已登录的 `gh` 一次性配置。
- 不要尝试用 workflow 自带的 `GITHUB_TOKEN` 自举打开该权限。
- 不要把管理员 PAT 写入 workflow 或仓库。若用户明确要求全自动集中配置，建议使用受限 GitHub App 或组织级策略，并说明安全边界。
- 如果组织或企业策略锁定此选项，停止修改并报告需要组织管理员处理。

## 排障

读取失败运行日志，不要只看最终状态。按错误选择处理：

- `GitHub Actions is not permitted to create or approve pull requests`：运行权限检查脚本，并在获得授权后用 `--apply`。
- `Splitting 0 commits by path`：补齐 manifest 配置中的 `packages`，并核对路径与 manifest key。
- `No user facing commits found`：检查最近发布之后是否有 `feat`、`fix` 或 breaking commit，以及 squash merge 后的最终提交标题。
- 找不到 release/tag：核对 manifest、版本文件和标签是否一致，避免把已有项目误当成首次发布。
- Release PR 已存在但未更新：查找 `release-please--branches--...` 分支和打开的 PR，避免创建重复自动化。

完成标准：配置校验通过；仓库级权限状态已明确；若用户要求实际启用，则一次 push 能创建或更新 Release PR，或者已给出来自运行日志的具体外部阻塞原因。

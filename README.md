# skills

个人 Claude Code skill 开发仓库，遵循 [agentskills.io](https://agentskills.io) 规范。

## 安装

### 使用 gh skill（推荐）

```bash
# 安装全部 skills
gh skill install ygcedu/skills

# 安装单个 skill
gh skill install ygcedu/skills nas

# 指定版本
gh skill install ygcedu/skills nas@v1.0.0
```

### 使用 npx skills

```bash
# 安装全部 skills
npx skills add ygcedu/skills

# 安装单个 skill（Claude Code）
npx skills add ygcedu/skills -a claude-code -s nas

# 全局安装
npx skills add ygcedu/skills -g
```

## 现有 skills

| Skill | 说明 |
|-------|------|
| `nas` | 通过 `qk ssh` 操作 NAS（远程命令、Docker、Compose） |
| `release-please` | 配置和排查 release-please 自动生成 CHANGELOG、Release PR 与版本发布 |
| `session-to-skill` | 从当前或近期会话中提炼可复用的 agent skill |
| `vibe-finder` | 扫描代码库并按优先级生成可执行的改进建议清单 |
| `archify` | 第三方技能：生成交互式架构与流程图，来自 [tt-a1i/archify](https://github.com/tt-a1i/archify) |

## 第三方 skill 更新

第三方源码随仓库提交，来源和版本记录在 `third-party-skills.conf`。版本填写 `commit = 完整 SHA` 或 `tag = v2.16.0`，二选一。

```bash
# 安装 archify
npx skills add ygcedu/skills -a claude-code -s archify

# 同步清单指定版本（只需要 Git）
qk git copy-dir
```

更新时修改清单中的 commit 或 tag 后同步，命令直接覆盖目标目录。检查差异并提交源码与清单。未安装新版 `qk` 时仍可运行 `./scripts/sync-skills`。

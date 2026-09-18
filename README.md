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

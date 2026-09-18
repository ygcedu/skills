# Agent Skills 开发指南

本仓库遵循 [agentskills.io 规范](https://agentskills.io/specification)。

## 创建 Skill

每个 skill 是一个目录，至少包含 `SKILL.md`：

```
skills/
└── <skill-name>/
    ├── SKILL.md          # 必填：元数据 + 指令
    ├── scripts/          # 可选：可执行脚本
    ├── references/       # 可选：参考资料
    └── assets/           # 可选：模板、图片等静态资源
```

## SKILL.md 格式

```markdown
---
name: skill-name
description: 描述做什么 + 何时触发。包含具体关键词。
license: MIT
compatibility: 运行环境要求（如有）
metadata:
  author: ygcedu
---

# Skill 名称

Markdown 格式的指令内容。
```

### Frontmatter 字段

| 字段 | 必填 | 约束 |
|------|------|------|
| `name` | ✅ | ≤64 字符，仅小写字母/数字/连字符，不能以 `-` 开头或结尾，不能有两个连续 `-`，必须与目录名一致 |
| `description` | ✅ | ≤1024 字符，非空，描述功能 + 触发场景 |
| `license` | ❌ | 许可证名称或引用的文件 |
| `compatibility` | ❌ | ≤500 字符，运行环境要求 |
| `metadata` | ❌ | 自定义 key-value 字符串映射 |

### name 命名规则

**合法：** `nas`、`code-review`、`my-tool`
**非法：** `NAS`（大写）、`-nas`（以连字符开头）、`na--s`（连续连字符）

## 编写指令

- 使用祈使句："读取文件"、"执行命令"，而非 "You should read..."
- 指令控制在 500 行以内；详细参考材料放入 `references/`
- 每个步骤给出明确的完成标准（如何判断做完了）
- 文件引用用相对路径：`references/GUIDE.md`

## 跨 Agent 兼容

agentskills.io 规范层面无 agent-specific 字段——同一份 `SKILL.md` 所有 agent 通用，差异只在各 agent 能调用的**工具集**。

### 用 `compatibility` 声明环境依赖

```yaml
---
name: my-skill
compatibility: Requires qk CLI, SSH access to 192.168.2.10:22022
---
```

安装方可以看到前置条件，不满足时自然知道不能用。

### 指令里用"工具名"而非绑定特定 agent API

```markdown
# 通用（推荐）
使用 Bash 工具执行 `qk ssh exec df -h`

# 绑定 claude-code（避免）
调用 Bash 工具...使用 Read 工具读取文件
```

### 不同 agent 的工具集差异

| 操作 | Claude Code | Codex CLI | Cursor |
|------|-------------|-----------|--------|
| 读文件 | `Read` 工具 | `cat` / `open` | 有编辑能力 |
| 执行命令 | `Bash` 工具 | 原生 shell | 有 terminal 能力 |
| 写文件 | `Write` 工具 | 有 write 能力 | 有编辑能力 |

**原则：** 如果你的 skill 只依赖 `Bash` + 系统命令，那所有有 terminal 能力的 agent 都能用。

### `allowed-tools` 声明（实验性）

```yaml
allowed-tools: Bash(git:*) Read Write Glob Grep
```

各 agent 实现不一致，仅作提示用。

### 拆分层级提升复用

如果 skill 既有 agent 特定逻辑又有通用逻辑，拆分为多个 skill：

```
skills/
├── nas/            # 核心：依赖 qk CLI（个人工具链）
├── docker-compose  # 纯知识：通用 Docker Compose 最佳实践
└── ssh-remote      # 纯知识：通用 SSH 远程操作
```

通用部分可以被任意 agent 复用，不依赖特定工具。

## 发布

```bash
# 校验（不发布）
gh skill publish --dry-run

# 发布新版本
gh skill publish --tag v1.0.0
```

发布流程会自动：添加 `agent-skills` topic → 选择 semver 版本号 → 创建 GitHub Release。

## 变更同步

新增、修改或删除 skill 后，必须同步更新 `README.md` 的"现有 skills"列表，保持与 `skills/` 目录一致。

**原因：** README 是仓库入口，安装者通过它快速了解可用技能。README 与 skills 目录不一致会导致用户找不到新技能或看到已删除的技能。

**执行时机：** 在提交 skill 变更的同一 commit 中完成 README 更新；若一次变更涉及多个 skill，统一更新一次 README。

## 安装（其他机器）

```bash
gh skill install ygcedu/skills <skill-name>
gh skill install ygcedu/skills <skill-name>@v1.0.0  # 指定版本
```

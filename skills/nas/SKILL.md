---
name: nas
description: 通过 qk ssh 命令操作用户家里的 NAS 服务器（192.168.2.10，已装 Docker）。可远程执行命令、管理 Docker 容器、管理 Docker Compose 项目、上传文件/目录/镜像。当用户提到 NAS、家里服务器、远程 Docker、部署服务到 NAS、查看 NAS 容器状态/日志等时触发。
license: MIT
compatibility: Requires qk CLI, local network access to 192.168.2.10:22022
---

# NAS 服务器操作指南（基于 qk ssh）

本机装有 `qk` CLI，可通过 `qk ssh` 系列命令操作用户家里的 NAS 服务器。**默认目标服务器就是 NAS**（配置项 `ssh.defaultTarget = "nas"`，地址 192.168.2.10:22022），无需每次指定 `-t` 参数。

NAS 上已安装 Docker，compose 项目存放在 `/tmp/zfsv3/nvme11/17621310509/data/docker/<项目名>/` 目录下。

## 命令速查

### 1. 执行任意远程命令：`qk ssh exec`

```bash
qk ssh exec <命令>           # 在 NAS 上执行任意 shell 命令
qk ssh exec df -h            # 查看磁盘
qk ssh exec uname -a         # 查看系统信息
```

### 2. Docker 命令：`qk ssh docker`

在 NAS 上透传执行 `sudo docker ...`，支持所有 docker 子命令：

```bash
qk ssh docker ps                    # 查看运行中的容器
qk ssh docker ps -a                 # 查看所有容器
qk ssh docker images                # 查看镜像
qk ssh docker logs --tail=100 <容器名>   # 查看容器日志
qk ssh docker restart <容器名>       # 重启容器
qk ssh docker stats --no-stream     # 查看资源占用
qk ssh docker exec <容器名> <命令>   # 进容器执行命令
```

### 3. Docker Compose 项目管理：`qk ssh docker compose <子命令>`

这是 qk 对 NAS 上 compose 项目的封装（自动定位项目目录和 yml 文件）：

```bash
qk ssh docker compose list                  # 列出所有项目（运行中 + 已停止）
qk ssh docker compose cat <project>         # 查看项目的 docker-compose.yml 内容
qk ssh docker compose upload <project> <本地路径>   # 上传 yml 文件或整个项目目录
qk ssh docker compose up <project>          # 启动项目（up -d）
qk ssh docker compose stop <project>        # 停止项目（保留容器）
qk ssh docker compose down <project>        # 停止并删除容器
qk ssh docker compose ps <project>          # 查看项目容器状态
qk ssh docker compose logs <project> [args] # 查看日志（默认 --tail=100，可追加 -f 等参数）
```

- `<本地路径>` 可以是单个 `docker-compose.yml` 文件，也可以是包含 yml + 挂载数据的整个目录。
- 新项目会上传到 NAS 的 `/tmp/zfsv3/nvme11/17621310509/data/docker/<project>/` 目录。
- 已有项目会自动定位到其实际 yml 路径。

**部署新服务的典型流程**：
```bash
qk ssh docker compose upload myapp ./myapp/    # 上传项目目录（含 docker-compose.yml）
qk ssh docker compose up myapp                 # 启动
qk ssh docker compose logs myapp -f            # 看日志
```

### 4. 上传镜像 tar：`qk ssh docker load`

```bash
qk ssh docker load <本地tar文件>   # scp 上传 + 远程 docker load + 自动清理临时文件
```

适用于本地 `docker build` + `docker save` 后把镜像推到 NAS（NAS 是 arm64，注意构建架构）。

### 5. 上传任意文件/目录：`qk ssh upload`

```bash
qk ssh upload <本地路径> <远程路径>     # 文件或目录均可，目录会递归上传（SFTP）
qk ssh upload ./dist/ /tmp/dist/       # 示例
```

注意：远程家目录 `/home/17621310509` 不存在，SSH 登录时会提示 "Could not chdir to home directory"（无害警告）。上传目标路径建议用 `/tmp/...` 或数据目录下的绝对路径。

## 当前 NAS 上的服务（2026-08 快照）

运行中的 compose 项目：`mimo2api`、`neo4j`、`pi-web`、`sq_music`（含 3 个容器）
已停止的项目：`9router`、`cpolar`、`devbox`、`glm2api`、`upsnap`、`webtop`
独立容器：`cloudflared`（Cloudflare Tunnel）、`upsnap`（网络唤醒）

主要端口：3000 (pi-web)、7474/7687 (neo4j)、8081 (mimo2api)、20128 (9router)、3306 (sqmusic_mysql)、18096 (sqmusic_web)

## 注意事项

- 执行命令前如果需要交互确认，注意这些命令都是非交互 SSH，避免使用需要 TTY 交互的命令（如 `docker exec -it`）。
- `qk ssh exec` / `qk ssh docker` 失败时会返回非零退出码并输出 stderr，可直接根据错误信息排查。
- 危险操作（如 `compose down`、删除容器、清理镜像）执行前先向用户确认。

# QQ Bot Docker 部署套件

基于 Docker 的 NapCat + AstrBot + Gsuid-Core 一键部署方案，专为国内网络环境优化。

## 架构概览

```
┌─────────────┐     ┌─────────────┐     ┌──────────────┐
│   NapCat    │────▶│  AstrBot    │────▶│  Gsuid-Core  │
│  端口 6099  │     │  端口 6185  │     │  端口 8765   │
│  NTQQ 协议  │     │  机器人框架  │     │  游戏机器人   │
└─────────────┘     └─────────────┘     └──────────────┘
         ────────── astrbot_network ──────────
```

三个服务通过 Docker bridge 网络 `astrbot_network` 互联，各自独立启动，数据通过卷挂载持久化到宿主机。

## 环境要求

| 项目 | 最低要求 |
|------|----------|
| 操作系统 | Ubuntu 20.04+ / Debian 11+ |
| Docker | 20.10+ |
| Docker Compose | V2 (`docker compose`) |
| 内存 | 2 GB+ |
| 磁盘 | 10 GB+（含镜像和数据） |
| 网络 | 可访问国内镜像源（阿里云、CNB、TUNA） |
| 权限 | sudo 或 root |

## 快速部署

### 步骤 1：安装 Docker

在全新服务器上：

```bash
cd 1_dockerInstall
chmod +x install_docker.sh
sudo ./install_docker.sh
```

> 脚本使用阿里云镜像源，无需额外配置。

### 步骤 2：启动机器人服务

```bash
cd 2_napcat_docker
chmod +x run_napcat.sh
./run_napcat.sh
```

脚本会自动完成：用户权限检测、目录创建、Gsuid-Core 代码克隆、容器启动。

### 步骤 2（可选）：修复 Docker 镜像加速

如果遇到镜像拉取超时，可在部署前修复：

```bash
./run_napcat.sh --fix-mirror
```

或单独运行修复脚本：

```bash
chmod +x fix_docker_mirror.sh
sudo ./fix_docker_mirror.sh
```

## 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| NapCat | 6099 | NTQQ 协议服务，WebUI 登录入口 |
| AstrBot | 6185 | 机器人框架 Web 管理界面 |
| Gsuid-Core | 8765 | 游戏机器人核心服务 |

## 配置参数

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `NAPCAT_UID` | `1000` | NapCat 容器内运行用户的 UID |
| `NAPCAT_GID` | `1000` | NapCat 容器内运行用户的 GID |

`.env` 文件由 `run_napcat.sh` 自动生成，通常无需手动编辑。

### 数据卷挂载

| 宿主机路径 | 容器内路径 | 服务 | 说明 |
|-----------|-----------|------|------|
| `./data` | `/AstrBot/data` | napcat + astrbot | AstrBot 数据 |
| `./napcat/config` | `/app/napcat/config` | napcat | NapCat 配置文件 |
| `./ntqq` | `/app/.config/QQ` | napcat | QQ 登录会话（重启免扫码） |
| `./gsuid_core` | `/gsuid_core` | gsuid-core | Gsuid-Core 源代码 |
| `./gsuid_data` | `/gsuid_core/data` | gsuid-core | Gsuid-Core 数据 |
| `./gsuid_start/gsuid_start.sh` | `/start` | gsuid-core | 启动脚本 |
| `./gsuid_plugins` | `/gsuid_core/gsuid_core/plugins` | gsuid-core | 插件目录 |

### 修改端口映射

如需修改宿主机端口，编辑 `2_napcat_docker/docker-compose.yml` 中的 `ports` 字段：

```yaml
ports:
  - "16099:6099"  # 宿主机 16099 → 容器 6099
```

修改后执行 `docker compose up -d` 重新创建容器。

## 常用命令

```bash
docker ps                          # 查看运行状态
docker logs napcat                 # 查看日志
docker logs -f astrbot             # 实时跟踪日志
docker compose restart gsuid-core  # 重启单个服务
docker compose down                # 停止所有服务
docker compose up -d               # 启动所有服务
```

## 常见问题排查

### Docker 镜像拉取超时 / 403 错误

**现象**: `docker pull` 报 `i/o timeout` 或 `403 Forbidden`

**解决方案**:
```bash
./run_napcat.sh --fix-mirror
# 或
sudo ./fix_docker_mirror.sh
```

### NapCat QQ 登录失败

**现象**: NapCat 容器运行但无法登录 QQ

**排查步骤**:
1. 访问 `http://<服务器IP>:6099` 打开 WebUI
2. 检查 QQ 账号是否被限制登录
3. 查看容器日志：`docker logs napcat`
4. 尝试删除 `./ntqq` 目录后重启（会清除登录会话）

### AstrBot 连接 NapCat 失败

**现象**: AstrBot 日志显示连接 NapCat 失败

**排查步骤**:
1. 确认 NapCat 已正常运行：`docker ps | grep napcat`
2. 确认 NapCat 处于 `MODE=astrbot`（已在 `docker-compose.yml` 中配置）
3. 检查两个容器是否在同一网络：`docker network inspect astrbot_network`
4. 重启服务：`docker compose restart`

### Gsuid-Core 启动失败

**现象**: gsuid-core 容器反复重启

**排查步骤**:
1. 查看日志：`docker logs gsuid-core`
2. 检查 `./gsuid_core` 目录是否有完整代码
3. 如代码损坏，删除后重新运行 `./run_napcat.sh`（脚本会自动重新克隆）

### 端口冲突

**现象**: `bind: address already in use`

**解决方案**: 修改 `docker-compose.yml` 中的宿主机端口映射（参见上方"修改端口映射"章节）

### 权限问题

**现象**: 容器内无法写入挂载目录

**排查步骤**:
1. 确认 `run_napcat.sh` 检测到的 UID/GID 与实际用户一致
2. 检查目录权限：`ls -la ./data ./napcat/config ./ntqq`
3. 手动修复：`sudo chown -R $(id -u):$(id -g) ./data ./napcat ./ntqq ./gsuid_*`

## 目录结构

```
qqbot/
├── 1_dockerInstall/          # Docker 安装脚本 (Ubuntu)
│   ├── install_docker.sh     # 带阿里云镜像的 Docker 安装脚本
│   └── README.md
└── 2_napcat_docker/          # 机器人部署目录
    ├── docker-compose.yml    # 服务编排配置
    ├── run_napcat.sh         # 一键部署脚本
    ├── fix_docker_mirror.sh  # Docker 镜像加速修复
    └── README.md
```

## 许可证

本项目仅供学习和研究使用。

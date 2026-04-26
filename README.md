# QQ Bot Docker 部署套件

基于 Docker 的 NapCat + AstrBot + Gsuid-Core 一键部署方案，专为国内网络环境优化。

## 功能特性

- 🚀 **一键部署**: 单脚本启动完整的 QQ 机器人栈
- 🔄 **数据持久化**: 登录会话、配置、数据全部固化到宿主机
- 🇨🇳 **国内优化**: Docker、PyPI、Git 全部使用国内镜像源
- 📦 **三大组件集成**:
  - **NapCat**: NTQQ 协议实现，提供 QQ 连接能力
  - **AstrBot**: 机器人框架，提供插件生态
  - **Gsuid-Core**: 原神/星穹铁道游戏机器人核心

## 目录结构

```
qqbot/
├── 1_dockerInstall/      # Docker 安装脚本 (Ubuntu)
│   ├── install_docker.sh # 带阿里云镜像的 Docker 安装脚本
│   └── README.md
└── 2_napcat_docker/      # 机器人部署目录
    ├── docker-compose.yml
    ├── run_napcat.sh     # 主启动脚本
    ├── fix_docker_mirror.sh # Docker 镜像加速修复
    └── README.md
```

## 快速开始

### 前置要求

- Ubuntu 20.04+ 服务器
- 具有 sudo 权限

### 步骤 1: 安装 Docker

在全新服务器上运行：

```bash
cd 1_dockerInstall
chmod +x install_docker.sh
./install_docker.sh
```

### 步骤 2: (可选) 配置 Docker 镜像加速

如果遇到 Docker 镜像下载超时：

```bash
cd ../2_napcat_docker
chmod +x fix_docker_mirror.sh
./fix_docker_mirror.sh
```

### 步骤 3: 启动机器人服务

```bash
chmod +x run_napcat.sh
./run_napcat.sh
```

脚本会自动：
- 创建所有必要的数据目录
- 设置正确的文件权限
- 克隆 Gsuid-Core 代码
- 启动所有 Docker 容器

## 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| NapCat | 6099 | NTQQ 协议服务 |
| AstrBot | 6185 | 机器人框架 Web 界面 |
| Gsuid-Core | 8765 | 游戏机器人核心 |

## 数据目录

启动后会自动创建以下数据目录：

- `./data` - AstrBot 数据
- `./napcat/config` - NapCat 配置文件
- `./ntqq` - QQ 登录会话数据（重启容器无需重新扫码）
- `./gsuid_core` - Gsuid-Core 源代码
- `./gsuid_data` - Gsuid-Core 数据
- `./gsuid_plugins` - Gsuid-Core 插件目录

## 常用命令

```bash
# 查看运行状态
docker ps

# 查看服务日志
docker logs napcat
docker logs astrbot
docker logs gsuid-core

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 实时查看日志
docker logs -f napcat
```

## 许可证

本项目仅供学习和研究使用。

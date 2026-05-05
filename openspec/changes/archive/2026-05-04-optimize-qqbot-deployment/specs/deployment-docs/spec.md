## ADDED Requirements

### Requirement: 主 README 结构化
项目根目录 `README.md` SHALL 包含以下章节：项目简介、架构概览、环境要求、快速部署、配置参数说明、常见问题排查。

#### Scenario: 新用户阅读 README
- **WHEN** 新用户打开项目 README
- **THEN** 可以按顺序了解项目用途、系统要求、部署步骤，并在遇到问题时查找故障排查章节

### Requirement: 环境要求说明
文档 SHALL 明确列出部署所需的最低环境要求：操作系统（Ubuntu 20.04+）、Docker 版本（20.10+）、Docker Compose V2、内存（2GB+）、磁盘空间（10GB+）、网络要求（中国大陆镜像可访问）。

#### Scenario: 用户检查环境兼容性
- **WHEN** 用户在部署前阅读环境要求
- **THEN** 可以确认自己的服务器是否满足最低要求

### Requirement: 故障排查指南
文档 SHALL 包含常见部署问题及解决方案，至少覆盖：Docker 镜像拉取超时、NapCat 登录失败、AstrBot 连接 NapCat 失败、Gsuid-Core 启动失败、端口冲突、权限问题。

#### Scenario: Docker 镜像拉取超时
- **WHEN** 用户遇到 Docker 镜像拉取超时
- **THEN** 文档提供解决方案：运行 `fix_docker_mirror.sh` 或 `run_napcat.sh --fix-mirror`

#### Scenario: NapCat 登录失败
- **WHEN** 用户遇到 NapCat QQ 登录问题
- **THEN** 文档提供排查步骤：检查 WebUI 访问、确认 QQ 账号状态、查看容器日志

#### Scenario: 端口冲突
- **WHEN** 用户服务器上已有服务占用 6099/6185/8765 端口
- **THEN** 文档说明如何在 `docker-compose.yml` 中修改宿主机端口映射

### Requirement: 配置参数说明
文档 SHALL 列出所有可配置的环境变量和卷挂载路径，包括其用途、默认值和修改方法。

#### Scenario: 用户需要修改端口映射
- **WHEN** 用户想修改 NapCat 的宿主机端口
- **THEN** 文档说明 `docker-compose.yml` 中 `ports` 字段的修改方法

#### Scenario: 用户需要了解数据卷用途
- **WHEN** 用户想了解每个数据卷目录的用途
- **THEN** 文档以表格形式列出所有卷挂载路径、容器内路径和用途说明

### Requirement: 子目录 README 精简
`1_dockerInstall/README.md` 和 `2_napcat_docker/README.md` SHALL 精简为该目录的功能说明和使用方法，避免与主 README 重复。两个子目录 README SHALL 各自包含指向主 README 的链接。

#### Scenario: 用户查看子目录 README
- **WHEN** 用户查看 `2_napcat_docker/README.md`
- **THEN** 获得该目录下文件和脚本的简要说明，以及指向主 README 的链接，无需重复阅读完整部署流程

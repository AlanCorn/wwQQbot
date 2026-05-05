## ADDED Requirements

### Requirement: 脚本统一错误处理
所有 Bash 脚本 SHALL 在顶部启用 `set -euo pipefail`，并通过 `trap` 捕获未处理错误，输出包含脚本名和行号的错误信息。

#### Scenario: 脚本中命令执行失败
- **WHEN** 脚本中任一命令返回非零退出码
- **THEN** 脚本输出包含出错脚本路径和行号的错误信息，并以非零退出码退出

#### Scenario: 脚本中未定义变量被引用
- **WHEN** 脚本引用了未定义的变量
- **THEN** 脚本立即终止并输出错误信息

### Requirement: 彩色日志输出
所有 Bash 脚本 SHALL 提供 `log_info`、`log_warn`、`log_error`、`log_step` 日志函数，使用 ANSI 颜色码区分级别。在非交互终端（`TERM` 未设置或为 `dumb`）中 SHALL 自动降级为无色输出。

#### Scenario: 交互式终端中的日志输出
- **WHEN** 脚本在支持 ANSI 颜色的终端中运行
- **THEN** 日志函数输出带有颜色区分的文本（info=绿色，warn=黄色，error=红色，step=蓝色加粗）

#### Scenario: 非交互终端中的日志输出
- **WHEN** `TERM` 环境变量未设置或为 `dumb`
- **THEN** 日志函数输出无颜色标记的纯文本，保留级别前缀

### Requirement: 部署脚本幂等性
`run_napcat.sh` SHALL 支持重复执行而不破坏已有配置或数据。对于已存在的目录和文件，脚本 SHALL 跳过而非覆盖。

#### Scenario: 重复执行部署脚本
- **WHEN** 用户在已部署的环境中再次运行 `run_napcat.sh`
- **THEN** 脚本正常完成，已有数据目录和配置文件保持不变，容器状态不变或正确重启

#### Scenario: 已存在的 .env 文件
- **WHEN** `.env` 文件已存在
- **THEN** 脚本重新写入 `.env`（更新 UID/GID），但不影响其他已有配置

### Requirement: 部署脚本参数支持
`run_napcat.sh` SHALL 支持 `--fix-mirror` 参数，在部署前执行 Docker 镜像源修复。SHALL 支持 `--help` 参数输出用法说明。

#### Scenario: 使用 --fix-mirror 参数
- **WHEN** 用户运行 `run_napcat.sh --fix-mirror`
- **THEN** 脚本在部署流程前先执行 Docker 镜像源配置（写入 `/etc/docker/daemon.json` 并重启 Docker）

#### Scenario: 使用 --help 参数
- **WHEN** 用户运行 `run_napcat.sh --help`
- **THEN** 脚本输出用法说明并退出，不执行任何部署操作

### Requirement: 前置条件检查
`run_napcat.sh` SHALL 在执行部署前检查 Docker 是否已安装且正在运行。

#### Scenario: Docker 未安装
- **WHEN** 系统中未安装 Docker
- **THEN** 脚本输出明确的错误信息，提示用户运行 `1_dockerInstall/install_docker.sh`，并以非零退出码退出

#### Scenario: Docker 已安装但未运行
- **WHEN** Docker 已安装但守护进程未启动
- **THEN** 脚本输出明确的错误信息，提示用户启动 Docker 服务，并以非零退出码退出

### Requirement: Git safe.directory 精细化
脚本 SHALL 仅对 Gsuid-Core 仓库目录设置 `safe.directory`，而非使用通配符 `*`。

#### Scenario: 设置 safe.directory
- **WHEN** 脚本需要执行 git 操作
- **THEN** 仅对 `${GSUID_CORE_DIR}` 路径执行 `git config --global --add safe.directory`，不使用通配符

### Requirement: Docker 安装脚本健壮性
`install_docker.sh` SHALL 启用 `set -euo pipefail` 和错误 trap，并在安装失败时提供清晰的错误信息。

#### Scenario: Docker GPG 密钥添加失败
- **WHEN** 添加 Docker GPG 密钥时网络不可达
- **THEN** 脚本输出包含错误原因的信息，并提示检查网络连接

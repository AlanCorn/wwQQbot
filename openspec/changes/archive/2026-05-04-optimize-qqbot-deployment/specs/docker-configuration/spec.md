## ADDED Requirements

### Requirement: 服务重启策略
所有三个服务（napcat、astrbot、gsuid-core）SHALL 配置 `restart: unless-stopped` 重启策略。

#### Scenario: 服务异常退出
- **WHEN** 任一服务容器以非零退出码退出
- **THEN** Docker 自动重启该容器

#### Scenario: 用户手动停止服务
- **WHEN** 用户通过 `docker compose stop` 或 `docker stop` 手动停止容器
- **THEN** Docker 不自动重启该容器，直到用户显式启动

#### Scenario: Docker 守护进程重启
- **WHEN** Docker 守护进程重启（如系统重启）
- **THEN** 之前运行中的容器自动启动，之前被手动停止的容器保持停止

### Requirement: 服务健康检查
每个服务 SHALL 配置 HTTP 健康检查，以验证服务实际可用而非仅端口绑定。

#### Scenario: NapCat 健康检查
- **WHEN** NapCat 容器启动
- **THEN** Docker 以 30 秒间隔向 `http://localhost:6099/api/get_login` 发起 HTTP 请求，超时 10 秒，启动等待期 60 秒，连续 3 次失败标记为 unhealthy

#### Scenario: AstrBot 健康检查
- **WHEN** AstrBot 容器启动
- **THEN** Docker 以 30 秒间隔向 `http://localhost:6185/` 发起 HTTP 请求，超时 10 秒，启动等待期 60 秒，连续 3 次失败标记为 unhealthy

#### Scenario: Gsuid-Core 健康检查
- **WHEN** Gsuid-Core 容器启动
- **THEN** Docker 以 30 秒间隔向 `http://localhost:8765/` 发起 HTTP 请求，超时 10 秒，启动等待期 120 秒（因需安装依赖），连续 3 次失败标记为 unhealthy

### Requirement: 日志大小限制
所有服务 SHALL 配置日志驱动限制，防止单个容器日志占用过多磁盘空间。

#### Scenario: 日志文件大小达到上限
- **WHEN** 容器日志文件大小达到 20MB
- **THEN** Docker 轮转日志文件，最多保留 3 个文件

#### Scenario: 日志文件数量达到上限
- **WHEN** 已有 3 个日志轮转文件
- **THEN** Docker 删除最旧的日志文件后创建新文件

### Requirement: Docker Compose 版本声明
`docker-compose.yml` SHALL 使用 `services` 顶级键（Compose V2 格式），不声明已废弃的 `version` 字段。

#### Scenario: Compose 文件格式
- **WHEN** 用户查看 `docker-compose.yml`
- **THEN** 文件使用 `services`、`networks`、`volumes` 顶级键，不含 `version` 字段

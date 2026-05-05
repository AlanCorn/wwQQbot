## Why

当前 QQ Bot 部署项目虽然功能基本可用，但存在脚本健壮性不足、Docker 配置缺少生产级保障（如健康检查、重启策略）、文档分散且缺少故障排查指南等问题。对于新手用户来说，一次失败的部署往往难以自行定位和修复，增加了部署门槛。优化这些方面可以显著提升"一键部署"的成功率和用户体验。

## What Changes

- 重构所有 Bash 脚本：添加统一错误处理（`set -euo pipefail`）、输入校验、幂等性检查、彩色日志输出
- 优化 Docker Compose 配置：添加 `healthcheck`、`restart: unless-stopped`、服务依赖顺序（`depends_on` + condition）、日志驱动限制
- 修复安全问题：移除宽泛的 `git config --global --add safe.directory '*'`，改为仅针对所需仓库设置
- 统一部署入口：合并 `run_napcat.sh` 和 `fix_docker_mirror.sh` 的逻辑，提供可选的镜像修复步骤
- 整合并完善文档：统一 README 结构，添加故障排查指南、环境要求说明、配置参数说明
- 改善 Windows 开发体验：为脚本添加 LF 行尾检查提示或自动转换

## Capabilities

### New Capabilities
- `deployment-automation`: 增强的部署自动化脚本，包含错误处理、输入校验、幂等性、彩色日志、统一入口
- `docker-configuration`: 生产级 Docker Compose 配置，含健康检查、重启策略、服务依赖排序、日志限制
- `deployment-docs`: 整合完善的部署文档，含故障排查、环境要求、配置参数参考

### Modified Capabilities
<!-- 无现有 specs -->

## Impact

- **Bash 脚本**：`run_napcat.sh`、`fix_docker_mirror.sh`、`install_docker.sh` 全部重构
- **Docker 配置**：`docker-compose.yml` 结构调整，新增 healthcheck 和 restart 策略
- **文档**：所有 `README.md` 文件重写/更新，新增故障排查章节
- **向后兼容**：现有部署不受影响，新配置均为增量添加（restart 策略、healthcheck）

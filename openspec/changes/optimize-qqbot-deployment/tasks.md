## 1. 脚本基础设施

- [ ] 1.1 为 `run_napcat.sh` 添加 `set -euo pipefail` 和错误 trap，定义彩色日志函数（log_info/log_warn/log_error/log_step），含非交互终端降级
- [ ] 1.2 为 `install_docker.sh` 添加 `set -euo pipefail` 和错误 trap，定义彩色日志函数
- [ ] 1.3 为 `fix_docker_mirror.sh` 添加 `set -euo pipefail` 和错误 trap，定义彩色日志函数

## 2. 部署脚本增强

- [ ] 2.1 为 `run_napcat.sh` 添加前置条件检查：Docker 是否安装、Docker 守护进程是否运行
- [ ] 2.2 为 `run_napcat.sh` 添加 `--help` 和 `--fix-mirror` 参数解析，整合镜像修复逻辑
- [ ] 2.3 将 `run_napcat.sh` 中 `git config --global --add safe.directory '*'` 替换为仅针对 gsuid_core 仓库目录的精细化设置
- [ ] 2.4 确保 `run_napcat.sh` 幂等性：已存在的目录和配置文件不被覆盖（.env 除外，需更新 UID/GID）

## 3. Docker Compose 配置优化

- [ ] 3.1 移除 `docker-compose.yml` 中已废弃的 `version` 字段
- [ ] 3.2 为所有三个服务添加 `restart: unless-stopped`
- [ ] 3.3 为 napcat 服务添加 HTTP 健康检查（6099 端口，start_period 60s）
- [ ] 3.4 为 astrbot 服务添加 HTTP 健康检查（6185 端口，start_period 60s）
- [ ] 3.5 为 gsuid-core 服务添加 HTTP 健康检查（8765 端口，start_period 120s）
- [ ] 3.6 为所有服务添加日志大小限制配置（max-size 20m，max-file 3）

## 4. 文档更新

- [ ] 4.1 重写项目根 `README.md`：项目简介、架构概览、环境要求、快速部署、配置参数说明、常见问题排查
- [ ] 4.2 精简 `1_dockerInstall/README.md` 为功能说明和使用方法，添加指向主 README 的链接
- [ ] 4.3 精简 `2_napcat_docker/README.md` 为目录结构和脚本说明，添加指向主 README 的链接

# NapCat + AstrBot 部署

此目录包含了部署 NapCat 和 AstrBot 联动环境所需的文件。

## 文件说明

- `docker-compose.yml`: Docker Compose 配置文件，包含 NapCat、AstrBot 和 Gsuid-Core 服务。
- `run_napcat.sh`: 自动化启动脚本（包含 Gsuid-Core 代码自动克隆）。
- `fix_docker_mirror.sh`: **[新增]** Docker 镜像加速修复脚本。如果在启动时遇到 `i/o timeout` 或下载慢的问题，请先运行此脚本。

## 目录结构

脚本运行后会自动创建以下目录以持久化数据（固化路径）：

- `./data`: AstrBot 的数据目录
- `./napcat/config`: NapCat 的配置文件 (对应容器内 `/app/napcat/config`)
- `./ntqq`: NapCat 的 QQ 登录数据 (对应容器内 `/app/.config/QQ`)
  > **注意**：登录后的 session 会保存在这里，重启容器无需再次扫码。
- `./gsuid_core`: Gsuid-Core 源代码 (自动克隆)
- `./gsuid_data`: Gsuid-Core 数据
- `./gsuid_plugins`: Gsuid-Core 插件


## 遇到镜像下载超时怎么办？

如果您在运行启动脚本时遇到 `i/o timeout` 或下载卡住，请先执行以下命令配置国内加速镜像：

```bash
chmod +x fix_docker_mirror.sh
./fix_docker_mirror.sh
```

脚本执行完毕并重启 Docker 后，再继续执行启动步骤。

## 如何使用

1.  赋予脚本执行权限：
    ```bash
    chmod +x run_napcat.sh
    ```

2.  运行脚本启动服务：
    ```bash
    ./run_napcat.sh
    ```

## 脚本功能

脚本会自动执行以下操作：
1.  **权限管理**：获取当前用户的 UID/GID 并写入 `.env` 文件，确保容器以正确权限运行。
2.  **目录初始化**：预先创建挂载目录，防止 Docker 以 root 权限创建导致读写问题。
3.  **服务启动**：调用 Docker Compose 启动所有服务。

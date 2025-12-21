# NapCat + AstrBot 部署

此目录包含了部署 NapCat 和 AstrBot 联动环境所需的文件。

## 文件说明

- `docker-compose.yml`: Docker Compose 配置文件，包含 NapCat 和 AstrBot 两个服务。
- `run_napcat.sh`: 自动化启动脚本。

## 目录结构

脚本运行后会自动创建以下目录以持久化数据：

- `./data`: AstrBot 的数据目录 (NapCat 也会访问)
- `./napcat/config`: NapCat 的配置文件
- `./ntqq`: NapCat 的 QQ 登录数据

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

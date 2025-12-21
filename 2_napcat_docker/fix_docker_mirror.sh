#!/bin/bash

# 脚本功能：配置 Docker 镜像加速器 (解决国内拉取镜像超时/403问题)

echo "正在配置 Docker 镜像加速器..."

# 1. 确保 /etc/docker 目录存在
sudo mkdir -p /etc/docker

# 2. 写入 daemon.json 配置文件
# 更新镜像源列表，移除可能导致 403 错误的源，优先使用更稳定的源
echo "写入配置文件 /etc/docker/daemon.json..."
sudo tee /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://docker.1panel.live",
        "https://hub.rat.dev",
        "https://docker.anyhub.us.kg",
        "https://dockerproxy.net"
    ]
}
EOF

# 3. 重启 Docker 服务以应用更改
echo "正在重启 Docker 服务..."
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "========================================"
echo "配置完成！Docker 服务已重启。"
echo "请重新尝试运行 './run_napcat.sh'"
echo "========================================"

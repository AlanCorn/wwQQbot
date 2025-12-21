#!/bin/bash

# 获取当前用户的 UID 和 GID
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "检测到当前用户 UID: $CURRENT_UID"
echo "检测到当前用户 GID: $CURRENT_GID"

# 预先创建挂载目录，确保权限正确 (避免 Docker 自动创建为 root 权限)
echo "正在检查并创建挂载目录..."
mkdir -p data
mkdir -p napcat/config
mkdir -p ntqq

echo "挂载目录准备完成。"

# 创建或更新 .env 文件
echo "正在生成 .env 文件..."
echo "NAPCAT_UID=$CURRENT_UID" > .env
echo "NAPCAT_GID=$CURRENT_GID" >> .env
echo ".env 文件已更新。"

# 启动容器
echo "正在启动服务 (NapCat + AstrBot)..."
if docker compose version >/dev/null 2>&1; then
    docker compose up -d
elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose up -d
else
    echo "错误: 未找到 docker compose 或 docker-compose 命令。"
    echo "请先安装 Docker Compose。"
    exit 1
fi

echo "=================================================="
echo "服务已启动！"
echo "你可以使用 'docker ps' 查看运行状态。"
echo "NapCat 配置目录: ./napcat/config"
echo "NapCat 数据目录: ./ntqq"
echo "AstrBot 数据目录: ./data"
echo "=================================================="

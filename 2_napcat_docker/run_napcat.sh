#!/bin/bash

# 获取当前用户的 UID 和 GID
# 如果使用 sudo 运行，尝试获取原始用户的 UID/GID，否则使用当前用户 (root)
CURRENT_UID=${SUDO_UID:-$(id -u)}
CURRENT_GID=${SUDO_GID:-$(id -g)}

echo "检测到实际用户 UID: $CURRENT_UID"
echo "检测到实际用户 GID: $CURRENT_GID"

# 预先创建挂载目录，确保权限正确 (避免 Docker 自动创建为 root 权限)
echo "正在检查并创建挂载目录..."
# 使用 install -d -o -g 可以直接指定所有者创建目录，或者创建后 chown
mkdir -p data
mkdir -p napcat/config
mkdir -p ntqq
mkdir -p gsuid_data
mkdir -p gsuid_cache
mkdir -p gsuid_plugins

# 统一处理所有目录的权限（无论是否新建）
# 1. 修正所有者：让宿主机用户可以编辑 (如果使用 sudo)
if [ "$EUID" -eq 0 ] && [ "$CURRENT_UID" -ne 0 ]; then
    echo "修正所有目录权限为 UID $CURRENT_UID..."
    # 包含 gsuid_core 代码目录
    chown -R "$CURRENT_UID:$CURRENT_GID" data napcat ntqq gsuid_data gsuid_cache gsuid_plugins gsuid_core
fi

# # 2. 放宽权限：由于我们已经在 docker-compose.yml 中指定了 user: UID:GID，
# 容器将以宿主机用户身份运行，因此不需要暴力 777，标准的 755 即可
chmod -R 755 gsuid_data gsuid_cache gsuid_plugins gsuid_core

# 处理 gsuid_start 启动脚本目录
# 注意：之前版本可能创建了名为 gsuid_start 的文件，这里需要清理并改为目录
if [ -f "gsuid_start" ]; then
    rm -f gsuid_start
fi
if [ ! -d "gsuid_start" ]; then
    mkdir -p gsuid_start
fi

echo "生成 Gsuid-Core 启动脚本 (gsuid_start/gsuid_start.sh)..."
cat > gsuid_start/gsuid_start.sh <<EOF
#!/bin/bash
set -e

# 设置 HOME 环境变量，确保 git config 有权限写入
export HOME=/app/data

# 修复 git 目录权限问题 (dubious ownership)
git config --global --add safe.directory '*'

# 启动 Gsuid Core
poetry run core
EOF
chmod +x gsuid_start/gsuid_start.sh

# 修正目录权限
if [ "$EUID" -eq 0 ] && [ "$CURRENT_UID" -ne 0 ]; then
    chown -R "$CURRENT_UID:$CURRENT_GID" gsuid_start
fi

# 检查并克隆 Gsuid-Core 代码
if [ ! -d "gsuid_core" ]; then
    echo "未检测到 gsuid_core 代码，正在从镜像源克隆..."
    # 尝试使用国内镜像源
    if git clone --depth=1 --single-branch https://cnb.cool/gscore-mirror/gsuid_core.git gsuid_core; then
        echo "克隆成功 (CNB)。"
    else
        echo "国内镜像源失败，尝试 GitHub..."
        git clone --depth=1 --single-branch https://github.com/Genshin-bots/gsuid_core.git gsuid_core
    fi
else
    echo "gsuid_core 代码目录已存在，跳过克隆。"
fi

echo "挂载目录准备完成。"

# 创建或更新 .env 文件
echo "正在生成 .env 文件..."
echo "NAPCAT_UID=$CURRENT_UID" > .env
echo "NAPCAT_GID=$CURRENT_GID" >> .env
echo ".env 文件已更新。"

# 启动容器
echo "正在启动服务 (NapCat + AstrBot + Gsuid-Core)..."
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
echo "Gsuid-Core 目录: ./gsuid_core"
echo "=================================================="

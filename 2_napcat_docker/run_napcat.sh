#!/bin/bash
set -euo pipefail

# ============================================================
# QQ Bot 一键部署脚本
# 部署 NapCat + AstrBot + Gsuid-Core Docker 服务栈
# ============================================================

# --- 错误处理 ---
on_error() {
    local exit_code=$?
    local line_no=$1
    log_error "脚本执行失败 (行号: ${line_no}, 退出码: ${exit_code})"
    log_error "请检查上方错误信息，或查看文档中的故障排查章节"
    exit "$exit_code"
}
trap 'on_error ${LINENO}' ERR

# --- 彩色日志 ---
if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]; then
    _RED='\033[0;31m'
    _GREEN='\033[0;32m'
    _YELLOW='\033[1;33m'
    _BLUE='\033[1;34m'
    _BOLD='\033[1m'
    _RESET='\033[0m'
else
    _RED='' _GREEN='' _YELLOW='' _BLUE='' _BOLD='' _RESET=''
fi

log_info()  { printf "${_GREEN}[INFO]${_RESET}  %s\n" "$*"; }
log_warn()  { printf "${_YELLOW}[WARN]${_RESET}  %s\n" "$*"; }
log_error() { printf "${_RED}[ERROR]${_RESET} %s\n" "$*" >&2; }
log_step()  { printf "\n${_BLUE}${_BOLD}[STEP]${_RESET} %s\n" "$*"; }

# --- 参数解析 ---
FIX_MIRROR=false

show_help() {
    cat <<EOF
用法: $(basename "$0") [选项]

QQ Bot 一键部署脚本，部署 NapCat + AstrBot + Gsuid-Core 服务栈。

选项:
  --fix-mirror   部署前先配置 Docker 镜像加速器
  --help         显示此帮助信息并退出

示例:
  $(basename "$0")              # 正常部署
  $(basename "$0") --fix-mirror # 先修复镜像源再部署
EOF
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --fix-mirror) FIX_MIRROR=true ;;
        --help|-h)    show_help ;;
        *)
            log_error "未知参数: $arg"
            log_error "运行 '$(basename "$0") --help' 查看用法"
            exit 1
            ;;
    esac
done

# --- 前置条件检查 ---
log_step "检查前置条件"

if ! command -v docker &>/dev/null; then
    log_error "Docker 未安装"
    log_error "请先运行: cd 1_dockerInstall && ./install_docker.sh"
    exit 1
fi
log_info "Docker 已安装: $(docker --version)"

if ! docker info &>/dev/null; then
    log_error "Docker 守护进程未运行"
    log_error "请尝试: sudo systemctl start docker"
    exit 1
fi
log_info "Docker 守护进程运行正常"

# --- 镜像加速修复（可选）---
if [ "$FIX_MIRROR" = true ]; then
    log_step "配置 Docker 镜像加速器"
    sudo mkdir -p /etc/docker
    log_info "写入 /etc/docker/daemon.json ..."
    sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
    "registry-mirrors": [
        "https://docker.1panel.live",
        "https://hub.rat.dev",
        "https://docker.anyhub.us.kG",
        "https://dockerproxy.net"
    ]
}
EOF
    log_info "重启 Docker 服务..."
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    log_info "Docker 镜像加速器配置完成"
fi

# --- 获取用户 UID/GID ---
log_step "检测用户权限"
CURRENT_UID=${SUDO_UID:-$(id -u)}
CURRENT_GID=${SUDO_GID:-$(id -g)}
log_info "用户 UID: $CURRENT_UID, GID: $CURRENT_GID"

# --- 创建挂载目录 ---
log_step "检查并创建挂载目录"
for dir in data napcat/config ntqq gsuid_data gsuid_cache gsuid_plugins; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_info "已创建: $dir"
    else
        log_info "已存在: $dir (跳过)"
    fi
done

# 修正目录所有者
if [ "$EUID" -eq 0 ] && [ "$CURRENT_UID" -ne 0 ]; then
    log_info "修正目录权限为 UID $CURRENT_UID ..."
    chown -R "$CURRENT_UID:$CURRENT_GID" data napcat ntqq gsuid_data gsuid_cache gsuid_plugins gsuid_core 2>/dev/null || true
fi

chmod -R 755 gsuid_data gsuid_cache gsuid_plugins gsuid_core 2>/dev/null || true

# --- 处理 gsuid_start ---
log_step "准备 Gsuid-Core 启动脚本"
if [ -f "gsuid_start" ]; then
    rm -f gsuid_start
    log_info "已清理旧版 gsuid_start 文件"
fi
if [ ! -d "gsuid_start" ]; then
    mkdir -p gsuid_start
fi

log_info "生成 gsuid_start/gsuid_start.sh ..."
cat > gsuid_start/gsuid_start.sh <<'STARTUP_EOF'
#!/bin/bash
set -e

export HOME=/app/data

# 仅针对 gsuid_core 仓库设置 safe.directory（避免使用通配符 *）
git config --global --add safe.directory /gsuid_core

# 修复 requirements.txt 中的哈希值冲突问题
sed -i '/^-e \./d' /app/requirements.txt || true
sed -i '/^--hash=/d' /app/requirements.txt || true

# 安装 Node.js 22
if ! command -v node &> /dev/null; then
    echo "正在安装 Node.js 22..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
    node --version
    npm --version
fi

# 配置 uv 使用清华源
export UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple/

# 安装额外依赖
echo "正在使用 uv 安装依赖..."
cd /app && uv pip install --system playwright opencv-python fonttools 2>/dev/null || true

# 启动 Gsuid Core
cd /app && uv run core
STARTUP_EOF
chmod +x gsuid_start/gsuid_start.sh

if [ "$EUID" -eq 0 ] && [ "$CURRENT_UID" -ne 0 ]; then
    chown -R "$CURRENT_UID:$CURRENT_GID" gsuid_start
fi

# --- 克隆 Gsuid-Core ---
log_step "检查 Gsuid-Core 代码"
if [ ! -d "gsuid_core" ]; then
    log_info "正在从镜像源克隆 gsuid_core ..."
    if git clone --depth=1 --single-branch https://cnb.cool/gscore-mirror/gsuid_core.git gsuid_core; then
        log_info "克隆成功 (CNB 镜像)"
    else
        log_warn "CNB 镜像失败，尝试 GitHub ..."
        git clone --depth=1 --single-branch https://github.com/Genshin-bots/gsuid_core.git gsuid_core
        log_info "克隆成功 (GitHub)"
    fi
else
    log_info "gsuid_core 代码目录已存在，跳过克隆"
fi

# --- 生成 .env ---
log_step "生成 .env 文件"
cat > .env <<EOF
NAPCAT_UID=$CURRENT_UID
NAPCAT_GID=$CURRENT_GID
EOF
log_info ".env 文件已更新 (UID=$CURRENT_UID, GID=$CURRENT_GID)"

# --- 启动容器 ---
log_step "启动服务 (NapCat + AstrBot + Gsuid-Core)"
if docker compose version &>/dev/null; then
    docker compose up -d
elif command -v docker-compose &>/dev/null; then
    docker-compose up -d
else
    log_error "未找到 docker compose 或 docker-compose 命令"
    log_error "请先安装 Docker Compose: cd 1_dockerInstall && ./install_docker.sh"
    exit 1
fi

log_step "部署完成"
printf "${_GREEN}${_BOLD}==================================================${_RESET}\n"
printf "${_GREEN}服务已启动！${_RESET}\n"
printf "  NapCat 配置目录:   ./napcat/config\n"
printf "  NapCat 数据目录:   ./ntqq\n"
printf "  AstrBot 数据目录:  ./data\n"
printf "  Gsuid-Core 目录:   ./gsuid_core\n"
printf "  查看运行状态:      docker ps\n"
printf "  查看服务日志:      docker logs <容器名>\n"
printf "${_GREEN}${_BOLD}==================================================${_RESET}\n"

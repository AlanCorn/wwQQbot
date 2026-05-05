#!/bin/bash
set -euo pipefail

# ============================================================
# Docker 安装脚本 (使用阿里云镜像，适用于国内服务器)
# ============================================================

# --- 错误处理 ---
on_error() {
    local exit_code=$?
    local line_no=$1
    log_error "安装失败 (行号: ${line_no}, 退出码: ${exit_code})"
    log_error "常见原因: 网络连接问题、apt 锁被占用"
    log_error "如网络超时，请检查服务器是否可访问 mirrors.aliyun.com"
    exit "$exit_code"
}
trap 'on_error ${LINENO}' ERR

# --- 彩色日志 ---
if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]; then
    _RED='\033[0;31m' _GREEN='\033[0;32m' _YELLOW='\033[1;33m' _BLUE='\033[1;34m' _BOLD='\033[1m' _RESET='\033[0m'
else
    _RED='' _GREEN='' _YELLOW='' _BLUE='' _BOLD='' _RESET=''
fi

log_info()  { printf "${_GREEN}[INFO]${_RESET}  %s\n" "$*"; }
log_warn()  { printf "${_YELLOW}[WARN]${_RESET}  %s\n" "$*"; }
log_error() { printf "${_RED}[ERROR]${_RESET} %s\n" "$*" >&2; }
log_step()  { printf "\n${_BLUE}${_BOLD}[STEP]${_RESET} %s\n" "$*"; }

# --- 清理旧配置 ---
log_step "清理旧的 Docker 配置"
sudo rm -f /etc/apt/keyrings/docker.gpg /etc/apt/keyrings/docker.asc
sudo rm -f /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.sources
log_info "旧配置已清理"

# --- 更新包索引 ---
log_step "更新包索引"
sudo apt update

# --- 安装依赖 ---
log_step "安装依赖"
sudo apt install -y ca-certificates curl

# --- GPG 密钥 ---
log_step "添加 Docker GPG 密钥 (阿里云镜像)"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc
log_info "GPG 密钥已添加"

# --- Docker 仓库 ---
log_step "设置 Docker 仓库 (阿里云镜像)"
echo \
  "Types: deb
URIs: https://mirrors.aliyun.com/docker-ce/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null
log_info "Docker 仓库已配置"

# --- 安装 Docker ---
log_step "安装 Docker"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
log_info "Docker 已安装"

# --- 启动 Docker ---
log_step "启动 Docker 并设置开机自启"
sudo systemctl start docker
sudo systemctl enable docker
log_info "Docker 已启动并设置为开机自启"

# --- 验证 ---
log_step "验证安装"
docker --version

# --- 配置 Docker Compose 包装脚本 ---
log_step "配置 Docker Compose"
if docker compose version &>/dev/null; then
    log_info "Docker Compose 插件已检测到"
    cat <<'EOF' | sudo tee /usr/local/bin/docker-compose > /dev/null
#!/bin/bash
exec docker compose "$@"
EOF
    sudo chmod +x /usr/local/bin/docker-compose
    log_info "docker-compose 包装脚本已创建"
else
    log_warn "Docker Compose 插件未找到，跳过包装脚本创建"
fi

# --- 验证 Compose ---
if command -v docker-compose &>/dev/null; then
    docker-compose version
else
    docker compose version
fi

log_step "安装完成"
printf "${_GREEN}${_BOLD}Docker 安装成功！${_RESET}\n"
printf "下一步: cd 2_napcat_docker && ./run_napcat.sh\n"

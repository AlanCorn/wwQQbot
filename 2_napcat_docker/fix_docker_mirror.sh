#!/bin/bash
set -euo pipefail

# ============================================================
# Docker 镜像加速器配置脚本
# 解决国内拉取镜像超时/403问题
# ============================================================

# --- 错误处理 ---
on_error() {
    local exit_code=$?
    local line_no=$1
    log_error "镜像加速配置失败 (行号: ${line_no}, 退出码: ${exit_code})"
    log_error "请确认您具有 sudo 权限，且 Docker 已安装"
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

# --- 前置检查 ---
if ! command -v docker &>/dev/null; then
    log_error "Docker 未安装，请先运行: cd 1_dockerInstall && ./install_docker.sh"
    exit 1
fi

# --- 配置镜像加速 ---
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

log_step "配置完成"
printf "${_GREEN}${_BOLD}Docker 镜像加速器已配置，服务已重启${_RESET}\n"
printf "请重新运行: ./run_napcat.sh\n"

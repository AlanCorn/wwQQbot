#!/bin/bash

# 步驟 1：安裝 Docker (使用阿里云镜像，适用于国内服务器)

# 清理旧的配置
echo "Cleaning up potential old configurations..."
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo rm -f /etc/apt/keyrings/docker.asc
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/sources.list.d/docker.sources

# 1.1. 更新
echo "Updating package index..."
sudo apt update

# 1.2. 安裝 dependencies
echo "Installing dependencies..."
sudo apt install -y ca-certificates curl

# 1.3. 建立目錄存放 GPG 金鑰
echo "Creating directory for GPG keys..."
sudo install -m 0755 -d /etc/apt/keyrings

# 1.4. 添加 Docker 的官方 GPG 密鑰 (使用阿里云镜像)
echo "Adding Docker GPG key from Aliyun..."
# 注意：阿里云镜像有时也使用 .gpg 后缀，这里为了兼容性使用 curl 下载并根据内容判断
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 1.5. 設置 Docker 官方穩定版 repository (使用阿里云镜像)
echo "Setting up Docker repository (Aliyun)..."
echo \
  "Types: deb
URIs: https://mirrors.aliyun.com/docker-ce/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null

# 1.6. 安裝 Docker
echo "Installing Docker..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 1.7. 啟動 Docker 並設置開機自動啟動
echo "Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# 1.8. 驗證 Docker 是否安裝成功
echo "Verifying Docker installation..."
docker --version

# 步驟 2：配置 Docker Compose
# 由于 GitHub 在国内访问不稳定，我们直接使用 docker-compose-plugin 提供的 'docker compose' 命令
# 并创建一个 wrapper 脚本，使得 'docker-compose' 命令也能使用

echo "Configuring Docker Compose..."

# 检查 docker compose 插件是否可用
if docker compose version >/dev/null 2>&1; then
    echo "Docker Compose plugin detected."
    
    # 创建 /usr/local/bin/docker-compose 包装脚本
    echo "Creating 'docker-compose' wrapper script..."
    cat <<EOF | sudo tee /usr/local/bin/docker-compose > /dev/null
#!/bin/bash
exec docker compose "\$@"
EOF
    
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Wrapper script created at /usr/local/bin/docker-compose"
else
    echo "Warning: Docker Compose plugin not found. Skipping wrapper creation."
fi

# 2.3. 驗證 Docker Compose 是否安裝成功
echo "Verifying Docker Compose installation..."
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose version
else
    echo "docker-compose command not found, but you can try 'docker compose' directly."
    docker compose version
fi

echo "Installation complete!"

# 步驟 1：安裝 Docker (使用阿里云镜像)

> **注意**：由于您的服务器位于国内（阿里云），直接访问 Docker 官方源可能会失败。以下配置已修改为使用阿里云镜像源，以确保下载速度和稳定性。

## 1.1. 更新
```bash
sudo apt update
```

## 1.2. 安裝 dependencies
```bash
sudo apt install ca-certificates curl
```

## 1.3. 建立目錄存放 GPG 金鑰
```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

## 1.4. 添加 Docker 的官方 GPG 密鑰 (阿里云)
```bash
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

## 1.5. 設置 Docker 官方穩定版 repository (阿里云)
```bash
echo \
  "Types: deb
URIs: https://mirrors.aliyun.com/docker-ce/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null
```

## 1.6. 安裝 Docker
```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 1.7. 啟動 Docker 並設置開機自動啟動
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

## 1.8. 驗證 Docker 是否安裝成功
通過以下命令檢查 Docker 版本，確認是否安裝成功：
```bash
docker --version
```

# 步驟 2：配置 Docker Compose

> **注意**: 由于 GitHub 下载在国内经常超时，我们利用 `docker-ce` 自带的 `docker-compose-plugin` 来实现 Compose 功能，并创建一个兼容的 `docker-compose` 命令。

脚本会自动创建一个 `/usr/local/bin/docker-compose` 的包装脚本，内容如下：
```bash
#!/bin/bash
exec docker compose "$@"
```
这样您既可以使用新版的 `docker compose` 命令，也可以继续使用旧习惯的 `docker-compose` 命令。

## 驗證 Docker Compose
```bash
docker-compose version
```
或者
```bash
docker compose version
```

# 步驟 3：執行 docker-compose.yml
假设已经有一个 `docker-compose.yml` 文件。

## 3.1. 啟動 Docker Compose
```bash
sudo docker-compose up -d
```

## 3.2. 停止並刪除 container
```bash
sudo docker-compose down
```

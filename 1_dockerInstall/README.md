# Docker 安装脚本

使用阿里云镜像源在 Ubuntu 上安装 Docker CE，适用于国内服务器环境。

## 使用方法

```bash
chmod +x install_docker.sh
sudo ./install_docker.sh
```

## 脚本功能

- 清理旧版 Docker 配置
- 使用阿里云镜像添加 Docker GPG 密钥和仓库
- 安装 Docker CE、CLI、containerd、Buildx 和 Compose 插件
- 启动 Docker 并设置开机自启
- 创建 `docker-compose` 包装脚本（兼容旧命令）

## 安装后验证

```bash
docker --version
docker compose version
```

---

> 完整部署流程请参考[项目主 README](../README.md)。

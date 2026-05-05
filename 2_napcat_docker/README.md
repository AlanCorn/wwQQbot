# NapCat + AstrBot 部署目录

此目录包含 QQ Bot 服务栈的部署文件。

## 文件说明

| 文件 | 说明 |
|------|------|
| `docker-compose.yml` | 三个服务的编排配置 |
| `run_napcat.sh` | 一键部署脚本（含 `--fix-mirror` 选项） |
| `fix_docker_mirror.sh` | Docker 镜像加速修复（独立工具） |

## 使用方法

```bash
chmod +x run_napcat.sh
./run_napcat.sh              # 正常部署
./run_napcat.sh --fix-mirror # 先修复镜像源再部署
./run_napcat.sh --help       # 查看帮助
```

## 数据目录

脚本运行后自动创建以下持久化目录：

- `./data` — AstrBot 数据
- `./napcat/config` — NapCat 配置
- `./ntqq` — QQ 登录会话（重启免扫码）
- `./gsuid_core` — Gsuid-Core 源代码（自动克隆）
- `./gsuid_data` — Gsuid-Core 数据
- `./gsuid_plugins` — Gsuid-Core 插件

---

> 完整部署流程和故障排查请参考[项目主 README](../README.md)。

# 🐳 MediaCrawler Docker 部署指南

本指南介绍如何使用 Docker 部署 MediaCrawler 项目。

## 📋 前置要求

- Docker 20.10+
- Docker Compose 2.0+

## 🚀 快速开始

### 1. 构建和启动服务

```bash
# 构建并启动所有服务（包括 MySQL 和 Redis）
docker-compose up -d

# 仅启动 MediaCrawler（不启动数据库）
docker-compose up -d mediacrawler
```

### 2. 访问 WebUI

启动成功后，在浏览器访问：
```
http://localhost:8080
```

### 3. 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 仅查看 MediaCrawler 日志
docker-compose logs -f mediacrawler
```

## 🔧 使用命令行模式

### 方式一：使用 docker-compose

```bash
# 小红书关键词搜索
docker-compose run --rm mediacrawler crawl --platform xhs --lt qrcode --type search

# 抖音详情爬取
docker-compose run --rm mediacrawler crawl --platform dy --lt qrcode --type detail

# B站创作者主页爬取
docker-compose run --rm mediacrawler crawl --platform bili --lt qrcode --type creator
```

### 方式二：直接使用 docker exec

```bash
# 进入容器
docker exec -it mediacrawler bash

# 在容器内执行爬虫命令
python main.py --platform xhs --lt qrcode --type search
```

## 📁 数据持久化

项目会自动在宿主机创建以下目录用于数据持久化：

```
MediaCrawler/
├── data/           # 爬取的数据文件
├── logs/           # 日志文件
├── browser_data/   # 浏览器缓存和登录态
└── config/         # 配置文件
```

## ⚙️ 配置说明

### 修改配置文件

编辑 `config/base_config.py` 文件：

```python
# 平台选择
PLATFORM = "xhs"  # xhs | dy | ks | bili | wb | tieba | zhihu

# 关键词配置
KEYWORDS = "编程副业,编程兼职"

# 登录方式
LOGIN_TYPE = "qrcode"  # qrcode | phone | cookie

# 爬取类型
CRAWLER_TYPE = "search"  # search | detail | creator

# 无头模式（Docker 中建议设置为 True）
HEADLESS = True
```

### 环境变量配置

在 `docker-compose.yml` 中可以配置：

```yaml
environment:
  - TZ=Asia/Shanghai           # 时区
  - MYSQL_HOST=mysql           # MySQL 主机
  - REDIS_HOST=redis           # Redis 主机
```

## 🗄️ 数据库配置

### 使用 MySQL

1. 修改 `config/db_config.py`：
```python
RELATION_DB_PWD = "mediacrawler_password"
RELATION_DB_HOST = "mysql"
RELATION_DB_PORT = 3306
RELATION_DB_USER = "mediacrawler"
RELATION_DB_NAME = "media_crawler"
```

2. 启动数据库服务：
```bash
docker-compose up -d mysql
```

### 使用 Redis

1. 修改相应配置：
```python
REDIS_DB_HOST = "redis"
REDIS_DB_PWD = "redis_password"
```

2. 启动 Redis：
```bash
docker-compose up -d redis
```

## 📊 服务管理

### 启动服务
```bash
docker-compose up -d
```

### 停止服务
```bash
docker-compose down
```

### 重启服务
```bash
docker-compose restart mediacrawler
```

### 查看运行状态
```bash
docker-compose ps
```

### 删除所有数据和容器
```bash
docker-compose down -v
```

## 🔍 常见问题

### 1. 二维码登录问题

Docker 中使用二维码登录的两种方式：

**方式一：使用 WebUI**
- 访问 http://localhost:8080
- 在 WebUI 界面中会显示二维码
- 使用手机 APP 扫码登录

**方式二：临时关闭无头模式**
- 设置 `HEADLESS = False`
- 重启容器
- 会弹出浏览器窗口供扫码（需要 X11 转发）

### 2. 浏览器无法启动

如果遇到 Playwright 浏览器启动失败：

```bash
# 重新安装浏览器
docker exec -it mediacrawler playwright install chromium
docker exec -it mediacrawler playwright install-deps chromium
```

### 3. 权限问题

如果遇到文件权限问题：

```bash
# 修改数据目录权限
chmod -R 777 data logs browser_data
```

### 4. 内存不足

如果爬取大量数据时内存不足，可以在 `docker-compose.yml` 中调整资源限制：

```yaml
deploy:
  resources:
    limits:
      cpus: '4'
      memory: 8G
```

## 🎯 生产环境建议

1. **安全性**
   - 修改默认数据库密码
   - 使用环境变量文件 `.env` 管理敏感信息
   - 限制端口暴露范围

2. **性能优化**
   - 使用 Redis 缓存
   - 启用 IP 代理池
   - 调整并发数

3. **监控**
   - 定期检查日志
   - 监控磁盘使用情况
   - 设置告警机制

## 📝 仅构建镜像（不启动）

```bash
# 构建镜像
docker-compose build

# 或使用 docker 命令
docker build -t mediacrawler:latest .
```

## 🔄 更新项目

```bash
# 停止服务
docker-compose down

# 拉取最新代码
git pull

# 重新构建并启动
docker-compose up -d --build
```

## 💡 高级用法

### 自定义启动命令

在 `docker-compose.yml` 中修改 `command` 参数：

```yaml
command: ["crawl", "--platform", "xhs", "--lt", "qrcode", "--type", "search"]
```

### 使用外部网络

```yaml
networks:
  mediacrawler_network:
    external: true
    name: my_custom_network
```

## 📞 获取帮助

- 查看项目文档：[GitHub Repository](https://github.com/NanmiCoder/MediaCrawler)
- 提交问题：[Issues](https://github.com/NanmiCoder/MediaCrawler/issues)

---

**注意**：本项目仅供学习研究使用，请遵守相关平台的使用条款和 robots.txt 规则。

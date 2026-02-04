# MediaCrawler Dockerfile
# 多阶段构建，支持 Python + Node.js + Playwright

FROM python:3.11-slim as base

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DEBIAN_FRONTEND=noninteractive

# 安装系统依赖和 Node.js
RUN apt-get update && apt-get install -y --no-install-recommends \
    # 基础工具
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    # 编译工具（用于构建 Python 包）
    gcc \
    g++ \
    make \
    build-essential \
    python3-dev \
    libmariadb-dev \
    pkg-config \
    # OpenCV 依赖库
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    # Playwright 浏览器依赖
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
    libwayland-client0 \
    # 中文字体支持
    fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js (版本 18 LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv 包管理器
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY requirements.txt pyproject.toml ./

# 使用 uv 安装 Python 依赖（更快）
RUN uv pip install --system --no-cache -r requirements.txt

# 安装 Playwright 浏览器（Chromium）
# 先安装浏览器，然后手动安装系统依赖（忽略字体包错误）
RUN playwright install chromium
RUN playwright install-deps chromium || true

# 复制项目文件
COPY . .

# 创建数据目录
RUN mkdir -p /app/data /app/logs /app/browser_data

# 暴露端口（WebUI 使用）
EXPOSE 8080

# 设置启动脚本
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

# 默认命令：启动 WebUI
CMD ["webui"]

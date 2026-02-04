#!/bin/bash
# MediaCrawler Docker 入口脚本

set -e

# 显示欢迎信息
echo "========================================"
echo "  MediaCrawler Docker Container"
echo "========================================"
echo ""

# 检查命令类型
case "$1" in
    webui)
        echo "🚀 启动 WebUI 模式..."
        echo "📱 访问地址: http://localhost:8080"
        exec uvicorn api.main:app --host 0.0.0.0 --port 8080
        ;;
    
    crawl)
        echo "🕷️  启动爬虫模式..."
        shift
        exec python main.py "$@"
        ;;
    
    bash|sh)
        echo "🔧 进入调试模式..."
        exec /bin/bash
        ;;
    
    *)
        # 如果是其他命令，直接执行
        exec "$@"
        ;;
esac

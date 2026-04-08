#!/bin/bash
set -e

# 定义复制函数，仅在源目录存在且非空时执行覆盖
copy_if_exists() {
    if [ -d "$1" ] && [ -n "$(ls -A $1 2>/dev/null)" ]; then
        echo "  - Copying $1 to $2"
        cp -rf $1/* $2/
    fi
}

# 1. 处理单文件配置（原有逻辑）
if [ -f /config/config.toml ]; then
    cp /config/config.toml /app/exampleSite/config.toml
    echo "  - config.toml updated"
fi

if [ -f /config/webstack.yml ]; then
    cp /config/webstack.yml /app/exampleSite/data/webstack.yml
    echo "  - webstack.yml updated"
fi

# 2. 处理目录覆盖（新增）
echo "Checking for custom directories..."
copy_if_exists /data/exampleSite /app/exampleSite
copy_if_exists /data/layouts    /app/layouts
copy_if_exists /data/static     /app/static

# 3. 重新生成静态文件（只要有任一配置或目录变更，就执行）
if [ -f /config/config.toml ] || [ -f /config/webstack.yml ] || \
   [ -d /data/exampleSite ] || [ -d /data/layouts ] || [ -d /data/static ]; then
    echo "Regenerating static site..."
    cd /app/exampleSite
    hugo --minify --destination /usr/share/nginx/html
    echo "Static site regenerated."
else
    echo "No custom config or directories provided, using default built-in static files."
fi

# 4. 启动 Nginx
nginx -g "daemon off;"

#!/bin/bash
set -e

# 如果挂载了自定义配置文件，则覆盖并重新生成静态文件
if [ -f /config/config.toml ] || [ -f /config/webstack.yml ]; then
    echo "Custom config detected, regenerating static site..."

    # 覆盖配置（如果存在）
    if [ -f /config/config.toml ]; then
        cp /config/config.toml /app/exampleSite/config.toml
        echo "  - config.toml updated"
    fi

    if [ -f /config/webstack.yml ]; then
        cp /config/webstack.yml /app/exampleSite/data/webstack.yml
        echo "  - webstack.yml updated"
    fi

    # 重新生成静态文件到 Nginx 目录
    cd /app/exampleSite
    hugo --minify --destination /usr/share/nginx/html
    echo "Static site regenerated."
else
    echo "No custom config provided, using default built-in static files."
fi

# 启动 Nginx
nginx -g "daemon off;"

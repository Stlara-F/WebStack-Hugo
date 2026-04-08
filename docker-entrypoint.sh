#!/bin/bash
set -e

# 定义默认站点目录
SITE_DIR="/app/exampleSite"

# 如果用户提供了完整的 exampleSite 目录，则直接替换整个站点
if [ -d "/data/exampleSite" ]; then
    echo "Detected custom /data/exampleSite, replacing default site..."
    rm -rf "$SITE_DIR"
    cp -r /data/exampleSite "$SITE_DIR"
else
    echo "No full exampleSite provided, applying incremental overrides..."

    # 单独覆盖配置文件
    if [ -f "/data/config.toml" ]; then
        cp /data/config.toml "$SITE_DIR/config.toml"
        echo "  - config.toml updated"
    fi

    if [ -f "/data/webstack.yml" ]; then
        cp /data/webstack.yml "$SITE_DIR/data/webstack.yml"
        echo "  - webstack.yml updated"
    fi

    # 覆盖 layouts 目录（如果存在）
    if [ -d "/data/layouts" ]; then
        mkdir -p "$SITE_DIR/layouts"
        cp -r /data/layouts/* "$SITE_DIR/layouts/"
        echo "  - layouts/ overridden"
    fi

    # 覆盖 static 目录（如果存在）
    if [ -d "/data/static" ]; then
        mkdir -p "$SITE_DIR/static"
        cp -r /data/static/* "$SITE_DIR/static/"
        echo "  - static/ overridden"
    fi
fi

# 重新生成静态文件到 Nginx 目录
echo "Generating static site..."
cd "$SITE_DIR"
hugo --minify --destination /usr/share/nginx/html

echo "Starting Nginx..."
nginx -g "daemon off;"

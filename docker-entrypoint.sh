#!/bin/bash
set -e

# 检查源码是否挂载
if [ ! -d /app/exampleSite ]; then
    echo "ERROR: /app/exampleSite not found. Please mount your WebStack-Hugo source code to /app."
    exit 1
fi

echo "Source code found, generating static site..."

cd /app/exampleSite

# 生成静态文件到 Nginx 目录
hugo --minify --destination /usr/share/nginx/html

echo "Static site generated successfully."

# 启动 Nginx
nginx -g "daemon off;"

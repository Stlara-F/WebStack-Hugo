#!/bin/bash
set -e

# 自动填充空的数据目录（如果挂载的目录为空，则从镜像默认位置复制）
populate_if_empty() {
    local source_dir=$1
    local target_dir=$2
    if [ -d "$target_dir" ] && [ -z "$(ls -A $target_dir 2>/dev/null)" ]; then
        echo "Populating $target_dir with default content from $source_dir"
        cp -r $source_dir/. $target_dir/
    fi
}

# 填充数据目录（仅在宿主机挂载目录为空时执行）
populate_if_empty /app/exampleSite /data/exampleSite
populate_if_empty /app/layouts    /data/layouts
populate_if_empty /app/static     /data/static

# 处理单文件配置（原有逻辑，保持不变）
if [ -f /config/config.toml ]; then
    cp /config/config.toml /app/exampleSite/config.toml
    echo "  - config.toml updated"
fi

if [ -f /config/webstack.yml ]; then
    cp /config/webstack.yml /app/exampleSite/data/webstack.yml
    echo "  - webstack.yml updated"
fi

# 重新生成静态文件（如果有任何配置或目录变更）
if [ -f /config/config.toml ] || [ -f /config/webstack.yml ] || \
   [ -d /data/exampleSite ] || [ -d /data/layouts ] || [ -d /data/static ]; then
    echo "Regenerating static site..."
    # 先同步数据目录到 /app 下
    [ -d /data/exampleSite ] && cp -rf /data/exampleSite/. /app/exampleSite/
    [ -d /data/layouts ] && cp -rf /data/layouts/. /app/layouts/
    [ -d /data/static ] && cp -rf /data/static/. /app/static/
    cd /app/exampleSite
    hugo --minify --destination /usr/share/nginx/html
    echo "Static site regenerated."
else
    echo "No custom config or directories provided, using default built-in static files."
fi

# 启动 Nginx
nginx -g "daemon off;"

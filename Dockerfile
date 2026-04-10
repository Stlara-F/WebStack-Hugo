# 第一阶段：构建 Hugo 静态文件
FROM hugomods/hugo:latest AS builder

WORKDIR /src
COPY . .

# 创建主题目录，并复制除 exampleSite 外的所有文件到 themes/WebStack-Hugo
RUN mkdir -p /src/exampleSite/themes/WebStack-Hugo && \
    tar -c --exclude=exampleSite . | tar -x -C /src/exampleSite/themes/WebStack-Hugo

WORKDIR /src/exampleSite

# 构建站点（主题已放置在正确位置）— 生成默认静态文件
RUN hugo --minify

# 第二阶段：运行时镜像（基于 Nginx，并加入 Hugo 支持动态生成）
FROM nginx:1.28-alpine-slim
RUN apk upgrade --no-cache

# 安装 bash 和 C++ 运行时库（解决 hugo 依赖）
RUN apk add --no-cache bash libstdc++

# 从 builder 阶段复制 hugo 二进制
COPY --from=builder /usr/bin/hugo /usr/local/bin/hugo

# 复制整个源码（包括主题、exampleSite、配置模板）到 /app
WORKDIR /app
COPY --from=builder /src /app/

# 复制第一阶段生成的默认静态文件到 Nginx 默认目录（作为后备）
COPY --from=builder /src/exampleSite/public /usr/share/nginx/html

# 复制启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

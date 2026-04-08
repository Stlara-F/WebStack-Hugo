# 第一阶段：构建 Hugo 静态文件（生成默认静态文件）
FROM hugomods/hugo:latest AS builder

WORKDIR /src
COPY . .

# 创建主题目录，并复制除 exampleSite 外的所有文件到 themes/WebStack-Hugo
RUN mkdir -p /src/exampleSite/themes/WebStack-Hugo && \
    tar -c --exclude=exampleSite . | tar -x -C /src/exampleSite/themes/WebStack-Hugo

WORKDIR /src/exampleSite
RUN hugo --minify

# 第二阶段：运行时镜像（基于 Alpine，同时安装 Nginx 和 Hugo）
FROM alpine:3.19

# 安装 Nginx、Bash 和 Hugo（Alpine 官方仓库中的 hugo 是 musl 兼容的）
RUN apk add --no-cache nginx bash hugo

# 创建 Nginx 运行时需要的目录
RUN mkdir -p /run/nginx /var/log/nginx

# 复制第一阶段生成的默认静态文件到 Nginx 默认目录（作为后备）
COPY --from=builder /src/exampleSite/public /usr/share/nginx/html

# 复制整个源码（包括主题、exampleSite、配置模板）到 /app
WORKDIR /app
COPY --from=builder /src /app/

# 复制启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

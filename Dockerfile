# 第一阶段：构建 Hugo 静态文件
FROM hugomods/hugo:latest as builder

WORKDIR /src
COPY . .

# 创建主题目录，并复制除 exampleSite 外的所有文件到 themes/WebStack-Hugo
RUN mkdir -p /src/exampleSite/themes/WebStack-Hugo && \
    tar -c --exclude=exampleSite . | tar -x -C /src/exampleSite/themes/WebStack-Hugo

WORKDIR /src/exampleSite

# 构建站点（主题已放置在正确位置）
RUN hugo --minify

# 第二阶段：使用 Nginx 提供静态文件（使用 slim 版本减少漏洞）
FROM nginx:1-alpine-slim

# 复制构建好的静态文件
COPY --from=builder /src/exampleSite/public /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

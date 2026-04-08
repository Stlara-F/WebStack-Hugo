# 第一阶段：构建 Hugo 静态文件
FROM hugomods/hugo:latest as builder

WORKDIR /src
COPY . .

# 将主题源码放到 exampleSite/themes/WebStack-Hugo 下
RUN mkdir -p /src/exampleSite/themes && \
    cp -r /src /src/exampleSite/themes/WebStack-Hugo

WORKDIR /src/exampleSite

# 构建站点（配置文件 config.toml 中应已指定 theme = "WebStack-Hugo"）
RUN hugo --minify

# 第二阶段：使用 Nginx 提供静态文件
FROM nginx:alpine

# 复制构建好的静态文件
COPY --from=builder /src/exampleSite/public /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

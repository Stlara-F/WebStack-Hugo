# 第一阶段：构建 Hugo 静态文件
FROM hugomods/hugo:latest as builder

WORKDIR /src
COPY . .

# 进入示例站点目录
WORKDIR /src/exampleSite

# 生成静态网站，指定主题目录为上级目录
RUN hugo --minify --themesDir ../..

# 第二阶段：使用 Nginx 提供静态文件
FROM nginx:alpine

# 复制构建好的静态文件
COPY --from=builder /src/exampleSite/public /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

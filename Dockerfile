# 第一阶段：构建 Hugo 静态文件
FROM hugomods/hugo:latest as builder

WORKDIR /src

# 复制项目文件
COPY . .

# 进入 exampleSite 目录（主题的示例站点）
WORKDIR /src/exampleSite

# 生成静态网站（输出到 public 目录）
RUN hugo --minify

# 第二阶段：使用 Nginx 提供静态文件
FROM nginx:alpine

# 复制构建好的静态文件（从 exampleSite/public）到 Nginx 默认目录
COPY --from=builder /src/exampleSite/public /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]

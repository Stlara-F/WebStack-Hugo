# 第一阶段：获取 hugo 二进制
FROM hugomods/hugo:latest AS hugo

# 第二阶段：运行时镜像
FROM nginx:1-alpine-slim

# 安装 bash（用于启动脚本）
RUN apk add --no-cache bash

# 从 builder 阶段复制 hugo 二进制
COPY --from=hugo /usr/bin/hugo /usr/local/bin/hugo

# 创建工作目录（用于挂载宿主机源码）
WORKDIR /app

# 复制启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 暴露端口
EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

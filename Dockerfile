# 1. 基础镜像：使用官方精简版 Python 3.9 (稳定且小巧)
FROM python:3.9-slim

# 2. 设置容器内的工作目录
WORKDIR /app

# 3. 先复制依赖清单 (利用 Docker 缓存机制加速构建)
COPY requirements.txt .

# 4. 安装依赖 (关键步骤：强制使用阿里云镜像源，解决国内下载失败和慢速问题)
# 确保安装了 Streamlit, zhipuai, httpx, sniffio
RUN pip install --no-cache-dir -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/

# 5. 复制剩下的代码 (app.py 等) 到容器
COPY . .

# 6. 暴露 Streamlit 的默认端口
EXPOSE 8501

# 7. 启动命令：针对 Nginx 代理环境进行了关键配置优化
# --server.enableCORS=false: 禁用跨域检查，允许 Nginx 转发
# --server.enableXsrfProtection=false: 禁用 XSRF 保护，解决登录/连接报错
# --server.address=0.0.0.0: 允许监听所有网卡
CMD ["streamlit", "run", "app.py", \
     "--server.port=8501", \
     "--server.address=0.0.0.0", \
     "--server.enableCORS=false", \
     "--server.enableXsrfProtection=false", \
     "--global.developmentMode=false"]

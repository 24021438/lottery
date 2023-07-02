# Use the official Node.js 16 image as base image
FROM node:16.14.0-buster

# 替换系统源为清华大学源
RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# 使用清华大学的 npm 镜像源
RUN npm config set registry https://registry.npm.taobao.org

# Upgrade npm to the latest version
RUN npm install -g npm@9.6.2

# 安装 nano 和 tree 工具
RUN apt-get update && apt-get install -y nano tree

# Set the author of the Dockerfile
LABEL maintainer="YIN"

# Copy the server directory to the container
COPY server /lottery/server

# Copy the product directory to the container
COPY product /lottery/product

# Set the working directory to the root directory of the application
WORKDIR /lottery

# Set the ownership of the application directory to root
RUN chown -R root /lottery \
    # Remove the line that opens the default browser when starting the server
    && sed -i '/openBrowser/ d' ./server/server.js \
    # Install dependencies for the server and product directories
    && cd server && npm install \
    && cd ../product && npm install \
    # Build the application
    && npm run build

# Expose port 8080 to the outside world
EXPOSE 8080

# Set the working directory to the product directory
WORKDIR /lottery/product

# Start the server
CMD ["npm", "start"]

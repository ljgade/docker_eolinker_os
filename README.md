# docker_eolinker_os
#### **快速使用**

------------
1、安装git、docker（ **[官方文档](https://docs.docker.com/engine/installation/#server "官方文档")** ）、docker-compose
```shell
#centOS下安装git:
sudo yum -y install git

#docker安装参考官网安装教程：
#SET UP THE REPOSITORY
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
#INSTALL DOCKER CE
sudo yum install docker-ce

#安装docker-compose
sudo yum -y install docker-compose
```

2、使用git下载完整代码
```shell
git clone https://github.com/ljgade/docker_eolinker_os
```
3、用docker-compose命令启动容器，首次使用需要下载镜像，会稍慢
```shell
docker-compose build && docker-compose up -d
```
4、在浏览器访问[http://localhost](http://localhost "http://localhost")
![eoLinker开源版安装页面](http://www.ljgade.cn/wp-content/uploads/2018/01/TKM@0M56S2TLRRX8DVW-768x430.png)


#### **目录结构**

------------
```shell
.
├── docker-compose.yml    容器启动配置文件
├── lnmp                  lnmp环境目录
│   ├── build.sh          容器编译启动脚本
│   ├── default.conf      nginx配置文件（eoLinker开源版配置）
│   ├── Dockerfile        镜像构建配置文件
│   ├── my.cnf            mysql配置文件
│   ├── nginx.conf        nginx默认配置文件
│   └── start.sh          容器初始化脚本
└── volumes               挂载目录
    └── apps              挂载apps目录（对应容器里的/apps目录）
        ├── eolinker_os   eoLinker开源版项目目录
        ├── mysql         mysql数据及日志存储目录
        ├── nginx         nginx日志存储目录
        └── php           php日志存储目录
```
**docker-compose.yml**

------------
```yaml
version: '2'
services:
  eolinker_os:
    build: lnmp
    image: eolinker/eolinker_os
    volumes:
      - "./volumes/apps:/apps"  #挂载apps目录
    ports:
      - "3306:3306"   #数据库端口
      - "80:80"       #nginx端口
    environment:
      - MYSQL_ROOT_PASSWORD=123456    #默认数据库root用户密码
      - MYSQL_DATABASE=eolinker_os    #默认数据库名称
    restart: always
```
**Dockerfile**

------------
```
#基于alpine镜像，体积很小，只有5M
FROM alpine:latest
MAINTAINER eolinker ljgade@eolinker.com

#使用阿里云镜像源，加快国内访问速度
RUN echo 'http://mirrors.aliyun.com/alpine/latest-stable/main/' > /etc/apk/repositories; \
    echo 'http://mirrors.aliyun.com/alpine/latest-stable/community/' >> /etc/apk/repositories; \
    apk update;

#安装curl、wget
RUN apk add --update curl wget;

# install nginx 安装nginx
RUN apk add nginx
RUN mkdir /run/nginx
RUN mkdir /apps
RUN mkdir -p /usr/share/nginx/html
COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/conf.d/
EXPOSE 80

# install php 安装php及php模块
RUN apk add php7 \
            php7-ctype \
            php7-curl \
            php7-dom \
            php7-exif \
            php7-fileinfo \
            php7-gd \
            php7-gettext \
            php7-iconv \
            php7-imagick \
            php7-json \
            php7-mbstring \
            php7-mcrypt \
            php7-memcached \
            php7-mysqli \
            php7-mysqlnd \
            php7-opcache \
            php7-openssl \
            php7-pcntl \
            php7-pdo \
            php7-pdo_mysql \
            php7-pdo_pgsql \
            php7-pdo_sqlite \
            php7-posix \
            php7-redis \
            php7-session \
            php7-simplexml \
            php7-sockets \
            php7-sqlite3 \
            php7-xml \
            php7-xmlwriter \
            php7-zlib;

# install php-fpm 安装php-fpm
RUN apk add php7-fpm
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php7/php.ini && \
sed -i "s/;error_log = php_errors.log/error_log = \/apps\/php\/php_errors.log/" /etc/php7/php.ini
EXPOSE 9000

# install mysql 安装mysql
RUN apk add mysql mysql-client;
RUN mkdir /run/mysqld/ && mkdir -p /apps/mysql/
COPY my.cnf /etc/mysql/my.cnf
RUN chmod 644 /etc/mysql/my.cnf
EXPOSE 3306

# copy files 复制文件到容器中（如：容器初始化脚本）
COPY start.sh /root/
RUN chmod +x /root/start.sh

WORKDIR /apps/
VOLUME ["/apps"]

# 执行初始化脚本(启动MySQL、php、nginx、下载eoLinker开源版最新版)
CMD ["/bin/sh","/root/start.sh"]
```

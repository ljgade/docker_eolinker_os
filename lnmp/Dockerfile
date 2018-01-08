FROM alpine:latest
MAINTAINER eolinker ljgade@eolinker.com

RUN echo 'http://mirrors.aliyun.com/alpine/latest-stable/main/' > /etc/apk/repositories; \
    echo 'http://mirrors.aliyun.com/alpine/latest-stable/community/' >> /etc/apk/repositories; \
    apk update;

RUN apk add --update curl wget;

# install nginx
RUN apk add nginx
RUN mkdir /run/nginx
RUN mkdir /apps
RUN mkdir -p /usr/share/nginx/html
COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/conf.d/
EXPOSE 80

# install php
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

# install php-fpm
RUN apk add php7-fpm
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php7/php.ini && \
sed -i "s/;error_log = php_errors.log/error_log = \/apps\/php\/php_errors.log/" /etc/php7/php.ini
EXPOSE 9000

# install mysql
RUN apk add mysql mysql-client;
RUN mkdir /run/mysqld/ && mkdir -p /apps/mysql/
COPY my.cnf /etc/mysql/my.cnf
RUN chmod 644 /etc/mysql/my.cnf
EXPOSE 3306

# copy files
COPY start.sh /root/
RUN chmod +x /root/start.sh

WORKDIR /apps/
VOLUME ["/apps"]

CMD ["/bin/sh","/root/start.sh"]

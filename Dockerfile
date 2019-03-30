FROM centos:7.4.1708

MAINTAINER linchqd<13435600095@163.com>
 
ARG PCRE_VERSION=8.37
ARG NGINX_VERSION=1.14.1
ARG PHP_VERSION=7.2.4
ARG PHP_REDIS_VERSION=3.1.2
ENV WEB_LOGS=/home/logs

# enable yum repo and install nginx/php requirements 
RUN yum -y install wget && cd /etc/yum.repos.d/ && rm -rf ./* \
    && wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
    && sed  -i '/aliyuncs/d' /etc/yum.repos.d/CentOS-Base.repo \
    && wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo \
    && sed -i '/aliyuncs/d' /etc/yum.repos.d/epel.repo \
    && yum clean all && yum makecache \
    && yum -y install gcc gcc-c++ glibc make autoconf libjpeg-turbo \
    libjpeg-turbo-devel libpng libpng-devel freetype freetype-devel \
    libxml2 libxml2-devel zlib zlib-devel libcurl libcurl-devel automake \
    openssl openssl-devel swig libxslt libxslt-devel gd-devel GeoIP-devel \
    && yum -y install gcc autoconf gcc-c++ bzip2 bzip2-devel libjpeg-turbo \
    libjpeg-turbo-devel libpng libpng-devel freetype freetype-devel libxml2 \
    libxml2-devel libcurl libcurl-devel libxslt libxslt-devel openssl \
    openssl-devel gmp gmp-devel readline readline-devel systemd-devel \
    && yum -y install supervisor \
    && yum clean all && rm -rf /var/cache/yum && rm -rf /var/lib/yum

# install pcre/nginx
RUN cd /usr/local/src/ && wget https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz \
    && tar zxvf pcre-${PCRE_VERSION}.tar.gz && cd pcre-${PCRE_VERSION} \
    && ./configure --prefix=/usr/local/pcre && make && make install \
    && useradd -s /sbin/nologin nginx \
    && mkdir -p ${WEB_LOGS}/nginx && chown nginx:nginx ${WEB_LOGS}/nginx \
    && cd /usr/local/src/ && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxvf nginx-${NGINX_VERSION}.tar.gz && cd nginx-${NGINX_VERSION} \
    && ./configure \
    --user=nginx \
    --group=nginx \
    --prefix=/usr/local/nginx-${NGINX_VERSION} \
    --conf-path=/usr/local/nginx-${NGINX_VERSION}/conf/nginx.conf \
    --error-log-path=${WEB_LOGS}/nginx/error.log  \
    --http-log-path=${WEB_LOGS}/nginx/access.log  \
    --pid-path=/usr/local/nginx-${NGINX_VERSION}/logs/nginx.pid  \
    --lock-path=/usr/local/nginx-${NGINX_VERSION}/logs/nginx.lock  \
    --with-http_ssl_module  \
    --with-http_stub_status_module  \
    --with-http_gzip_static_module  \
    --with-http_xslt_module  \
    --with-http_sub_module  \
    --with-http_realip_module  \
    --with-http_image_filter_module  \
    --with-http_geoip_module  \
    --with-http_dav_module  \
    --with-http_addition_module  \
    --http-client-body-temp-path=/usr/local/nginx-${NGINX_VERSION}/client_body_temp/  \
    --http-fastcgi-temp-path=/usr/local/nginx-${NGINX_VERSION}/fastcgi_temp/  \
    --http-proxy-temp-path=/usr/local/nginx-${NGINX_VERSION}/proxy_temp/  \
    --http-scgi-temp-path=/usr/local/nginx-${NGINX_VERSION}/scgi_temp/  \
    --http-uwsgi-temp-path=/usr/local/nginx-${NGINX_VERSION}/uwsgi_temp/  \
    --with-file-aio  \
    --with-pcre=/usr/local/src/pcre-${PCRE_VERSION} \
    && make && make install \
    && ln -s /usr/local/nginx-${NGINX_VERSION}/sbin/nginx /usr/local/sbin/ \
    && ln -s /usr/local/nginx-${NGINX_VERSION} /usr/local/nginx \
    && cd / && rm -rf /usr/local/src/*

# install php
RUN groupadd php-fpm && useradd -s /sbin/nologin -g php-fpm -M php-fpm \
    && mkdir -p ${WEB_LOGS}/php && chown php-fpm:php-fpm ${WEB_LOGS}/php \
    && cd /usr/local/src/ \
    && wget https://raw.githubusercontent.com/linchqd/saltstack/master/salt/prod/modules/php/files/php-${PHP_VERSION}.tar.gz \
    && tar zxvf php-${PHP_VERSION}.tar.gz && cd php-${PHP_VERSION} \
    && ./configure \
    --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --with-zlib-dir \
    --with-freetype-dir \
    --enable-mbstring \
    --with-libxml-dir=/usr \
    --enable-xmlreader \
    --enable-xmlwriter \
    --enable-soap \
    --enable-calendar \
    --with-curl \
    --with-zlib \
    --with-gd \
    --with-pdo-sqlite \
    --with-pdo-mysql=mysqlnd \
    --with-mysqli=mysqlnd \
    --with-mysql-sock \
    --enable-mysqlnd \
    --disable-rpath \
    --enable-inline-optimization \
    --with-bz2 \
    --with-zlib \
    --enable-sockets \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-pcntl \
    --enable-mbregex \
    --enable-exif \
    --enable-bcmath \
    --with-mhash \
    --enable-zip \
    --with-pcre-regex \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-openssl \
    --enable-ftp \
    --with-kerberos \
    --with-gettext \
    --with-xmlrpc \
    --with-xsl \
    --enable-fpm \
    --with-fpm-user=php-fpm \
    --with-fpm-group=php-fpm \
    --with-fpm-systemd \
    --with-iconv-dir \
    --with-libdir=lib64 \
    --with-pear \
    --enable-shmop \ 
    --enable-xml \
    && make && make install \
    && ln -s /usr/local/php/bin/* /usr/bin/ \
    && cd ext/pdo_mysql/ && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=mysqlnd \
    && make && make install \
    && cd /usr/local/src/ \
    && wget https://raw.githubusercontent.com/linchqd/saltstack/master/salt/prod/modules/php/files/redis-${PHP_REDIS_VERSION}.tgz \
    && tar zxf redis-${PHP_REDIS_VERSION}.tgz \
    && cd redis-${PHP_REDIS_VERSION} \
    && phpize \
    && ./configure --with-php-config=/usr/local/php/bin/php-config \
    && make && make install \
    && cd / && rm -rf /usr/local/src/*

COPY opt /opt

EXPOSE 80

CMD ["/bin/bash"]

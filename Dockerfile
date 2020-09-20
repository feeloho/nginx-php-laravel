FROM centos:7
MAINTAINER bY feeloho <79534505@qq.com>

ENV NGINX_VERSION 1.15.3
ENV PHP_VERSION 7.0.27
ENV PHP_PATH /server/php
ENV NGINX_PATH /server/nginx
ENV LOG_PATH /var/log

RUN set -x && \
    yum install -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \
#Install PHP library
## libmcrypt-devel DIY
    rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm && \
    yum install -y zlib \
    zlib-devel \
    openssl \
    openssl-devel \
    pcre-devel \
    libxml2 \
    libxml2-devel \
    libcurl \
    libcurl-devel \
    libpng-devel \
    libjpeg-devel \
    freetype-devel \
    libmcrypt-devel \
    openssh-server \
	bzip2-devel	\
    python-setuptools && \
## Install extenstion --with-libzip   
    wget https://nih.at/libzip/libzip-1.2.0.tar.gz \
    tar -zxf libzip-1.2.0.tar.gz \
    rm -rf libzip-1.2.0.tar.gz \
    cd libzip-1.2.0 \
    ./configure \
    make \
    make install && \
#Add user
	mkdir -p /server/phpextini && \
	mkdir -p /server/phpextfile && \
    useradd -r -s /sbin/nologin -d /web-data -m -k no www && \
#Download nginx & php
    mkdir -p /home/nginx-php && cd $_ && \
    curl -Lk http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
    curl -Lk https://php.net/distributions/php-$PHP_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
#Make install nginx
    cd /home/nginx-php/nginx-$NGINX_VERSION && \
    ./configure --prefix=$NGINX_PATH \
    --user=www --group=www \
    --error-log-path=/var/log/nginx_error.log \
    --http-log-path=/var/log/nginx_access.log \
    --pid-path=/var/run/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --with-http_gzip_static_module && \
    make && make install && \
	cp $NGINX_PATH/sbin/nginx /usr/local/bin/nginx && \
#Make install php
    cd /home/nginx-php/php-$PHP_VERSION && \      
    ./configure --prefix=$PHP_PATH \
    --with-config-file-path=$PHP_PATH/etc \
    --with-config-file-scan-dir=/server/phpextini \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mysqli \
    --with-pdo-mysql \
    --with-openssl \
    --with-gd \
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-png-dir \
    --with-jpeg-dir \
    --with-freetype-dir \
    --with-xmlrpc \
    --with-mhash \
	--with-bz2	\
    --with-libzip \
    --enable-fpm \
    --enable-xml \
    --enable-shmop \
    --enable-sysvsem \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-mbstring \
    --enable-ftp \
    --enable-mysqlnd \
    --enable-pcntl \
    --enable-sockets \
    --enable-zip \
    --enable-soap \
    --enable-session \
    --enable-opcache \
    --enable-bcmath \
    --enable-exif \
    --enable-fileinfo \
    --disable-rpath \
    --enable-ipv6 \
    --disable-debug \
    --without-pear \
    --with-mcrypt && \
    make && make install && \
#Install php-fpm
    cd /home/nginx-php/php-$PHP_VERSION && \
    #cp php.ini-production $PHP_PATH/etc/php.ini && \
    #cp $PHP_PATH/etc/php-fpm.conf.default $PHP_PATH/etc/php-fpm.conf && \
    #cp $PHP_PATH/etc/php-fpm.d/www.conf.default $PHP_PATH/etc/php-fpm.d/www.conf && \
	cp /server/php/bin/php /usr/local/bin/php && \
#Install composer
    curl -sS https://getcomposer.org/installer | $PHP_PATH/bin/php && \
    mv composer.phar /usr/local/bin/composer && \
	rm -rf installer && \
#Clean OS
    yum remove -y gcc \
    gcc-c++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake && \
    yum clean all && \
    rm -rf /tmp/* /var/cache/{yum,ldconfig} /etc/my.cnf{,.d} && \
    mkdir -p --mode=0755 /var/cache/{yum,ldconfig} && \
    find /var/log -type f -delete && \
    rm -rf /home/nginx-php && \
	mkdir -p $LOG_PATH/php && \
	mkdir -p $LOG_PATH/nginx && \
#Change Mod from webdir
	chown -R www:www $LOG_PATH && \
    chown -R www:www /web-data && \
	chmod 775 -R $LOG_PATH

#Create web folder
# WEB Folder: /web-data
# SSL Folder: /server/nginx/conf/ssl
# Vhost Folder: /server/nginx/conf/vhost
# php extfile ini Folder: /server/php/etc/conf.d
# php extfile Folder: /server/phpextfile
#VOLUME ["/web-data", $NGINX_PATH"/conf/ssl", $NGINX_PATH"/conf/vhost", "/server/phpextini", "/server/phpextfile"]

#Update nginx config
ADD nginx.conf $NGINX_PATH/conf/
ADD php.ini $PHP_PATH/etc/
ADD php-fpm.conf $PHP_PATH/etc/
ADD www.conf $PHP_PATH/etc/php-fpm.d/

#Set port
EXPOSE 80 443

#Start nginx php-fpm
ENTRYPOINT /server/php/sbin/php-fpm && /server/nginx/sbin/nginx 
	

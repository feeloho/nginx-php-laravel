FROM centos:7
MAINTAINER By feeloho <79534505@qq.com>

ENV NGINX_VERSION 1.15.3
ENV PHP_VERSION 7.2.34
ENV PHPUNIT_VERSION 9.4.2
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
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
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
    wget \
    python-setuptools \
    oniguruma-devel \
    sqlite-devel && \
#Add user
	mkdir -p /server/phpextini && \
	mkdir -p /server/phpextfile && \
    useradd -r -s /sbin/nologin -d /web-data -m -k no www && \
#Download nginx & php
    mkdir -p /home/nginx-php && cd $_ && \
    curl -Lk http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
    curl -Lk http://php.net/distributions/php-$PHP_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
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
# Download phpunit
    mkdir -p /home/nginx-php/phpunit-$PHPUNIT_VERSION && \
    cd /home/nginx-php/phpunit-$PHPUNIT_VERSION && \
    wget https://phar.phpunit.de/phpunit-$PHPUNIT_VERSION.phar  &&\
    chmod +x phpunit-$PHPUNIT_VERSION.phar && \
    mv phpunit-$PHPUNIT_VERSION.phar /usr/local/bin/phpunit && \
# php gd
    mkdir -p /home/php-gd-extend && \
    ## zlib
    cd /home/php-gd-extend && \
    wget http://www.zlib.net/zlib-1.2.11.tar.gz && \
    tar -zxvf zlib-1.2.11.tar.gz && \
    cd zlib-1.2.11 && \
    ./configure --prefix=/usr/local/bin/zlib && \
    make && make install && \
    ## freetype
    cd /home/php-gd-extend && \
    wget https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz && \
    tar -zxvf freetype-2.9.tar.gz && \
    cd freetype-2.9 && \
    ./configure --prefix=/usr/local/bin/freetype && \
    make && make install && \
    ## libpng
    cd /home/php-gd-extend && \
    wget https://nchc.dl.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz && \
    tar -zxvf libpng-1.6.37.tar.gz && \
    cd libpng-1.6.37 && \
    ./configure --prefix=/usr/local/bin/libpng  && \
    make && make install && \
    ## jpegsrc
    cd /home/php-gd-extend && \
    wget  http://www.ijg.org/files/jpegsrc.v9d.tar.gz && \
    tar -zxvf jpegsrc.v9d.tar.gz && \
    cd jpeg-9d && \
    ./configure --prefix=/usr/local/bin/libjpeg --enable-shared && \
    make && make install && \
# delete php dg install files
    rm -rf /home/php-gd-extend && \
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
    --with-iconv \
    --with-zlib \
    --with-gettext \
    --with-curl \
    --with-png-dir=/usr/local/bin/libpng \
    --with-jpeg-dir=/usr/local/bin/libjpeg  \
    --with-freetype-dir=/usr/local/bin/freetype \
    --with-zlib-dir=/usr/local/bin/zlib \    
    --with-xmlrpc \
    --with-mhash \
	--with-bz2	\
    --with-jpeg-dir=/user/local/libjpeg \
    --with-png-dir=/user/local/libpng \
    --with-freetype-dir=/user/local/freetype \
    --with-zlib-dir=/user/local/zlib \
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
    --enable-gd && \
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
	

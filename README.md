# nginx-php-laravel
Nginx and PHP and Laravel for Docker



## 版本

Nginx:  **1.15.3**

php:  **7.2.9**

composer:  **1.7.3**

## Docker Hub

Nginx-PHP-Laravel: [https://hub.docker.com/r/zhaozhongjin/nginx-php-laravel/](https://hub.docker.com/r/zhaozhongjin/nginx-php-laravel/)

## 配置信息

- 软件目录 : /server/
- laravel目录: /web-data/
- 日志目录: /var/log/

## 安装使用

docker 镜像

```sh
docker pull zhaozhongjin/nginx-php-laravel:latest
```

## 启动

镜像启动容器

```sh
docker run --name nginx-php-laravel -p 80:80 -v /web-data:/web-data -d zhaozhongjin/nginx-php-laravel
```

然后通过浏览器访问```http://\<docker_host\>:80``` 
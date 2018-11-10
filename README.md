# nginx-php-laravel
Nginx and PHP and Laravel for Docker



## 版本

Nginx:  **1.15.3**

php:  **7.2.9**

## Docker Hub

Nginx-PHP-Laravel: [https://hub.docker.com/r/zhaozhongjin/nginx-php-laravel/](https://hub.docker.com/r/zhaozhongjin/nginx-php-laravel/)

## 安装使用

docker 镜像

```sh
docker pull zhaozhongjin/nginx-php-laravel:latest
```

## 启动

镜像启动容器

```sh
docker run --name nginx-php-laravel -p 80:80 -d zhaozhongjin/nginx-php-laravel
```

然后通过浏览器访问```http://\<docker_host\>:8080``` 
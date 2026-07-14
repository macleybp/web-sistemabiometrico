FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libzip-dev \
        unzip \
        git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_mysql \
        mysqli \
        gd \
        zip \
        opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

COPY docker/apache-vhost.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

COPY . /var/www/html/

RUN APP_VERSION=$(cat /var/www/html/VERSION 2>/dev/null | tr -d '[:space:]') \
    && echo "APP_VERSION=${APP_VERSION}" >> /etc/apache2/envvars

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}

EXPOSE 80

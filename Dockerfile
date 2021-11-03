FROM php:8.0-fpm

RUN apt-get update \
    && apt-get install -y \
        apt-utils \
        libicu-dev \
        libjpeg-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
        libssh-dev \
        libonig-dev \
        git \
        curl \
        libc-client-dev \
        libkrb5-dev \
        libmagickwand-dev --no-install-recommends \
        ssh \
    && docker-php-ext-install \
        bcmath \
        sockets \
        intl \
        opcache \
        zip \
        pdo \
        pdo_pgsql \
        pdo_mysql \
        gd \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && echo "date.timezone = Europe/Paris" >> /usr/local/etc/php/conf.d/symfony.ini \
    && echo "short_open_tag = Off" >> /usr/local/etc/php/conf.d/symfony.ini

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl

# install mongodb ext
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

RUN curl -sL 'https://deb.nodesource.com/setup_6.x' | bash /dev/stdin

RUN curl -sS 'https://dl.yarnpkg.com/debian/pubkey.gpg' | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get -y update && curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs yarn

# Download and install wkhtmltopdf
RUN apt-get update && apt-get install -y wkhtmltopdf xvfb

# CLEAN
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN yarn global add gulp -g
RUN yarn global add bower -g

# Composer
COPY install-composer /usr/local/bin/install-composer
RUN /usr/local/bin/install-composer

RUN usermod -u 1000 www-data

EXPOSE 8080

FROM php:7.3-fpm

RUN apt-get update && \
    apt-get install -y \
        apt-utils \
        libicu-dev \
        libjpeg-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
        git \
        curl \
    && docker-php-ext-install \
        mbstring \
        bcmath \
        intl \
        opcache \
        zip \
        pdo \
        pdo_pgsql \
        pdo_mysql \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && echo "date.timezone = Europe/Paris" >> /usr/local/etc/php/conf.d/symfony.ini \
    && echo "short_open_tag = Off" >> /usr/local/etc/php/conf.d/symfony.ini

RUN apt-get install -y \
        libc-client-dev libkrb5-dev && \
    rm -r /var/lib/apt/lists/*

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) imap

# SSH2
#RUN apt-get install -y \
#        wget \
#        unzip \
#        libssh2-1-dev \
#        libssh2-1 && \
#        pecl install ssh2-1.1.0 && \
#    echo "extension=ssh2.so" >> /usr/local/etc/php/conf.d/symfony.ini

# install mongodb ext
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

RUN curl -sL 'https://deb.nodesource.com/setup_6.x' | bash /dev/stdin

RUN curl -sS 'https://dl.yarnpkg.com/debian/pubkey.gpg' | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get -y update && apt-get install -y nodejs yarn


# CLEAN
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install gulp -g
RUN npm install bower -g

# Composer
COPY install-composer /usr/local/bin/install-composer
RUN /usr/local/bin/install-composer

RUN usermod -u 1000 www-data

EXPOSE 8080
#!/bin/bash -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build
apt update
apt install -y \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libzip-dev \
  libxml2-dev \
  libsqlite3-dev \
  libpq-dev \
  libfreetype6-dev \
  liblqr-1-0-dev \
  libfftw3-dev \
  libjbig-dev \
  libtiff5-dev \
  libwebp-dev \
  libmcrypt-dev \
  zip \
  wget \
  unzip \
  libgmp-dev \
  libonig-dev \
  libicu-dev \
  --no-install-recommends

docker-php-ext-install bcmath
docker-php-ext-install pdo_mysql
docker-php-ext-install mysqli
docker-php-ext-install mbstring
docker-php-ext-install opcache
docker-php-ext-install zip
docker-php-ext-install pcntl
docker-php-ext-install exif
docker-php-ext-install pdo pdo_pgsql
docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install -j2 gd

cd ${BUILD_DIR}
wget --progress=dot:giga https://github.com/cyberb/invoiceninja/archive/refs/heads/v5-stable.tar.gz
tar xf v5-stable.tar.gz
mv invoiceninja-5-stable server

cd ${BUILD_DIR}/server
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 
composer config -g github-oauth.github.com $GITHUB_TOKEN

for i in {1..5}; do
  composer install --no-dev && break || sleep 15
done

ls -la .
ls -la config

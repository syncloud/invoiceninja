#!/bin/bash -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build/snap
apt update
apt install -y \
  zip \
  wget \
  unzip \
  --no-install-recommends

cd ${DIR}/../build
wget https://getcomposer.org/installer -O - -q | php -- --quiet
mv composer.phar /usr/local/bin/composer

wget --progress=dot:giga https://github.com/cyberb/invoiceninja/archive/refs/heads/v5-stable.tar.gz
tar xf v5-stable.tar.gz
mv invoiceninja-5-stable $BUILD_DIR/server

cd $BUILD_DIR/server
composer config --global github-oauth.github.com $GITHUB_TOKEN
composer install --no-dev

SNAP=/snap/invoiceninja/current
SNAP_DATA=/var$SNAP
mkdir -p bin
cp -r $DIR/bin/* bin
sed -i "s/'driver' => '.*'/'driver' => 'syslog'/g" config/logging.php
grep driver config/logging.php
sed -i "s#'host'.*REDIS_HOST.*#'path'=>env('REDIS_PATH'),#g" config/database.php
grep REDIS_PATH config/database.php
sed -i "s#'port'.*REDIS_PORT.*#'scheme'=>'unix',#g" config/database.php
grep scheme config/database.php
sed -i "s#'root' => base_path().*#'root' => '$SNAP_DATA/storage',#g" config/filesystems.php
grep root config/filesystems.php
sed -i "s#return \$app;#\$app->useStoragePath( '$SNAP_DATA/storage' ); return \$app;#g" bootstrap/app.php
grep return bootstrap/app.php

rm -rf .env
ln -s $SNAP_DATA/config/.env .env
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

cd ${BUILD_DIR}
wget --progress=dot:giga https://github.com/cyberb/invoiceninja/archive/refs/heads/v5-stable.tar.gz
tar xf v5-stable.tar.gz
mv invoiceninja-5-stable server
cd server

${BUILD_DIR}/php/bin/php.sh ${BUILD_DIR}/php/bin/composer config --global github-oauth.github.com $GITHUB_TOKEN
${BUILD_DIR}/php/bin/php.sh ${BUILD_DIR}/php/bin/composer install --no-dev

SNAP=/snap/invoiceninja/current
SNAP_DATA=/var$SNAP
sed -i "s/'driver' => '.*'/'driver' => 'syslog'/g" server/config/logging.php
grep driver server/config/logging.php
sed -i "s#'host'.*REDIS_HOST.*#'path'=>env('REDIS_PATH'),#g" server/config/database.php
grep REDIS_PATH server/config/database.php
sed -i "s#'port'.*REDIS_PORT.*#'scheme'=>'unix',#g" server/config/database.php
grep scheme server/config/database.php
sed -i "s#'root' => base_path().*#'root' => '$SNAP_DATA/storage',#g" server/config/filesystems.php
grep root server/config/filesystems.php
sed -i "s#return \$app;#\$app->useStoragePath( '$SNAP_DATA/storage' ); return \$app;#g" server/bootstrap/app.php
grep return server/bootstrap/app.php

rm -rf server/.env
ln -s $SNAP_DATA/config/.env server/.env
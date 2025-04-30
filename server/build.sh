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

#mkdir -p ${BUILD_DIR}/var/www/app
#ls -la ${DIR}/../build/server
#ls -la ${DIR}/../build/server/config
#cp -r ${DIR}/../build/server/* ${BUILD_DIR}/var/www/app/
#rsync -a ${DIR}/../build/server ${BUILD_DIR}/var/www/app
#ls -la ${BUILD_DIR}/var/www/app
#ls -la ${BUILD_DIR}/var/www/app/config

#EXT=$(echo usr/local/lib/php/extensions/no-debug*)
SNAP=/snap/invoiceninja/current
SNAP_DATA=/var$SNAP
#RUNTIME_DIR=$SNAP/invoiceninja
#echo "extension_dir=$RUNTIME_DIR/$EXT" >> ${BUILD_DIR}/usr/local/etc/php/php.ini

#sed -i "s#include=.*#include=$RUNTIME_DIR/usr/local/etc/php-fpm.d/*.conf#g" ${BUILD_DIR}/usr/local/etc/php-fpm.conf
#grep include ${BUILD_DIR}/usr/local/etc/php-fpm.conf

#sed -i "s#;pid =.*#pid = $SNAP_DATA/php-fpm.pid#g" ${BUILD_DIR}/usr/local/etc/php-fpm.conf
#grep pid ${BUILD_DIR}/usr/local/etc/php-fpm.conf

#sed -i "s#;error_log =.*#error_log = syslog#g" ${BUILD_DIR}/usr/local/etc/php-fpm.conf
#grep error_log ${BUILD_DIR}/usr/local/etc/php-fpm.conf

sed -i "s/'driver' => '.*'/'driver' => 'syslog'/g" server/config/logging.php
grep driver server/config/logging.php

sed -i "s#'host'.*REDIS_HOST.*#'path'=>env('REDIS_PATH'),#g" server/config/database.php
grep REDIS_PATH server/config/database.php

sed -i "s#'port'.*REDIS_PORT.*#'scheme'=>'unix',#g" server/config/database.php
grep scheme server/config/database.php

sed -i "s#'root' => base_path().*#'root' => '$SNAP_DATA/storage',#g" server/config/filesystems.php
#sed -i "s#'root' => public_path('storage').*#'root' => '$SNAP_DATA/storage',#g" server/config/filesystems.php
#sed -i "s#'root' => public_path('storage').*#'root' => '$SNAP_DATA/storage',#g" server/config/filesystems.php
grep root server/config/filesystems.php

sed -i "s#return \$app;#\$app->useStoragePath( '$SNAP_DATA/storage' ); return \$app;#g" server/bootstrap/app.php
grep return server/bootstrap/app.php

rm -rf server/.env
ln -s $SNAP_DATA/config/.env server/.env
#!/bin/sh -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1

apk add rsync

BUILD_DIR=${DIR}/../build/snap/invoiceninja
while ! docker ps ; do
  sleep 1
  echo "retry docker"
done
docker build --build-arg GITHUB_TOKEN=$GITHUB_TOKEN --build-arg VERSION=$1 -t app:syncloud .
docker create --name=app app:syncloud
mkdir -p ${BUILD_DIR}
cd ${DIR}/../build
mkdir docker
cd docker

docker export app -o app.tar
tar xf app.tar

cp -r usr ${BUILD_DIR}
cp -r bin ${BUILD_DIR}
cp -r lib ${BUILD_DIR}

#mkdir -p ${BUILD_DIR}/var
#cp -r var/www ${BUILD_DIR}/var

mkdir -p ${BUILD_DIR}/var/www/app
ls -la ${DIR}/../build/server
ls -la ${DIR}/../build/server/config
cp -r ${DIR}/../build/server/* ${BUILD_DIR}/var/www/app/
#rsync -a ${DIR}/../build/server ${BUILD_DIR}/var/www/app
ls -la ${BUILD_DIR}/var/www/app
ls -la ${BUILD_DIR}/var/www/app/config

EXT=$(echo usr/local/lib/php/extensions/no-debug*)
SNAP=/snap/invoiceninja/current
SNAP_DATA=/var$SNAP
RUNTIME_DIR=$SNAP/invoiceninja
echo "extension_dir=$RUNTIME_DIR/$EXT" >> ${BUILD_DIR}/usr/local/etc/php/php.ini

sed -i "s#include=.*#include=$RUNTIME_DIR/usr/local/etc/php-fpm.d/*.conf#g" ${BUILD_DIR}/usr/local/etc/php-fpm.conf
grep include ${BUILD_DIR}/usr/local/etc/php-fpm.conf

#sed -i "s#;pid =.*#pid = $SNAP_DATA/php-fpm.pid#g" ${BUILD_DIR}/usr/local/etc/php-fpm.conf
#grep pid ${BUILD_DIR}/usr/local/etc/php-fpm.conf

#sed -i "s#;error_log =.*#error_log = syslog#g" ${BUILD_DIR}/usr/local/etc/php-fpm.conf
#grep error_log ${BUILD_DIR}/usr/local/etc/php-fpm.conf

sed -i "s/'driver' => '.*'/'driver' => 'syslog'/g" ${BUILD_DIR}/var/www/app/config/logging.php
grep driver ${BUILD_DIR}/var/www/app/config/logging.php

sed -i "s#'host'.*REDIS_HOST.*#'path'=>env('REDIS_PATH'),#g" ${BUILD_DIR}/var/www/app/config/database.php
grep REDIS_PATH ${BUILD_DIR}/var/www/app/config/database.php

sed -i "s#'port'.*REDIS_PORT.*#'scheme'=>'unix',#g" ${BUILD_DIR}/var/www/app/config/database.php
grep scheme ${BUILD_DIR}/var/www/app/config/database.php

sed -i "s#'root' => base_path().*#'root' => '$SNAP_DATA/storage',#g" ${BUILD_DIR}/var/www/app/config/filesystems.php
#sed -i "s#'root' => public_path('storage').*#'root' => '$SNAP_DATA/storage',#g" ${BUILD_DIR}/var/www/app/config/filesystems.php
#sed -i "s#'root' => public_path('storage').*#'root' => '$SNAP_DATA/storage',#g" ${BUILD_DIR}/var/www/app/config/filesystems.php
grep root ${BUILD_DIR}/var/www/app/config/filesystems.php

sed -i "s#return \$app;#\$app->useStoragePath( '$SNAP_DATA/storage' ); return \$app;#g" ${BUILD_DIR}/var/www/app/bootstrap/app.php
grep return ${BUILD_DIR}/var/www/app/bootstrap/app.php

rm -rf ${BUILD_DIR}/var/www/app/.env
ln -s $SNAP_DATA/config/.env ${BUILD_DIR}/var/www/app/.env

rm ${BUILD_DIR}/usr/local/etc/php-fpm.d/docker.conf
rm ${BUILD_DIR}/usr/local/etc/php-fpm.d/zz-docker.conf

cp $DIR/../config/php-fpm.conf ${BUILD_DIR}/usr/local/etc/php-fpm.d/zz-php-fpm.conf
cp -r ${DIR}/bin/* ${BUILD_DIR}/bin

#cp app/Http/Controllers/Auth/LoginController.php ${BUILD_DIR}/var/www/app/app/Http/Controllers/Auth
#cp app/Http/Controllers/BaseController.php ${BUILD_DIR}/var/www/app/app/Http/Controllers
#cp app/Libraries/OAuth/OAuth.php ${BUILD_DIR}/var/www/app/app/Libraries/OAuth
#cp app/Providers/EventServiceProvider.php ${BUILD_DIR}/var/www/app/app/Providers
#cp config/services.php ${BUILD_DIR}/var/www/app/config

ls -la ${BUILD_DIR}/usr/local/etc/php/conf.d

#rm -rf ${BUILD_DIR}/var/www/app/public
#mv public ${BUILD_DIR}/var/www/app/public

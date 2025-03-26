#!/bin/sh -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1

BUILD_DIR=${DIR}/../build/snap/invoiceninja
while ! docker ps ; do
  sleep 1
  echo "retry docker"
done
docker build --build-arg GITHUB_TOKEN=$GITHUB_TOKEN --build-arg VERSION=$1 -t app:syncloud .
docker create --name=app app:syncloud
mkdir -p ${BUILD_DIR}
cd ${DIR}/../build
docker export app -o app.tar
tar xf app.tar

cp -r usr ${BUILD_DIR}
cp -r bin ${BUILD_DIR}
cp -r lib ${BUILD_DIR}
mkdir ${BUILD_DIR}/var
cp -r var/www ${BUILD_DIR}/var

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

ln -s $SNAP_DATA/config/.env ${BUILD_DIR}/var/www/app/.env

rm ${BUILD_DIR}/usr/local/etc/php-fpm.d/docker.conf
rm ${BUILD_DIR}/usr/local/etc/php-fpm.d/zz-docker.conf

cp $DIR/../config/php-fpm.conf ${BUILD_DIR}/usr/local/etc/php-fpm.d/zz-php-fpm.conf
cp -r ${DIR}/bin/* ${BUILD_DIR}/bin

#cd ${BUILD_DIR}/var/www/app
#${BUILD_DIR}/bin/composer.sh require socialiteproviders/authelia
#cp -r vendor/socialiteproviders/authelia ${BUILD_DIR}/var/www/app/vendor/socialiteproviders/

wget https://github.com/cyberb/invoiceninja/archive/refs/heads/v5-stable.tar.gz
tar xf v5-stable.tar.gz
cp invoiceninja-5-stable/app/Http/Controllers/Auth/LoginController.php ${BUILD_DIR}/var/www/app/app/Http/Controllers/Auth
cp invoiceninja-5-stable/app/Http/Controllers/BaseController.php ${BUILD_DIR}/var/www/app/app/Http/Controllers
cp invoiceninja-5-stable/app/Libraries/OAuth/OAuth.php ${BUILD_DIR}/var/www/app/app/Libraries/OAuth
cp invoiceninja-5-stable/app/Providers/EventServiceProvider.php ${BUILD_DIR}/var/www/app/app/Providers
cp invoiceninja-5-stable/config/services.php ${BUILD_DIR}/var/www/app/config

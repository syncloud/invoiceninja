#!/bin/sh -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1

BUILD_DIR=${DIR}/../build/snap/invoiceninja
while ! docker create --name=app invoiceninja/invoiceninja:$VERSION ; do
  sleep 1
  echo "retry docker"
done
mkdir -p ${BUILD_DIR}
cd ${DIR}/../build
docker export app -o app.tar
tar xf app.tar

cp -r opt ${BUILD_DIR}
cp -r usr ${BUILD_DIR}
cp -r bin ${BUILD_DIR}
cp -r lib ${BUILD_DIR}
EXT=$(echo usr/local/lib/php/extensions/no-debug*)
SNAP=/snap/invoiceninja/current
SNAP_DATA=/var$SNAP
RUNTIME_DIR=$SNAP/invoiceninja
echo "extension_dir=$RUNTIME_DIR/$EXT" >> ${BUILD_DIR}/usr/local/etc/php/php.ini

sed -i "s#include=.*#include=$RUNTIME_DIR/usr/local/etc/php-fpm.d/*.conf#g" ${BUILD_DIR}/usr/local/etc/php-fpm.conf
grep include ${BUILD_DIR}/usr/local/etc/php-fpm.conf

sed -i "s#;pid =.*#pid = $SNAP_DATA/php-fpm.pid#g" ${BUILD_DIR}/usr/local/etc/php-fpm.conf
grep pid ${BUILD_DIR}/usr/local/etc/php-fpm.conf

cp -r ${DIR}/bin/* ${BUILD_DIR}/bin




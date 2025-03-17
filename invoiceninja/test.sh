#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
VERSION=$1

SNAP=/snap/invoiceninja/current
SNAP_DATA=/var$SNAP
RUNTIME_DIR=$SNAP/invoiceninja
BUILD_DIR=${DIR}/../build/snap/invoiceninja
sed -i "s#$RUNTIME_DIR#$BUILD_DIR#g" ${BUILD_DIR}/usr/local/etc/php/php.ini
sed -i "s#$SNAP_DATA#$BUILD_DIR#g" ${BUILD_DIR}/var/www/app/bootstrap/app.php

${BUILD_DIR}/bin/php-fpm.sh --version
${BUILD_DIR}/bin/php-fpm.sh --version | ( ! grep Warning )
${BUILD_DIR}/bin/php.sh --version
${BUILD_DIR}/bin/php.sh $BUILD_DIR/var/www/app/artisan key:generate --show

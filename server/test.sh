#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}

SNAP=/snap/invoiceninja/current
SNAP_DATA=/var$SNAP
BUILD_DIR=${DIR}/../build/snap/server
TEST_DIR=${DIR}/../build/server.test
cp -r $BUILD_DIR $TEST_DIR
#sed -i "s#$SNAP/invoiceninja#$BUILD_DIR#g" ${BUILD_DIR}/usr/local/etc/php/php.ini
cd $TEST_DIR
mkdir -p framework/{sessions,views,cache}
sed -i "s#$SNAP_DATA/storage#$TEST_DIR#g" $TEST_DIR/bootstrap/app.php
grep return $TEST_DIR/bootstrap/app.php

#$TEST_DIR/bin/artisan.sh key:generate --show

export PATH=$PATH:$BUILD_DIR/../php/bin
$BUILD_DIR/../php/bin/php.sh artisan key:generate --show

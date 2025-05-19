#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/chromium
mkdir -p $BUILD_DIR
cp -r /usr ${BUILD_DIR}
cp -r /lib ${BUILD_DIR}
cp -r /etc ${BUILD_DIR}
cp -r ${DIR}/bin ${BUILD_DIR}/bin
cp -r ${DIR}/ms-playwright/chromium-*/chrome-linux/* ${BUILD_DIR}/lib/*-linux-gnu*/

sed -i 's#<dir>/usr/share/fonts</dir>#<dir>/snap/invoiceninja/current/chromium/usr/share/fonts</dir>#g' ${BUILD_DIR}/etc/fonts/fonts.conf

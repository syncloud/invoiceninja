#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}
cp -r ${DIR}/../build/snap/chromium ${DIR}/../build/chromium
BUILD_DIR=${DIR}/../build/chromium
sed -i "s#/snap/invoiceninja/current/chromium#${BUILD_DIR}#g" ${BUILD_DIR}/etc/fonts/fonts.conf
$BUILD_DIR/bin/chromium.sh \
 --disable-gpu \
 --disable-translate \
 --disable-extensions \
 --disable-sync \
 --disable-background-networking \
 --disable-software-rasterizer \
 --disable-default-apps \
 --disable-dev-shm-usage \
 --safebrowsing-disable-auto-update \
 --run-all-compositor-stages-before-draw \
 --no-first-run \
 --no-margins \
 --no-sandbox \
 --print-to-pdf-no-header \
 --no-pdf-header-footer \
 --hide-scrollbars \
 --ignore-certificate-errors \
 --no-default-browser-check \
 --block-insecure-private-network-requests \
 --block-port=22,25,465,587 \
 --disable-usb \
 --disable-webrtc \
 --block-new-web-contents \
 --deny-permission-prompts \
 --disable-renderer-backgrounding \
 --disable-background-timer-throttling \
 --disable-domain-reliability \
 --disable-ipc-flooding-protection \
 --disable-plugins \
 --disable-notifications \
 --disable-device-discovery-notifications \
 --disable-reading-from-canvas \
 --disable-features=SharedArrayBuffer,OutOfBlinkCors \
 --font-render-hinting=medium \
 --enable-font-antialiasing \
 --virtual-time-budget=10000 \
 --print-to-pdf=test.pdf test.html

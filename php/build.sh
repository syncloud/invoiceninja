#!/bin/sh -xe

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

BUILD_DIR=${DIR}/../build/snap/php
while ! docker ps ; do
  sleep 1
  echo "retry docker"
done
docker build -t php:syncloud .
docker create --name=php php:syncloud
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
docker export php -o php.tar
tar xf php.tar
rm -rf php.tar
mv ${BUILD_DIR}/usr/lib/*-linux*/ImageMagick-*/modules-*/coders ${BUILD_DIR}/usr/lib/ImageMagickCoders
ls -la ${BUILD_DIR}/usr/lib/ImageMagickCoders
cp ${DIR}/bin/* ${BUILD_DIR}/bin
mkdir -p ${BUILD_DIR}/lib/php/extensions
mv ${BUILD_DIR}/usr/local/lib/php/extensions/*/*.so ${BUILD_DIR}/lib/php/extensions
rm -rf ${BUILD_DIR}/usr/src

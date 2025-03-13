#!/bin/sh -ex

VERSION=$1
DIR=$(pwd)
cd ${DIR}/build
BUILD_DIR=${DIR}/../build/snap/invoiceninja
while ! docker create --name=app invoiceninja/invoiceninja:$VERSION ; do
  sleep 1
  echo "retry docker"
done
mkdir -p ${BUILD_DIR}
docker export app -o app.tar
tar xf app.tar

cp -r opt ${BUILD_DIR}
cp -r usr ${BUILD_DIR}
cp -r bin ${BUILD_DIR}
cp -r lib ${BUILD_DIR}
cp -r ${DIR}/bin/* ${BUILD_DIR}/bin



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
cd ${DIR}/build
docker export app -o app.tar
tar xf app.tar

cp -r opt ${BUILD_DIR}
cp -r usr ${BUILD_DIR}
cp -r bin ${BUILD_DIR}
cp -r lib ${BUILD_DIR}
cp -r ${DIR}/bin/* ${BUILD_DIR}/bin



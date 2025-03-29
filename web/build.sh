#!/bin/sh -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build
cd ${BUILD_DIR}
wget https://github.com/cyberb/invoiceninja-ui/archive/refs/heads/main.tar.gz
tar xf main.tar.gz
mv invoiceninja-ui-main web

#!/bin/bash -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build/snap

cd ${BUILD_DIR}
wget --progress=dot:giga https://github.com/cyberb/invoiceninja/archive/refs/heads/v5-stable.tar.gz
tar xf v5-stable.tar.gz
mv invoiceninja-5-stable app

ls -la .
ls -la config

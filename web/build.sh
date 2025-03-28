#!/bin/sh -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build/snap/web
cd ${DIR}/../build

wget https://github.com/cyberb/invoiceninja-ui/archive/refs/heads/main.tar.gz
tar xf invoiceninja-ui-main.tar.gz
cd invoiceninja-ui-main
cp .env.example .env
set -i 's/VITE_IS_HOSTED=.*/VITE_IS_HOSTED=true/g' .env
npm ci
npm run build
mv dist ${BUILD_DIR}
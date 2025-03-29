#!/bin/sh -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build

cd ${BUILD_DIR}
wget https://github.com/cyberb/invoiceninja-ui/archive/refs/heads/main.tar.gz
tar xf main.tar.gz
mv invoiceninja-ui-main web

wget https://github.com/cyberb/invoiceninja/archive/refs/heads/v5-stable.tar.gz
tar xf v5-stable.tar.gz
mv invoiceninja-5-stable server

cd ${BUILD_DIR}/web
cp .env.example .env
sed -i 's/VITE_IS_HOSTED=.*/VITE_IS_HOSTED=true/g' .env
sed -i 's/VITE_IS_TEST=.*/VITE_IS_TEST=false/' .env
cp ${BUILD_DIR}/server/vite.config.ts.react vite.config.js
sed -i '/"version"/c\  "version": " Latest Build - '`date +%Y.%m.%d`'",' package.json
npm i --ignore-scripts
NODE_OPTIONS="--max-old-space-size=6144" npm run build
ls -la dist/


cd ${BUILD_DIR}/server
cp -r ${BUILD_DIR}/web/dist/* public/
npm i 
npm run production
mv public/index.html public/index.php

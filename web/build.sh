#!/bin/bash -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build
SERVER_DIR=${BUILD_DIR}/snap/server

cd ${BUILD_DIR}
wget --progress=dot:giga https://github.com/cyberb/invoiceninja-ui/archive/refs/heads/main.tar.gz
tar xf main.tar.gz
mv invoiceninja-ui-main web

cd ${BUILD_DIR}/web
cp .env.example .env
sed -i 's/VITE_IS_HOSTED=.*/VITE_IS_HOSTED=false/g' .env
sed -i 's/VITE_IS_TEST=.*/VITE_IS_TEST=false/' .env
cp ${SERVER_DIR}/vite.config.ts.react vite.config.js
sed -i '/"version"/c\  "version": " Latest Build - '`date +%Y.%m.%d`'",' package.json

npm config set fetch-retry-mintimeout 200000
npm config set fetch-retry-maxtimeout 1200000

for i in {1..5}; do
  npm i --ignore-scripts && break || rm -rf node_modules && sleep 15
done

NODE_OPTIONS="--max-old-space-size=6144" npm run build
ls -la dist/


cd ${SERVER_DIR}
cp -r ${BUILD_DIR}/web/dist/* public/
mv public/index.html resources/views/react/index.blade.php

for i in {1..5}; do
  npm i && break || rm -rf node_modules && sleep 15
done

echo $?

npm run production
#mv public/index.html public/index.php

#!/bin/sh -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
#BUILD_DIR=${DIR}/../build/snap/web
cd ${DIR}/../build
wget https://github.com/cyberb/invoiceninja-ui/archive/refs/heads/main.tar.gz
tar xf main.tar.gz
mv invoiceninja-ui-main web
cd web
cp .env.example .env
set -i 's/VITE_IS_HOSTED=.*/VITE_IS_HOSTED=true/g' .env
sed -i 's/VITE_IS_TEST=.*/VITE_IS_TEST=false/' .env
npm ci --ignore-scripts
cp ../vite.config.ts.react ./vite.config.js
sed -i '/"version"/c\  "version": " Latest Build - ${{ env.current_date }}",' package.json
npm i
NODE_OPTIONS="--max-old-space-size=6144" npm run build
ls -la dist/

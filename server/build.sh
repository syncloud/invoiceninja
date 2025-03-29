#!/bin/sh -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

VERSION=$1
BUILD_DIR=${DIR}/../build
apt update
apt install -y wget

cd ${BUILD_DIR}
wget --progress=dot:giga https://github.com/cyberb/invoiceninja/archive/refs/heads/v5-stable.tar.gz
tar xf v5-stable.tar.gz
mv invoiceninja-5-stable server

cd ${BUILD_DIR}/server

composer config -g github-oauth.github.com $GITHUB_TOKEN
composer install --no-dev
composer require socialiteproviders/authelia

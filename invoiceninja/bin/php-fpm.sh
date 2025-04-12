#!/bin/sh -e
DIR=$( cd "$( dirname "$0" )" && cd .. && pwd )
LIBS=${DIR}/lib
LIBS=$LIBS:${DIR}/usr/lib
export PHP_INI_SCAN_DIR=${DIR}/usr/local/etc/php:${DIR}/usr/local/etc/php/conf.d
export CURL_CA_BUNDLE=/var/snap/platform/current/syncloud.ca.crt 
exec ${DIR}/lib/ld-*.so* \
  --library-path $LIBS \
  ${DIR}/usr/local/sbin/php-fpm "$@"

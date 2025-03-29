#!/bin/sh -e
DIR=$( cd "$( dirname "$0" )" && cd .. && pwd )
LIBS=${DIR}/lib
LIBS=$LIBS:${DIR}/usr/lib
exec PHP_INI_SCAN_DIR=${DIR}/usr/local/etc/php:${DIR}/usr/local/etc/php/conf.d \
  ${DIR}/lib/ld-*.so* \
  --library-path $LIBS \
  ${DIR}/usr/local/bin/php "$@"

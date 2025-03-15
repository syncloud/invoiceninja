#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
LIBS=${DIR}/lib
LIBS=$LIBS:$(echo ${DIR}/usr/lib)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/*-linux-gnu*/samba)
MAGICK_CODER_MODULE_PATH=$(echo ${DIR}/usr/lib/ImageMagickCoders) PHP_INI_SCAN_DIR=${DIR}/usr/local/etc/php ${DIR}/lib/ld-*.so* --library-path $LIBS ${DIR}/usr/local/bin/php "$@"

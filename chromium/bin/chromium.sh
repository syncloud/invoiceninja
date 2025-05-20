#!/bin/bash -xe
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

export FONTCONFIG_PATH=$DIR/etc/fonts

LIBS_DIR=$(echo ${DIR}/lib/*-linux-gnu*)
LIBS=$LIBS_DIR:$(echo ${DIR}/usr/lib/*-linux-gnu*)
LIBS=$LIBS:$(echo ${DIR}/usr/lib)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/*-linux-gnu*/pulseaudio)

logger "${LIBS_DIR}/ld-*.so* \
  --library-path $LIBS \
  ${LIBS_DIR}/chrome $@ --single-process --headless=old"


exec ${LIBS_DIR}/ld-*.so* \
  --library-path $LIBS \
  ${LIBS_DIR}/chrome "$@" --single-process --headless=old

#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}/../test

SPEC=$1
DISTRO=$2
APP=$3
ARCH=$4

ARGS="--distro=${DISTRO} --domain=${DISTRO}.com --device-host=${APP}.${DISTRO}.com --app=${APP} --arch=${ARCH}"
if [ -f ${DIR}/../package.name ]; then
  ARGS="${ARGS} --app-archive-path=$(realpath ${DIR}/../$(cat ${DIR}/../package.name))"
fi

./deps.sh
py.test -x -s ${SPEC} ${ARGS}

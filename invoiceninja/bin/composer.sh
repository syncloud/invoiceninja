#!/bin/sh -e
DIR=$( cd "$( dirname "$0" )" && cd .. && pwd )
${DIR}/bin/php.sh ${DIR}/usr/local/bin/composer "$@"
in/composer "$@"

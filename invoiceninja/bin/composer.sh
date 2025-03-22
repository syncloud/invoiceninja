#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
${DIR}/bin/php.sh ${DIR}/usr/local/bin/composer "$@"

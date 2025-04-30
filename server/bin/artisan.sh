#!/bin/sh -e
DIR=$( cd "$( dirname "$0" )" && cd .. && pwd )
cd $DIR/..
export PATH=$PATH:$DIR/../bin
${DIR}/../../php/bin/php.sh artisan "$@"

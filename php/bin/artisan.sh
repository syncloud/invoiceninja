#!/bin/sh -e
DIR=$( cd "$( dirname "$0" )" && cd .. && pwd )
cd $DIR/..
export PATH=$PATH:$DIR/../../server/bin
${DIR}/php.sh artisan "$@"

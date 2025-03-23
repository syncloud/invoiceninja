#!/bin/sh -e
DIR=$( cd "$( dirname "$0" )" && cd .. && pwd )
cd $DIR/var/www/app
export PATH=$PATH:$DIR/../bin
${DIR}/bin/php.sh artisan "$@"

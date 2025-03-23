#!/bin/sh -e
DIR=$( cd "$( dirname "$0" )" && cd .. && pwd )
cd $DIR/var/www/app
${DIR}/bin/php.sh artisan "$@"

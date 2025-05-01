#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
export PHP_BINARY=$DIR/php/bin/php.sh
cd $SNAP/server
exec $DIR/bin/artisan.sh \
  queue:work \
  --sleep=3 \
  --tries=3 \
  --max-time=3600 \
  --verbose

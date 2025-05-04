#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
export PHP_BINARY=$DIR/bin/php.sh
cd $SNAP/server
exec $DIR/bin/artisan.sh \
  schedule:work \
  --verbose

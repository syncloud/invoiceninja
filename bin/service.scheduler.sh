#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
export PHP_BINARY=$DIR/invoiceninja/bin/php.sh
cd $SNAP/invoiceninja/var/www/app
exec $DIR/invoiceninja/bin/php.sh \
  $SNAP/invoiceninja/var/www/app/artisan \
  schedule:work \
  --verbose

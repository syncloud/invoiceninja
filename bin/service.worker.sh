#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

$DIR/invoiceninja/bin/php.sh $SNAP/invoiceninja/var/www/app/artisan queue:work --sleep=3 --tries=3 --max-time=3600 --verbose

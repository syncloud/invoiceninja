#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

$DIR/invoiceninja/bin/php.sh $SNAP/invoiceninja/var/www/app/artisan schedule:work --verbose

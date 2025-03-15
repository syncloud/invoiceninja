#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

$DIR/invoiceninja/bin/php-fpm.sh -y ${SNAP}/invoiceninja/usr/local/etc/php-fpm.conf -c ${SNAP}/invoiceninja/usr/local/etc/php.ini

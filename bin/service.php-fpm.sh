#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

$DIR/invoiceninja/bin/php-fpm.sh -y ${SNAP_DATA}/config/php-fpm.conf -c ${SNAP_DATA}/config/php.ininvoiceninja/bin/php-fpm.sh -y ${SNAP_DATA}/config/php-fpm.conf -c ${SNAP_DATA}/config/php.ini

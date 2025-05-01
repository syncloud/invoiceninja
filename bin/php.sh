#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
exec $DIR/php/bin/php.sh -c /var/snap/invoiceninja/current/config/php.ini "$@"

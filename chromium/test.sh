#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}
cp -r ${DIR}/../build/snap/chromium ${DIR}/../build/chromium
BUILD_DIR=${DIR}/../build/chromium
sed -i "s#/snap/invoiceninja/current/chromium#${BUILD_DIR}#g" ${BUILD_DIR}/etc/fonts/fonts.conf


attempts=0
max_attempts=10
timeout=5

while [ $attempts -lt $max_attempts ]; do
    if timeout $timeout $DIR/pdf.sh; then
        exit 0
    fi
    attempts=$((attempts + 1))
    echo "Attempt $attempts failed, retrying..."
done

echo "Failed after $max_attempts attempts"
exit 1

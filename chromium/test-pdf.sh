#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

apt update
apt install poppler-utils
#sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml
pdftotext test.pdf test.txt

grep "I am normal" test.txt
grep "I am red" test.txt
grep "I am blue" test.txt
grep "I am big" test.txt

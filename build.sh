#!/bin/bash

. ./config
FILE="backup-tools_${VERSION}_all"

rm -f ./builds/*.deb
rm -f ./builds/*.rpm

fakeroot dpkg-deb --build ./deb ./builds/${FILE}.deb

cd builds

lintian ./${FILE}.deb
fakeroot alien --to-rpm --scripts ./${FILE}.deb > /dev/null
#mv backup-tools-${VERSION_FAKE}.noarch.rpm backup-tools-${VERSION}.noarch.rpm
echo "Save as backup-tools-${VERSION_FAKE}.noarch.rpm"

cd ..
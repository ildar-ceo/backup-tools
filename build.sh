#!/bin/bash

VERSION="1.1"
FILE="backup-tools_${VERSION}_all"

rm -f ./builds/*.deb
rm -f ./builds/*.rpm

fakeroot dpkg-deb --build ./deb ./builds/${FILE}.deb

cd builds

lintian ./${FILE}.deb
sudo alien --to-rpm --scripts ./${FILE}.deb

cd ..
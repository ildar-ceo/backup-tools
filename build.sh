#!/bin/bash

VERSION="1.1.0"
FILE="backup-tools_${VERSION}_all"

rm -f ./builds/*.deb
rm -f ./builds/*.rpm

fakeroot dpkg-deb --build ./deb ./builds/${FILE}.deb

cd builds

lintian ./${FILE}.deb
fakeroot alien --to-rpm --scripts ./${FILE}.deb


cd ..
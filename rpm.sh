#!/bin/bash

VERSION="1.1.0"
FILE="backup-tools_${VERSION}_all"

#download rpmrebuild from https://sourceforge.net/projects/rpmrebuild/

rpmrebuild -pe ./builds/backup-tools-*.rpm
mv -f ~/rpmbuild/RPMS/noarch/backup-tools-*.rpm ./builds

cd ..
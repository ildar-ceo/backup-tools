#!/bin/bash

. ./config

#download rpmrebuild from https://sourceforge.net/projects/rpmrebuild/

rpmrebuild -pe ./builds/backup-tools-${VERSION_FAKE}.noarch.rpm
mv -f ~/rpmbuild/RPMS/noarch/backup-tools-${VERSION_FAKE}.noarch.rpm ./builds/backup-tools-${VERSION_FAKE}.noarch.rpm

cd ..
#!/bin/bash

VERSION=11.12_aster2
cd /work
rm -rf homard
mkdir homard
wget --no-check-certificate --quiet \
    https://bitbucket.org/code_aster/homard/get/${VERSION}.tar.gz \
    -O homard.tar.gz
tar xf homard.tar.gz -C homard --strip-components 1
cd homard
export LANG=en_US.UTF-8 LC_MESSAGES=POSIX
python3 setup_homard.py --prefix=/scif/apps/homard
ln -s /scif/apps/homard/homard /usr/local/bin/

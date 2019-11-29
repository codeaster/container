#!/bin/bash

VERSION=6.0.4_aster7
cd ${DATA}
rm -rf scotch_seq
hg clone --noupdate https://bitbucket.org/code_aster/scotch scotch_seq
cd scotch_seq
hg update ${VERSION}
cd src
sed -i -e 's/CFLAGS\s*=/CFLAGS = -Wl,--no-as-needed/g' \
    -e 's/CCD\s*=.*$/CCD = cc/g' Makefile.inc
make scotch
make esmumps
mkdir -p /scif/apps/scotch_seq
make install prefix=/scif/apps/scotch_seq

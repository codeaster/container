#!/bin/bash

VERSION=6.0.4_aster7
cd ${DATA}
rm -rf scotch-seq
hg clone --noupdate https://bitbucket.org/code_aster/scotch scotch-seq
cd scotch-seq
hg update ${VERSION}
cd src
sed -i -e 's/CFLAGS\s*=/CFLAGS = -Wl,--no-as-needed/g' \
    -e 's/CCD\s*=.*$/CCD = cc/g' Makefile.inc
make scotch
make esmumps
mkdir -p /scif/apps/scotch-seq
make install prefix=/scif/apps/scotch-seq

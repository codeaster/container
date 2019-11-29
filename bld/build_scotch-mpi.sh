#!/bin/bash

VERSION=6.0.4_aster7
cd ${DATA}
rm -rf scotch-mpi
hg clone --noupdate https://bitbucket.org/code_aster/scotch scotch-mpi
cd scotch-mpi
hg update ${VERSION}
cd src
sed -i -e 's/CFLAGS\s*=/CFLAGS = -Wl,--no-as-needed/g' \
    -e 's/CCD\s*=.*$/CCD = mpicc/g' Makefile.inc
make scotch
make ptscotch
make esmumps
mkdir -p /scif/apps/scotch-mpi
make install prefix=/scif/apps/scotch-mpi

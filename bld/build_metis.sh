#!/bin/bash

VERSION=5.1.0_aster4
cd ${DATA}
rm -rf metis
hg clone --noupdate https://bitbucket.org/code_aster/metis metis
cd metis
hg update ${VERSION}
make config prefix=/scif/apps/metis
make -j 4
make install

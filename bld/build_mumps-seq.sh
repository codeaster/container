#!/bin/bash

VERSION=5.1.2_aster6
cd ${DATA}
rm -rf mumps-seq
hg clone --noupdate https://bitbucket.org/code_aster/mumps mumps-seq
cd mumps-seq
hg update ${VERSION}
LIBPATH="/scif/apps/scotch-seq/lib /scif/apps/metis/lib /scif/apps/parmetis/lib" \
    INCLUDES="/scif/apps/scotch-seq/include /scif/apps/metis/include /scif/apps/parmetis/include" \
    python3 ./waf configure --enable-openmp --enable-metis --enable-scotch \
        --install-tests --prefix=/scif/apps/mumps-seq
python3 ./waf build --jobs=1
python3 ./waf install --jobs=1

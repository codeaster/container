#!/bin/bash

VERSION=5.1.2_aster6
cd ${DATA}
rm -rf mumps-mpi
hg clone --noupdate https://bitbucket.org/code_aster/mumps mumps-mpi
cd mumps-mpi
hg update ${VERSION}
LIBPATH="/scif/apps/scotch-mpi/lib /scif/apps/metis/lib /scif/apps/parmetis/lib" \
    INCLUDES="/scif/apps/scotch-mpi/include /scif/apps/metis/include /scif/apps/parmetis/include" \
    python3 ./waf configure --enable-mpi --enable-openmp --enable-metis --enable-parmetis --enable-scotch \
        --install-tests --prefix=/scif/apps/mumps-mpi
python3 ./waf build --jobs=1
python3 ./waf install --jobs=1

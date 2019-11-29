#!/bin/bash

VERSION=3.9.4_aster
cd ${DATA}
rm -rf petsc
hg clone --noupdate https://bitbucket.org/code_aster/petsc
cd petsc
hg update ${VERSION}
cd petsc-src
./configure \
    --with-debugging=0 \
    --with-mpi=1 \
    --with-ssl=0 \
    --with-x=0 \
    --with-mumps-lib="-L/scif/apps/mumps_mpi/lib -lzmumps -ldmumps -lmumps_common -lpord -L/scif/apps/scotch_mpi/lib -lesmumps -lptscotch -lptscotcherr -lptscotcherrexit -lscotch -lscotcherr -lscotcherrexit -L/scif/apps/parmetis/lib -lparmetis -L/scif/apps/metis/lib -lmetis" \
    --with-mumps-include=/scif/apps/mumps_mpi/include \
    --with-blas-lapack-lib="-lopenblas -llapack -lblacsCinit-openmpi -lblacsF77init-openmpi -lblacs-openmpi" \
    --with-scalapack-lib="-lscalapack-openmpi" \
    --PETSC_ARCH=arch-linux2-codeaster \
    --download-ml=${DATA}/petsc/3rd/petsc-pkg-ml-e5040d11aa07.tar.gz \
    --download-hypre=${DATA}/petsc/3rd/hypre-2.14.0.tar.gz \
    --download-superlu=${DATA}/petsc/3rd/superlu-a0819410c9eb779f9b296cdd95fbdfd96986ae10.tar.gz \
    --with-openmp=0 \
    LIBS=-lgomp \
    --prefix=/scif/apps/petsc
make -j 4 PETSC_DIR=${DATA}/petsc/petsc-src PETSC_ARCH=arch-linux2-codeaster all
make -j 4 PETSC_DIR=${DATA}/petsc/petsc-src PETSC_ARCH=arch-linux2-codeaster install
